# 🐳 Zomato Clone - Docker & Jenkins Deployment Guide

## Project Structure Overview

```
Zomato_Clone/
├── src/                          # Application source files
│   ├── index.html
│   ├── just.html
│   ├── style.css
│   ├── image/                    # Static assets (copy images here)
│   └── ...
├── nginx/
│   └── nginx.conf                # Nginx web server config
├── docs/
│   ├── DEPLOYMENT.md             # This file
│   ├── DOCKER_SETUP.md           # Docker quick start
│   └── JENKINS_CI-CD.md          # Jenkins pipeline setup
├── Dockerfile                    # Docker image definition
├── docker-compose.yml            # Multi-container orchestration
├── .dockerignore                 # Files to exclude from Docker build
├── .gitignore
├── .env.example                  # Environment variables template
└── README.md
```

---

## Part 1: Local Docker Setup & Testing

### Prerequisites
- Docker Desktop installed (Windows, Mac) or Docker Engine (Linux)
- Docker Compose v3.8+
- Git installed

### Step 1: Copy Images to src/image Directory
```bash
# Navigate to project root
cd d:\Projects\Zomato_Clone

# If you haven't already, copy images from root to src/
mkdir src\image
copy miantop.avif src\image\
copy miantop2.avif src\image\
# Copy all other images from the image/ folder to src/image/
```

### Step 2: Build Docker Image Locally
```bash
# Test build locally
docker build -t zomato-clone:latest .

# Check if build was successful
docker images | grep zomato-clone
```

### Step 3: Run Container Locally
```bash
# Option A: Using docker run
docker run -d \
  --name zomato-local \
  -p 8080:80 \
  zomato-clone:latest

# Option B: Using docker-compose (recommended)
docker-compose up -d

# Verify container is running
docker ps
```

### Step 4: Test Application
```bash
# Open browser and navigate to:
http://localhost:8080

# Check logs
docker logs zomato-local

# Health check
curl http://localhost:8080
```

### Step 5: Stop Container
```bash
# Using docker-compose
docker-compose down

# OR using docker run
docker stop zomato-local
docker rm zomato-local
```

---

## Part 2: Push to Docker Registry (DockerHub/ECR)

### Option A: DockerHub

```bash
# Step 1: Login to DockerHub
docker login
# Enter username and password

# Step 2: Tag image
docker tag zomato-clone:latest YOUR_DOCKERHUB_USERNAME/zomato-clone:latest
docker tag zomato-clone:latest YOUR_DOCKERHUB_USERNAME/zomato-clone:v1.0

# Step 3: Push to registry
docker push YOUR_DOCKERHUB_USERNAME/zomato-clone:latest
docker push YOUR_DOCKERHUB_USERNAME/zomato-clone:v1.0

# Verify on DockerHub
# Visit: https://hub.docker.com/r/YOUR_DOCKERHUB_USERNAME/zomato-clone
```

### Option B: AWS ECR (Recommended for Jenkins CI/CD)

```bash
# Step 1: Create ECR repository in AWS
aws ecr create-repository \
  --repository-name zomato-clone \
  --region us-east-1

# Step 2: Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Step 3: Tag image for ECR
docker tag zomato-clone:latest YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/zomato-clone:latest
docker tag zomato-clone:latest YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/zomato-clone:v1.0

# Step 4: Push to ECR
docker push YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/zomato-clone:latest
docker push YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/zomato-clone:v1.0

# Verify in AWS Console
# Go to: ECR → Repositories → zomato-clone
```

---

## Part 3: Jenkins CI/CD Pipeline Setup

### Prerequisites
- Jenkins server running (local or cloud)
- Jenkins plugins: Git, Docker, AWS
- Docker installed on Jenkins agent
- AWS credentials configured in Jenkins

### Step 1: Create Jenkins Job

1. **Login to Jenkins Dashboard**
   - URL: `http://your-jenkins-url:8080`

2. **Create New Pipeline Job**
   - Click "New Item"
   - Name: `zomato-clone-pipeline`
   - Select: "Pipeline"
   - Click "OK"

### Step 2: Configure Pipeline

**See JENKINS_CI-CD.md for detailed Jenkinsfile setup**

Or create `Jenkinsfile` in project root with this content:

```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPO = 'zomato-clone'
        TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/YOUR_GITHUB/zomato-clone.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t ${DOCKER_REGISTRY}/${ECR_REPO}:${TAG} .'
                    sh 'docker tag ${DOCKER_REGISTRY}/${ECR_REPO}:${TAG} ${DOCKER_REGISTRY}/${ECR_REPO}:latest'
                }
            }
        }
        
        stage('Push to ECR') {
            steps {
                script {
                    sh '''
                        aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${DOCKER_REGISTRY}
                        docker push ${DOCKER_REGISTRY}/${ECR_REPO}:${TAG}
                        docker push ${DOCKER_REGISTRY}/${ECR_REPO}:latest
                    '''
                }
            }
        }
        
        stage('Deploy to AWS') {
            steps {
                script {
                    sh '''
                        # Update ECS service with new image
                        aws ecs update-service \
                            --cluster zomato-cluster \
                            --service zomato-service \
                            --force-new-deployment \
                            --region us-east-1
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
```

