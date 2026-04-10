# 🔄 Jenkins CI/CD Pipeline Setup - Zomato Clone

## Architecture Overview

```
GitHub Push
    ↓
GitHub Webhook
    ↓
Jenkins Pipeline Triggered
    ↓
Checkout Code
    ↓
Build Docker Image
    ↓
Push to AWS ECR
    ↓
Deploy to ECS/EC2
    ↓
Health Check & Verify
```

---

## Prerequisites

1. **Jenkins Server**
   - Jenkins 2.300+ installed
   - Running with Docker support
   - Java 11+ installed

2. **Jenkins Plugins**
   - Docker Pipeline
   - Amazon ECR plugin
   - GitHub plugin
   - AWS Steps

3. **Credentials Setup in Jenkins**

### Add Docker Registry Credentials
```
Jenkins → Manage Credentials → Systems → Global Credentials
Add Credentials → Username with password
ID: ecr-credentials
Username: AWS
Password: YOUR_AWS_ACCESS_KEY
```

### Add AWS Credentials
```
Add Credentials → AWS Credentials
ID: aws-creds
Access Key ID: YOUR_KEY
Secret Access Key: YOUR_SECRET
```

### Add GitHub Credentials
```
Add Credentials → GitHub Personal Access Token
ID: github-token
Token: YOUR_GITHUB_TOKEN
```

---

## Create Jenkins Pipeline Job

### Step 1: Create New Job
1. Click **New Item**
2. Enter name: `zomato-clone-pipeline`
3. Select **Pipeline**
4. Click **OK**

### Step 2: Configure Pipeline

**Pipeline Definition:**
- Select: **Pipeline script from SCM**
- SCM: **Git**
- Repository URL: `https://github.com/YOUR_GITHUB/zomato-clone.git`
- Credentials: Select **github-token**
- Branch: `*/main`
- Script Path: `Jenkinsfile`

### Step 3: Build Triggers

Check **GitHub hook trigger for GITScm polling**

Or Manual: Click **Build Now**

---

## Jenkinsfile Configuration

Create `Jenkinsfile` in project root:

```groovy
#!/usr/bin/env groovy

pipeline {
    agent any
    
    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = credentials('aws-account-id')
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        ECR_REPO = 'zomato-clone'
        IMAGE_TAG = "${BUILD_NUMBER}"
        GITHUB_REPO = 'YOUR_GITHUB/zomato-clone'
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
    }
    
    stages {
        stage('📥 Checkout') {
            steps {
                script {
                    echo "Checking out code from GitHub..."
                }
                checkout scm
            }
        }
        
        stage('🧹 Clean') {
            steps {
                script {
                    echo "Cleaning Docker environment..."
                    sh 'docker system prune -f --volumes || true'
                }
            }
        }
        
        stage('🔨 Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image..."
                    sh '''
                        docker build \
                            -t ${ECR_REPO}:${IMAGE_TAG} \
                            -t ${ECR_REPO}:latest \
                            .
                    '''
                    sh 'docker images | grep zomato-clone'
                }
            }
        }
        
        stage('✅ Test') {
            steps {
                script {
                    echo "Running container tests..."
                    sh '''
                        docker run -d \
                            --name zomato-test \
                            -p 9090:80 \
                            ${ECR_REPO}:latest
                        
                        sleep 5
                        
                        # Health check
                        if curl -f http://localhost:9090 > /dev/null; then
                            echo "✓ Health check passed"
                        else
                            echo "✗ Health check failed"
                            docker logs zomato-test
                            exit 1
                        fi
                        
                        docker stop zomato-test
                        docker rm zomato-test
                    '''
                }
            }
        }
        
        stage('🔐 AWS Login') {
            steps {
                script {
                    echo "Logging in to AWS ECR..."
                    withAWS(credentials: 'aws-creds', region: '${AWS_REGION}') {
                        sh '''
                            aws ecr get-login-password --region ${AWS_REGION} | \
                            docker login --username AWS --password-stdin ${ECR_REGISTRY}
                        '''
                    }
                }
            }
        }
        
        stage('🏷️ Tag & Push to ECR') {
            steps {
                script {
                    echo "Pushing image to ECR..."
                    sh '''
                        docker tag ${ECR_REPO}:${IMAGE_TAG} ${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}
                        docker tag ${ECR_REPO}:latest ${ECR_REGISTRY}/${ECR_REPO}:latest
                        
                        docker push ${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}
                        docker push ${ECR_REGISTRY}/${ECR_REPO}:latest
                        
                        echo "Image push complete!"
                        aws ecr describe-images --repository-name ${ECR_REPO} --region ${AWS_REGION}
                    '''
                }
            }
        }
        
        stage('🚀 Deploy to ECS') {
            steps {
                script {
                    echo "Updating ECS service..."
                    withAWS(credentials: 'aws-creds', region: '${AWS_REGION}') {
                        sh '''
                            aws ecs update-service \
                                --cluster zomato-cluster \
                                --service zomato-service \
                                --force-new-deployment \
                                --region ${AWS_REGION}
                            
                            echo "Waiting for service to stabilize..."
                            sleep 10
                            
                            aws ecs describe-services \
                                --cluster zomato-cluster \
                                --services zomato-service \
                                --region ${AWS_REGION}
                        '''
                    }
                }
            }
        }
        
        stage('📊 Verify Deployment') {
            steps {
                script {
                    echo "Verifying deployment..."
                    withAWS(credentials: 'aws-creds', region: '${AWS_REGION}') {
                        sh '''
                            TASK_ID=$(aws ecs list-tasks --cluster zomato-cluster --region ${AWS_REGION} --query 'taskArns[0]' --output text)
                            
                            if [ -z "$TASK_ID" ]; then
                                echo "No running tasks found"
                                exit 1
                            fi
                            
                            echo "Running task: $TASK_ID"
                            
                            for i in {1..30}; do
                                STATUS=$(aws ecs describe-tasks --cluster zomato-cluster --tasks $TASK_ID --region ${AWS_REGION} --query 'tasks[0].lastStatus' --output text)
                                echo "Task status: $STATUS"
                                
                                if [ "$STATUS" = "RUNNING" ]; then
                                    echo "✓ Service deployed successfully!"
                                    exit 0
                                fi
                                
                                sleep 10
                            done
                            
                            echo "✗ Deployment verification timeout"
                            exit 1
                        '''
                    }
                }
            }
        }
        
        stage('🧹 Cleanup') {
            steps {
                script {
                    echo "Cleaning up..."
                    sh '''
                        docker rmi ${ECR_REPO}:${IMAGE_TAG} ${ECR_REPO}:latest || true
                        docker image prune -f || true
                    '''
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo "Pipeline execution completed"
            }
        }
        
        success {
            script {
                echo "✓ Deployment successful!"
                // Optional: Send notifications
                // slackSend(color: 'good', message: 'Zomato Clone deployed successfully')
            }
        }
        
        failure {
            script {
                echo "✗ Deployment failed!"
                // Optional: Send notifications
                // slackSend(color: 'danger', message: 'Zomato Clone deployment failed')
            }
        }
    }
}
```

