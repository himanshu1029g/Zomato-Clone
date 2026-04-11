# 🐳 Zomato Clone - Complete Deployment Guide

## Project Structure Overview

```
Zomato_Clone/
├── src/                          # Application source files
│   ├── index.html                # Landing page
│   ├── just.html                 # Secondary page
│   ├── style.css                 # Styling
│   ├── image/                    # Static assets
│   ├── miantop.avif              # Hero image 1
│   └── miantop2.avif             # Hero image 2
├── nginx/
│   └── nginx.conf                # Optimized web server config
├── docs/
│   ├── DEPLOYMENT.md             # This file
│   ├── DOCKER_SETUP.md           # Quick Docker start
│   ├── JENKINS_CI-CD.md          # CI/CD pipeline guide
│   └── SETUP_CHECKLIST.md        # Pre-deployment checklist
├── Dockerfile                    # Multi-stage Docker build
├── Jenkinsfile                   # Jenkins CI/CD pipeline
├── docker-compose.yml            # Container orchestration
├── docker-compose.override.yml.example  # Dev overrides
├── .dockerignore                 # Files to exclude from build
├── .gitignore                    # Git ignore rules
├── .env.example                  # Environment variables template
├── LICENSE                       # MIT License
├── CONTRIBUTING.md               # Contribution guidelines
└── README.md                     # Project documentation
```

---

## Part 1: Local Docker Setup & Testing

### Prerequisites
- Docker Desktop installed (Windows, Mac) or Docker Engine (Linux)
- Docker Compose v3.8+
- Git installed
- 200 MB free disk space

### Step 1: Clone Repository
```bash
# Clone the repository
git clone https://github.com/himanshu1029g/Zomato-Clone.git
cd Zomato-Clone

# Verify project structure
ls -la
```

### Step 2: Build Docker Image Locally
```bash
# Navigate to project root
cd d:\Projects\Zomato_Clone

# Build Docker image
docker build -t zomato_clone:latest .

# Verify build was successful
docker images | grep zomato_clone
```

**Expected Output:**
```
REPOSITORY      TAG       IMAGE ID      SIZE
zomato_clone    latest    a1b2c3d4e5    40MB
```

### Step 3: Run Container Locally

**Option A: Using Docker Compose (Recommended)**
```bash
# Start container with docker-compose
docker-compose up -d

# Verify container is running
docker-compose ps

# View logs
docker-compose logs -f web
```

**Option B: Using Docker Run**
```bash
# Run container directly
docker run -d \
  --name zomato-local \
  -p 8080:80 \
  zomato_clone:latest

# Verify container is running
docker ps | grep zomato
```

### Step 4: Test Application
```bash
# Open browser and navigate to:
http://localhost:8080

# Or test via curl
curl http://localhost:8080

# Check container logs
docker logs zomato-local

# Verify health check
docker ps | grep zomato  # HEALTHCHECK column
```

### Step 5: Verify Features
- ✅ Homepage loads
- ✅ All images display correctly
- ✅ CSS styling applied
- ✅ No console errors
- ✅ Links work properly
- ✅ Responsive on mobile/tablet/desktop

### Step 6: Stop Container
```bash
# Using docker-compose
docker-compose down

# OR using docker run
docker stop zomato-local
docker rm zomato-local
```

---

## Part 2: Push to DockerHub