### Step 3: Jenkins Job Configuration

1. **Pipeline Definition**
   - Select: "Pipeline script from SCM"
   - SCM: Git
   - Repository URL: `https://github.com/YOUR_GITHUB/zomato-clone.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`

2. **Build Triggers**
   - Check: "GitHub hook trigger for GITScm polling"
   - Or: "Poll SCM" - set to `* * * * *` (every minute)

3. **Save & Apply**

### Step 4: Trigger Pipeline

**Option A: Manual Trigger**
- Click "Build Now" on job dashboard

**Option B: GitHub Webhook**
- Go to GitHub repository settings
- Webhooks → Add webhook
- Payload URL: `http://jenkins-url:8080/github-webhook/`
- Events: Push events
- Active: Check

---

## Part 4: AWS Deployment

### Option A: ECS (Elastic Container Service)

#### Create ECS Cluster & Service

```bash
# 1. Create cluster
aws ecs create-cluster --cluster-name zomato-cluster

# 2. Create task definition
aws ecs register-task-definition \
  --family zomato-task \
  --network-mode awsvpc \
  --requires-compatibilities FARGATE \
  --cpu 256 \
  --memory 512 \
  --container-definitions '[
    {
      "name": "zomato-container",
      "image": "YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/zomato-clone:latest",
      "portMappings": [{"containerPort": 80, "hostPort": 80}],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/zomato",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]'

# 3. Create service
aws ecs create-service \
  --cluster zomato-cluster \
  --service-name zomato-service \
  --task-definition zomato-task \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxxxx],securityGroups=[sg-xxxxx],assignPublicIp=ENABLED}"
```

#### Verify Deployment

```bash
# Check service status
aws ecs describe-services \
  --cluster zomato-cluster \
  --services zomato-service

# Check running tasks
aws ecs list-tasks --cluster zomato-cluster
```

### Option B: EC2 with Docker Compose

```bash
# SSH into EC2 instance
ssh -i your-key.pem ec2-user@your-instance-ip

# Install Docker
sudo yum update -y
sudo yum install docker -y
sudo usermod -a -G docker ec2-user
newgrp docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Clone repository
git clone https://github.com/YOUR_GITHUB/zomato-clone.git
cd zomato-clone

# Run with Docker Compose
docker-compose up -d

# Verify
docker ps
```

### Option C: EKS (Kubernetes)

See [KUBERNETES_DEPLOYMENT.md](KUBERNETES_DEPLOYMENT.md) for Kubernetes setup.

---

## Part 5: Monitoring & Logs

### Docker Logs
```bash
docker logs zomato-local
docker logs -f zomato-local  # Follow logs
```

### AWS CloudWatch Logs
```bash
# View logs
aws logs tail /ecs/zomato --follow

# Get log streams
aws logs describe-log-streams --log-group-name /ecs/zomato
```

### Jenkins Build Logs
- Jenkins Dashboard → Select job → Build # → Console Output

---

## Part 6: Cleanup

### Remove Local Docker Resources
```bash
# Stop and remove container
docker-compose down
docker rmi zomato-clone:latest

# Clean up dangling images
docker image prune -a
```

### Remove AWS Resources
```bash
# Delete ECS service
aws ecs delete-service \
  --cluster zomato-cluster \
  --service zomato-service \
  --force

# Delete ECS cluster
aws ecs delete-cluster --cluster zomato-cluster

# Delete ECR repository
aws ecr delete-repository \
  --repository-name zomato-clone \
  --force

# Delete EC2 instance (if used)
aws ec2 terminate-instances --instance-ids i-xxxxx
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Docker build fails | Check Dockerfile syntax, ensure all files exist |
| Container won't start | Check docker logs, verify port availability |
| ECR push fails | Verify AWS credentials, region, repository name |
| Jenkins pipeline fails | Check Jenkins console output, verify AWS role permissions |
| App not accessible | Check security groups, load balancer health check |

---

## Quick Reference Commands

```bash
# Docker
docker build -t zomato-clone:latest .
docker run -d -p 8080:80 zomato-clone:latest
docker-compose up -d
docker-compose logs -f

# AWS ECR
aws ecr get-login-password | docker login --username AWS --password-stdin ECR_URL
docker push ECR_URL/zomato-clone:latest

# Jenkins
curl -X POST http://jenkins:8080/job/zomato-clone-pipeline/build --user user:token
```

---

**Last Updated:** 2024
**Version:** 1.0
