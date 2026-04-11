# 🔄 Jenkins CI/CD Pipeline Setup - Zomato Clone

## Architecture Overview

```
GitHub Push (main branch)
    ↓
GitHub Webhook
    ↓
Jenkins Pipeline Triggered (Agent: "vinod")
    ↓
Stage 1: Checkout Code from GitHub
    ↓
Stage 2: Build Docker Image (Multi-stage)
    ↓
Stage 3: Validate & Test
    ↓
Stage 4: Push to DockerHub (him1029g/zomato_clone)
    ↓
Stage 5: Deploy via Docker Compose
    ↓
Health Check & Application Live 🚀
```

---

## Prerequisites

1. **Jenkins Server**
   - Jenkins 2.300+ installed
   - Running with Docker support
   - Java 11+ installed
   - Docker installed on Jenkins agent node

2. **Jenkins Plugins Required**
   - Docker Pipeline
   - GitHub plugin
   - Pipeline: Stage View
   - Log Parser (optional)

3. **Credentials Setup in Jenkins**

### Add DockerHub Credentials
```
Jenkins → Manage Jenkins → Manage Credentials → Systems → Global Credentials
Add Credentials → Username with password
ID: dockerhubcred
Username: your_dockerhub_username
Password: your_dockerhub_password (or token)
```

### Add GitHub Credentials (Optional - for private repos)
```
Add Credentials → GitHub Personal Access Token
ID: github-token
Token: YOUR_GITHUB_TOKEN
```

---

## Create Jenkins Pipeline Job

### Step 1: Create New Job
1. Click **New Item**
2. Enter name: `Declarative Pipeline` (or any name you prefer)
3. Select **Pipeline**
4. Click **OK**

### Step 2: Configure Pipeline Source

**Pipeline Definition:**
- Select: **Pipeline script from SCM**
- SCM: **Git**
- Repository URL: `https://github.com/himanshu1029g/Zomato-Clone.git`
- Credentials: Leave blank (public repo) or select GitHub credentials if private
- Branch: `*/main`
- Script Path: `Jenkinsfile`

### Step 3: Build Triggers

✅ Check: **GitHub hook trigger for GITScm polling**

This enables automatic builds when you push to GitHub main branch.

### Step 4: Test the Pipeline

Click **Build Now** to test manually, or push code to GitHub to trigger via webhook.

---

## The Jenkinsfile Explained

Your project already has a `Jenkinsfile` in the root directory with this structure:

### Pipeline Overview

```groovy
pipeline {
    agent { label "vinod" }    // Runs on Jenkins Agent named "vinod"
    
    stages {
        stage("📋 Code") { }           // Clone from GitHub
        stage("🔨 Build") { }          // Build Docker image
        stage("🧪 Test") { }           // Validate image
        stage("📤 Push to DockerHub") { }  // Push to registry
        stage("🚀 Deployment") { }     // Deploy with Docker Compose
    }
    
    post { }                   // Success/Failure notifications
}
```

---

## Stage Details

### Stage 1️⃣: Code (Clone Repository)
```groovy
stage("📋 Code") {
    steps {
        git url: "https://github.com/himanshu1029g/Zomato-Clone.git", 
            branch: "main"
    }
}
```
**What it does:**
- Clones the latest code from `main` branch
- Runs on agent node "vinod"
- Takes ~1-3 seconds

---

### Stage 2️⃣: Build (Docker Build)
```groovy
stage("🔨 Build") {
    steps {
        sh "docker build -t zomato_clone:latest ."
    }
}
```
**What it does:**
- Executes multi-stage Docker build from `Dockerfile`
- Creates image: `zomato_clone:latest`
- Size: ~40MB (optimized with Alpine Linux)
- Takes ~400-500ms

---

### Stage 3️⃣: Test (Validation)
```groovy
stage("🧪 Test") {
    steps {
        // Validates Docker image and Dockerfile syntax
    }
}
```
**What it does:**
- Validates image was created successfully
- Checks Dockerfile syntax
- Can add container tests here
- Takes ~70-80ms

---

### Stage 4️⃣: Push to DockerHub
```groovy
stage("📤 Push to DockerHub") {
    steps {
        withCredentials([usernamePassword(
            credentialsId: "dockerhubcred",
            passwordVariable: "dockerHubPass",
            usernameVariable: "dockerHubUser"
        )]) {
            sh '''
                docker login -u ${dockerHubUser} -p ${dockerHubPass}
                docker tag zomato_clone:latest him1029g/zomato_clone:latest
                docker push him1029g/zomato_clone:latest
            '''
        }
    }
}
```
**What it does:**
- Authenticates with DockerHub using credentials
- Tags image: `him1029g/zomato_clone:latest`
- Pushes to DockerHub public registry
- Image available at: https://hub.docker.com/r/him1029g/zomato_clone
- Takes ~2-3 seconds

