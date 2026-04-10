# 🍜 Zomato Clone - Docker & Jenkins Deployment

**A fully containerized Zomato-like UI project with complete CI/CD pipeline ready for production deployment on AWS.**

---

## 📁 Project Structure

```
Zomato_Clone/
├── src/                          # Application source files
│   ├── index.html                # Main page
│   ├── just.html                 # Secondary page
│   ├── style.css                 # Styles
│   ├── image/                    # Assets
│   └── miantop.avif, miantop2.avif
├── nginx/
│   └── nginx.conf                # Web server config
├── docs/
│   ├── DEPLOYMENT.md             # Complete deployment guide
│   ├── DOCKER_SETUP.md           # Quick Docker setup
│   └── JENKINS_CI-CD.md          # Jenkins pipeline guide
├── Dockerfile                    # Docker image
├── Jenkinsfile                   # CI/CD pipeline
├── docker-compose.yml            # Local development
├── .dockerignore
├── .gitignore
└── README.md
```

## 🚀 Quick Start

### Local Development with Docker

```bash
# Build image
docker build -t zomato-clone:latest .

# Run container
docker-compose up -d

# Access application
open http://localhost:8080

# View logs
docker-compose logs -f

# Stop container
docker-compose down
```

### Deploy to AWS

```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ECR_URL

# Push image
docker tag zomato-clone:latest YOUR_ECR_URL/zomato-clone:latest
docker push YOUR_ECR_URL/zomato-clone:latest

# Deploy to ECS
aws ecs update-service --cluster zomato-cluster --service zomato-service --force-new-deployment
```

### CI/CD with Jenkins

1. Create Jenkins Pipeline job
2. Link GitHub repository
3. Configure with Jenkinsfile
4. Enable GitHub webhook
5. Push code → Auto-deploy

## 📚 Documentation

| Guide | Purpose |
|-------|---------|
| [DEPLOYMENT.md](docs/DEPLOYMENT.md) | **Step-by-step** deployment guide for Docker, AWS, Jenkins |
| [DOCKER_SETUP.md](docs/DOCKER_SETUP.md) | Quick Docker commands |
| [JENKINS_CI-CD.md](docs/JENKINS_CI-CD.md) | Jenkins pipeline setup |

## ✨ Features

- ✅ **Containerized** - Docker with Nginx
- ✅ **Production-Ready** - Security headers, health checks, gzip
- ✅ **CI/CD Pipeline** - Automated Jenkins deployment
- ✅ **AWS Ready** - ECR, ECS, EC2 compatible
- ✅ **Auto-Deploy** - GitHub webhook integration
- ✅ **Monitoring** - Logs, health checks enabled

## 🐳 Docker

- **Base**: nginx:alpine (~40MB)
- **Stages**: Multi-stage build optimization
- **Port**: 80 (mapped to 8080)
- **Features**: Compression, caching, security headers

## 🔄 CI/CD Pipeline

```
GitHub Push → Webhook → Jenkins Build → Docker Build → ECR Push → ECS Deploy
```

**Stages:**
1. Checkout code
2. Build Docker image
3. Run health checks
4. Login to AWS ECR
5. Push to registry
6. Deploy to ECS
7. Verify deployment

## ☁️ Cloud Deployment

**Supported:**
- AWS ECS (containers)
- AWS EC2 + Docker Compose
- AWS ECR (registry)
- Docker Hub

## 🔧 Tech Stack

- **Frontend**: HTML5, CSS3
- **Server**: Nginx (Alpine)
- **Container**: Docker, Docker Compose
- **CI/CD**: Jenkins
- **Cloud**: AWS

## 📋 Prerequisites

### Local Development
- Docker Desktop installed
- Git installed

### AWS Deployment
- AWS Account
- IAM user (ECR/ECS permissions)
- AWS CLI configured

### Jenkins
- Jenkins 2.300+
- Docker support
- AWS credentials

## ⚡ Key Steps Overview

### 1. Prepare Environment
```bash
# Copy images to src directory
mkdir src/image
cp image/* src/image/
```

### 2. Local Testing
```bash
docker-compose up -d
# Test at http://localhost:8080
docker-compose down
```

### 3. Push to Registry
```bash
docker build -t zomato-clone:latest .
docker tag zomato-clone:latest YOUR_ECR_URL/zomato-clone:latest
docker push YOUR_ECR_URL/zomato-clone:latest
```

### 4. Setup Jenkins
- Create Pipeline job
- Add GitHub webhook
- Configure AWS credentials
- Deploy on push

### 5. Deploy on AWS
- Create ECS cluster/service
- Configure load balancer
- Monitor with CloudWatch

## 📖 Full Deployment Steps

**For complete step-by-step instructions, see [DEPLOYMENT.md](docs/DEPLOYMENT.md)**

Key sections:
- Docker local setup
- Registry push (DockerHub/ECR)
- Jenkins pipeline configuration
- AWS ECS/EC2 deployment
- Monitoring & troubleshooting

## 🔐 Security

✅ Non-root Docker user
✅ Security headers (X-Frame-Options, etc.)
✅ Health checks enabled
✅ AWS IAM roles
✅ HTTPS ready

## 📊 Monitoring

- **Logs**: `docker logs container-name`
- **CloudWatch**: `aws logs tail /ecs/zomato --follow`
- **Jenkins**: Dashboard → Job → Console

## 🛠️ Troubleshooting

| Issue | Solution |
|-------|----------|
| Port in use | Change port in docker-compose.yml |
| Build fails | Check Dockerfile, ensure files in src/ |
| ECR push fails | Verify AWS credentials, IAM permissions |
| Pipeline fails | Check Jenkins console, GitHub token |

## 📝 Original Features

- Clean, responsive layout for restaurants
- Image-based cards and headers
- Demo navigation pages
- Modern CSS styling

## 🎯 Now With DevOps!

- ✅ Containerized
- ✅ Production deployment
- ✅ Automated CI/CD
- ✅ Cloud-ready
- ✅ Enterprise scalable

---

**Last Updated**: 2024 | **Version**: 2.0 (With Docker & Jenkins)
**Status**: ✅ Ready for Production Deployment