---

## GitHub Webhook Setup

### Configure Webhook in GitHub

1. Go to Repository Settings
2. Select **Webhooks**
3. Click **Add Webhook**
4. Configure:
   - **Payload URL**: `http://your-jenkins-url:8080/github-webhook/`
   - **Content type**: `application/json`
   - **Events**: Push events
   - **Active**: ✓ Checked
5. Click **Add webhook**

### Verify Webhook
```bash
# Recent Deliveries tab shows webhook calls
# Check green checkmarks for successful delivery
```

---

## Advanced Configuration

### Email Notifications

Add to Jenkinsfile `post` section:
```groovy
post {
    always {
        emailext(
            subject: "Build ${env.BUILD_NUMBER} - ${currentBuild.result}",
            body: """
                Build: ${env.BUILD_URL}
                Status: ${currentBuild.result}
            """,
            to: 'your-email@example.com'
        )
    }
}
```

### Slack Notifications

```groovy
post {
    success {
        slackSend(
            color: 'good',
            message: "Deployment successful: ${env.BUILD_URL}"
        )
    }
    failure {
        slackSend(
            color: 'danger',
            message: "Deployment failed: ${env.BUILD_URL}"
        )
    }
}
```

### Blue Ocean UI

1. Install "Blue Ocean" plugin in Jenkins
2. Go to Jenkins Dashboard
3. Click **Open Blue Ocean**
4. Select your pipeline
5. Visual workflow execution

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Webhook not triggering | Verify GitHub token permissions, firewall rules |
| Build fails on Docker | Check Docker daemon running, disk space |
| ECR push fails | Verify AWS credentials, IAM permissions |
| ECS deployment fails | Check task definition, service configuration |
| Permission denied errors | Add Jenkins user to docker group: `sudo usermod -a -G docker jenkins` |

---

## Testing Pipeline Manually

```bash
# 1. SSH into Jenkins server
ssh user@jenkins-server

# 2. Trigger pipeline
curl -X POST \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  http://localhost:8080/job/zomato-clone-pipeline/build

# 3. Monitor build
tail -f /var/log/jenkins/jenkins.log
```

---

## Security Best Practices

✅ Use Jenkins credentials for sensitive data
✅ Enable HTTPS for Jenkins
✅ Restrict webhook IP addresses
✅ Use IAM roles instead of access keys
✅ Enable build job security
✅ Audit Jenkins logs regularly
✅ Keep Jenkins and plugins updated

---

**Last Updated:** 2024
**Version:** 1.0