---

### Stage 5️⃣: Deployment (Docker Compose)
```groovy
stage("🚀 Deployment") {
    steps {
        sh '''
            docker compose down --remove-orphans || true
            docker compose up -d
        '''
    }
}
```
**What it does:**
- Stops and removes old containers safely
- Pulls latest image from DockerHub
- Starts new container via `docker-compose.yml`
- Application accessible at `http://localhost:8080` (or EC2 IP)
- Takes ~1 second

---

## Pipeline Execution Flow

```
┌─────────────────────────────────────────────────┐
│ GitHub Webhook Trigger (on push to main)        │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│ Jenkins Job: "Declarative Pipeline" Starts      │
└────────────────────┬────────────────────────────┘
                     │
        ┌────────────┼────────────┬────────────────┬──────────────┐
        ▼            ▼            ▼                ▼              ▼
   ┌─────────┐  ┌─────────┐  ┌──────────┐    ┌──────────────┐  ┌──────────┐
   │  Code   │  │  Build  │  │  Test    │    │  Push to     │  │ Deploy   │
   │ Clone   │  │ Docker  │  │Validate  │    │DockerHub     │  │via       │
   │ 1-3s    │  │ 412ms   │  │ 78ms     │    │ 2-3s         │  │Compose   │
   │         │  │         │  │          │    │              │  │ 1s       │
   └────┬────┘  └────┬────┘  └────┬─────┘    └──────┬───────┘  └────┬─────┘
        │            │            │                 │               │
        └────────────┴────────────┴─────────────────┴───────────────┘
                     │
                     ▼
         ┌───────────────────────────────┐
         │ Pipeline Complete ✅           │
         │ Total Time: ~8-10 seconds     │
         │ App Live at Port 8080          │
         └───────────────────────────────┘
```

---

## GitHub Webhook Setup (Automated Triggers)

### Step 1: Get Jenkins Webhook URL
```
Jenkins_URL/github-webhook/
Example: http://16.16.124.83:8080/github-webhook/
```

### Step 2: Add Webhook to GitHub
1. Go to: GitHub Repository → Settings → Webhooks
2. Click: **Add webhook**
3. Fill in:
   - **Payload URL**: `http://your-jenkins:8080/github-webhook/`
   - **Content type**: `application/json`
   - **Events**: Select "Push events"
   - **Active**: ✅ Check

### Step 3: Test Webhook
- Push code to main branch
- Jenkins should automatically trigger build
- Check Jenkins Console Output for logs

---

## Build Status & Monitoring

### View Build Status
1. Jenkins Dashboard → Job → Build History
2. Click build number to see details
3. Check Console Output for logs

### Monitor Stages
- Each stage shows duration
- Green = Success ✅
- Red = Failed ❌

### Access Application
- **Local**: `http://localhost:8080`
- **AWS EC2**: `http://<EC2_IP>:8080`
- **DockerHub**: https://hub.docker.com/r/him1029g/zomato_clone

---

## Troubleshooting

### Build Fails at Code Stage
```bash
# Check GitHub URL
git clone https://github.com/himanshu1029g/Zomato-Clone.git
# Verify branch exists
git branch -a
```

### Build Fails at Docker Build Stage
```bash
# Verify Dockerfile exists
ls -l Dockerfile
# Test build locally
docker build -t zomato_clone:latest .
```

### Push to DockerHub Fails
```bash
# Check credentials
Jenkins → Manage Credentials → Look for "dockerhubcred"
# Test DockerHub login locally
docker login
docker push him1029g/zomato_clone:latest
```

### Deployment Fails
```bash
# Check docker-compose.yml
docker-compose config
# Test locally
docker-compose up -d
docker-compose logs web
```

---

## Performance Metrics

| Metric | Value |
|--------|-------|
| Average Code Stage | 1-3s |
| Average Build Stage | 412ms |
| Average Test Stage | 78ms |
| Average Push Stage | 2-3s |
| Average Deploy Stage | 1s |
| **Total Pipeline Time** | **~8-10s** |
| Simultaneous Builds | 1 (serial) |
| Max Timeout | 30 minutes |

---

## Next Steps

1. ✅ Verify Jenkins has Docker installed
2. ✅ Add `dockerhubcred` credentials in Jenkins
3. ✅ Create pipeline job pointing to Jenkinsfile
4. ✅ Configure GitHub webhook
5. ✅ Push code to trigger first build
6. ✅ Monitor console output
7. ✅ Access application at `http://localhost:8080`

---

## Documentation Links

- [Jenkinsfile Reference](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/)
- [GitHub Webhook Setup](https://docs.github.com/en/developers/webhooks-and-events/webhooks/)
- [Docker Pipeline Plugin](https://plugins.jenkins.io/docker-pipeline/)
- [Jenkins Agent Setup](https://www.jenkins.io/doc/book/using/using-agents/)
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
