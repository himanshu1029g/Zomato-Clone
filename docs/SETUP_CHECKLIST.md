# ✅ Setup Checklist - Zomato Clone Docker & Jenkins Deployment

## 🏁 Pre-Deployment Checklist

### Phase 1️⃣: Local Setup (Windows)

- [ ] **Docker Desktop installed**
  - Download: https://www.docker.com/products/docker-desktop
  - Verify: `docker --version`

- [ ] **Copy images to src directory**
  ```bash
  mkdir src\image
  copy image\* src\image\
  ```

- [ ] **Build Docker image locally**
  ```bash
  docker build -t zomato-clone:latest .
  ```

- [ ] **Test with Docker Compose**
  ```bash
  docker-compose up -d
  # Open: http://localhost:8080
  docker-compose down
  ```

### Phase 2️⃣: AWS Setup (For Production)

- [ ] **Create AWS Account** (if needed)

- [ ] **Create ECR Repository**
  ```bash
  aws ecr create-repository --repository-name zomato-clone --region us-east-1
  ```

- [ ] **Note ECR URL**
  - Format: `YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com`
  - Save this for later

- [ ] **Test ECR Login**
  ```bash
  aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ECR_URL
  ```

### Phase 3️⃣: Push to ECR

- [ ] **Tag Docker image**
  ```bash
  docker tag zomato-clone:latest YOUR_ECR_URL/zomato-clone:latest
  ```

- [ ] **Push to ECR**
  ```bash
  docker push YOUR_ECR_URL/zomato-clone:latest
  ```

- [ ] **Verify in AWS Console**
  - Go to ECR → Repositories → zomato-clone
  - Confirm image appears

### Phase 4️⃣: Jenkins Setup

- [ ] **Have Jenkins Server Ready**
  - URL: `http://your-jenkins-url:8080`
  - Admin access

- [ ] **Install Required Plugins**
  - Docker Pipeline
  - Amazon ECR
  - GitHub
  - AWS Steps

- [ ] **Add Jenkins Credentials**
  - [ ] AWS credentials (ID: `aws-creds`)
  - [ ] GitHub token (ID: `github-token`)
  - [ ] AWS Account ID (ID: `aws-account-id`)

- [ ] **Create Jenkins Job**
  - Type: Pipeline
  - Name: `zomato-clone-pipeline`
  - SCM: Git
  - Repository: `https://github.com/YOUR_GITHUB/zomato-clone.git`
  - Script Path: `Jenkinsfile`

- [ ] **Configure GitHub Webhook**
  - GitHub → Settings → Webhooks → Add Webhook
  - Payload URL: `http://jenkins-url:8080/github-webhook/`
  - Select: Push events
  - Active: ✓

- [ ] **Test Jenkins Pipeline**
  - Click "Build Now"
  - Monitor Console Output
  - Verify all stages pass

### Phase 5️⃣: AWS ECS Setup (For Auto-Deployment)

- [ ] **Create ECS Cluster**
  ```bash
  aws ecs create-cluster --cluster-name zomato-cluster
  ```

- [ ] **Create Task Definition**
  - Memory: 512 MB
  - CPU: 256
  - Image: `YOUR_ECR_URL/zomato-clone:latest`
  - Port: 80

- [ ] **Create ECS Service**
  - Cluster: `zomato-cluster`
  - Service: `zomato-service`
  - Desired Count: 2 (for HA)
  - Launch Type: FARGATE

- [ ] **Configure Load Balancer**
  - Type: Application Load Balancer
  - Port: 80
  - Target: ECS service

### Phase 6️⃣: Verify Deployment

- [ ] **Check Container Status**
  ```bash
  docker ps  # Local
  aws ecs list-tasks --cluster zomato-cluster  # AWS
  ```

- [ ] **Test Application**
  - Local: `http://localhost:8080`
  - AWS: `http://load-balancer-url`

- [ ] **Check Logs**
  - Local: `docker logs zomato-local`
  - AWS: `aws logs tail /ecs/zomato --follow`

- [ ] **Monitor Jenkins Build**
  - Jenkins Dashboard → Job → Build #X → Console Output

---

## 📋 Important Credentials to Save

| Item | Value | Location |
|------|-------|----------|
| AWS Account ID | `123456789012` | AWS Console |
| ECR Repository URL | `123456789012.dkr.ecr.us-east-1.amazonaws.com` | AWS ECR |
| Jenkins URL | `http://your-jenkins:8080` | Jenkins Server |
| GitHub Repo | `your-github/zomato-clone` | GitHub |
| Load Balancer URL | `zomato-lb-123.us-east-1.elb.amazonaws.com` | AWS |

---

## 🚀 Auto-Deployment Workflow

Once everything is set up:

1. **Make code changes locally**
   ```bash
   git add .
   git commit -m "Update feature"
   git push origin main
   ```

2. **GitHub sends webhook to Jenkins**

3. **Jenkins automatically:**
   - Pulls latest code
   - Builds Docker image
   - Pushes to ECR
   - Updates ECS service
   - Deploys new version

4. **Application is live on AWS**

---

## 🆘 Quick Troubleshooting

### Docker Issues
```bash
# Clean up
docker system prune -a

# Rebuild
docker build --no-cache -t zomato-clone:latest .

# Check logs
docker logs zomato-local
```

### AWS Issues
```bash
# Verify ECR login
aws ecr get-login-password --region us-east-1

# Check ECS service
aws ecs describe-services --cluster zomato-cluster --services zomato-service

# View CloudWatch logs
aws logs tail /ecs/zomato --follow
```

### Jenkins Issues
- Check Console Output (Jenkins Dashboard → Job → Build → Console)
- Verify credentials (Jenkins → Credentials → Global)
- Check plugin versions (Jenkins → Manage Plugins)

---

## 📚 Documentation Files

| File | Content |
|------|---------|
| [DEPLOYMENT.md](docs/DEPLOYMENT.md) | **FULL GUIDE** - Read this first! |
| [DOCKER_SETUP.md](docs/DOCKER_SETUP.md) | Docker commands reference |
| [JENKINS_CI-CD.md](docs/JENKINS_CI-CD.md) | Jenkins pipeline details |

---

## ✨ Summary

**After completing this checklist:**

✅ Docker image ready for production
✅ Automated CI/CD pipeline working
✅ One-click deployment to AWS
✅ Application auto-updates on code push

**Estimated Time:** 2-3 hours for first-time setup

---

**Last Updated**: 2024
**Status**: Ready to Deploy 🚀