### Prerequisites
- DockerHub account (free at https://hub.docker.com)
- Docker CLI configured
- Image already built locally

### Step 1: Create DockerHub Repository

1. Go to https://hub.docker.com
2. Sign in with your account
3. Click **Repositories** → **Create repository**
4. Fill in:
   - **Name**: `zomato-clone`
   - **Description**: "Zomato clone UI with Jenkins CI/CD pipeline"
   - **Visibility**: Public
   - Click **Create**

### Step 2: Login to DockerHub via Docker CLI
```bash
# Login to DockerHub
docker login

# Enter your DockerHub username and password
# Or use a personal access token (recommended)
```

### Step 3: Tag Image for DockerHub
```bash
# Tag local image for DockerHub
docker tag zomato_clone:latest YOUR_USERNAME/zomato_clone:latest
docker tag zomato_clone:latest YOUR_USERNAME/zomato_clone:v1.0

# Verify tags
docker images | grep zomato_clone
```

**Example with actual username:**
```bash
docker tag zomato_clone:latest him1029g/zomato_clone:latest
docker tag zomato_clone:latest him1029g/zomato_clone:v1.0
```

### Step 4: Push to DockerHub
```bash
# Push image to DockerHub
docker push YOUR_USERNAME/zomato_clone:latest
docker push YOUR_USERNAME/zomato_clone:v1.0

# Track progress
# Layer 1: 100%
# Layer 2: 100%
# Digest: sha256:xxxxxxxxxxxxx
```

### Step 5: Verify on DockerHub
1. Visit: https://hub.docker.com/r/YOUR_USERNAME/zomato_clone
2. Check:
   - ✅ Image appears in repository
   - ✅ Tags listed (latest, v1.0)
   - ✅ Image size: ~25.42 MB
   - ✅ OS/Arch: linux/amd64
   - ✅ Pulls counter updated

### Step 6: Pull Image from DockerHub (Anywhere)
```bash
# Pull from DockerHub
docker pull YOUR_USERNAME/zomato_clone:latest

# Run on another machine
docker run -d -p 8080:80 YOUR_USERNAME/zomato_clone:latest
```

---

## Part 3: Deploy on AWS EC2

### Prerequisites
- AWS account with EC2 access
- EC2 instance running Ubuntu (t3.small or larger)
- Docker installed on EC2
- Security group allows port 8080

### Step 1: Connect to EC2 Instance
```bash
# SSH into EC2 (from your local machine)
ssh -i your-key.pem ubuntu@EC2_PUBLIC_IP

# Example:
ssh -i zomato-key.pem ubuntu@16.16.124.83
```

### Step 2: Install Docker on EC2 (if not already installed)
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install docker.io -y

# Install Docker Compose
sudo apt install docker-compose -y

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Verify installation
docker --version
docker-compose --version
```

### Step 3: Clone Repository on EC2
```bash
# Navigate to home directory
cd ~

# Clone repository
git clone https://github.com/himanshu1029g/Zomato-Clone.git

# Navigate to project
cd Zomato-Clone
```

### Step 4: Create docker-compose.yml on EC2
```bash
# The file already exists, just verify
cat docker-compose.yml
```

### Step 5: Pull and Run Image from DockerHub
```bash
# Pull latest image from DockerHub
docker pull YOUR_USERNAME/zomato_clone:latest

# Or run directly (pulls automatically)
docker-compose up -d

# Verify container is running
docker-compose ps

# Check logs
docker-compose logs web
```

### Step 6: Access Application on EC2
```bash
# From your local machine, open browser:
http://EC2_PUBLIC_IP:8080

# Example:
http://16.16.124.83:8080
```

### Step 7: Configure Auto-Restart (Optional)
```bash
# Enable container restart on EC2 reboot
docker update --restart=unless-stopped zomato-app

# Verify
docker inspect zomato-app | grep RestartPolicy
```

---

## Part 4: Jenkins CI/CD Pipeline Deployment

### How It Works

```
1. Code Push to GitHub (main branch)
        ↓
2. GitHub sends webhook to Jenkins
        ↓
3. Jenkins Pipeline Triggered Automatically
        ↓
4. Stage 1: Clone code from GitHub
            ↓
5. Stage 2: Build Docker image
            ↓
6. Stage 3: Test & validate image
            ↓
7. Stage 4: Push to DockerHub
            ↓
8. Stage 5: Deploy via Docker Compose on EC2
            ↓
9. Application Live ✅
```

### Jenkins Setup (See JENKINS_CI-CD.md for details)

1. Create Jenkins job from Jenkinsfile
2. Configure GitHub webhook
3. Add DockerHub credentials (ID: `dockerhubcred`)
4. Test pipeline with "Build Now"
5. Setup automatic triggers

### Trigger Deployment
```bash
# Simply push code to GitHub main branch
git add .
git commit -m "Fix: update homepage layout"
git push origin main

# Jenkins automatically:
# - Detects push via webhook
# - Builds Docker image
# - Pushes to DockerHub
# - Deploys to EC2
# - App is live in ~8-10 seconds!
```

---

## Monitoring & Maintenance

### Check Application Status
```bash
# On EC2, check container status
docker-compose ps

# View container logs
docker-compose logs --tail=100 web

# Real-time logs
docker-compose logs -f web
```

### Update Application

**Option 1: Pull latest from DockerHub**
```bash
docker-compose pull
docker-compose up -d
```

**Option 2: Push code to GitHub** (Auto-deploy via Jenkins)
```bash
git push origin main
# Jenkins pipeline runs automatically
```

### Backup Application Data
```bash
# Docker doesn't store persistent data in this project,
# but you can backup source code:
tar -czf zomato-backup-$(date +%Y%m%d).tar.gz ~/Zomato-Clone/
```

### Stop Application
```bash
# Stop containers gracefully
docker-compose down

# Remove containers and images
docker-compose down --rmi all
```

---

## Performance Optimization

### Memory Usage (In Production)
```bash
# Set memory limits in docker-compose.yml
services:
  web:
    deploy:
      resources:
        limits:
          memory: 512M
```

### Enable Gzip Compression
✅ Already configured in nginx.conf
- Reduces response size by 70-80%
- Transparent to browser
- Automatic compression

### Cache Static Assets
✅ Already configured
- 7-day cache for images, CSS, JS
- Reduces bandwidth usage
- Improves page load time

### Health Checks
✅ Already enabled
- Checks every 30 seconds
- Automatically restarts on failure
- Prevents zombie containers

---

## Troubleshooting Deployment

| Issue | Cause | Solution |
|-------|-------|----------|
| **Port 8080 in use** | Another service running | `lsof -i :8080` then kill process |
| **Container won't start** | Image pull failed | `docker pull USERNAME/zomato_clone` manually |
| **Connection refused** | Nginx not responding | `docker logs zomato-app` check errors |
| **Out of disk space** | Too many images | `docker system prune -a` |
| **High memory usage** | No limits set | Add resource limits in docker-compose.yml |
| **Slow performance** | Gzip disabled | Verify nginx.conf has gzip on |
| **Cannot access from outside** | Security group blocked | Allow port 8080 in AWS security group |

### Debug Commands
```bash
# Check everything
docker-compose ps
docker-compose logs web
docker stats

# Test connectivity
curl http://localhost:8080
curl http://EC2_IP:8080

# Inspect image
docker inspect YOUR_USERNAME/zomato_clone:latest

# Verify configuration
docker-compose config
```

---

## Production Checklist

- [ ] Image tested locally with docker-compose
- [ ] Image pushed to DockerHub successfully
- [ ] EC2 instance has Docker installed
- [ ] Security group allows port 8080
- [ ] Jenkins pipeline configured and tested
- [ ] GitHub webhook working
- [ ] Health checks enabled and passing
- [ ] Logs monitored for errors
- [ ] Backup strategy in place
- [ ] Application accessible from internet

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `docker build -t zomato_clone:latest .` | Build locally |
| `docker-compose up -d` | Start container |
| `docker-compose down` | Stop container |
| `docker push USERNAME/zomato_clone:latest` | Push to DockerHub |
| `docker pull USERNAME/zomato_clone:latest` | Pull from DockerHub |
| `docker-compose logs -f web` | View live logs |
| `docker stats` | Monitor resources |
| `docker-compose ps` | Check status |

---

## Next Steps

1. ✅ Setup local Docker environment
2. ✅ Build and test image locally
3. ✅ Push to DockerHub
4. ✅ Setup EC2 instance
5. ✅ Deploy on EC2
6. ✅ Configure Jenkins pipeline
7. ✅ Setup GitHub webhook
8. ✅ Monitor and maintain

---

## Need Help?

- Check [README.md](../README.md) for overview
- See [JENKINS_CI-CD.md](./JENKINS_CI-CD.md) for pipeline details
- Review [SETUP_CHECKLIST.md](./SETUP_CHECKLIST.md) for step-by-step guide
- Check [DOCKER_SETUP.md](./DOCKER_SETUP.md) for quick Docker start
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
