# ✅ Setup Checklist - Zomato Clone Docker & Jenkins Deployment

Complete and track each phase of deployment using this checklist.

---

## 🏁 Pre-Deployment Checklist

### Phase 1️⃣: Local Development Setup

- [ ] **Docker Desktop installed**
  - Download: https://www.docker.com/products/docker-desktop
  - Command: `docker --version`
  - Should show: Docker version 20.10+

- [ ] **Docker Compose installed**
  - Command: `docker-compose --version`
  - Should show: Docker Compose version 1.29+

- [ ] **Git installed**
  - Command: `git --version`
  - Should show: git version 2.x+

- [ ] **Project cloned locally**
  ```bash
  git clone https://github.com/himanshu1029g/Zomato-Clone.git
  cd Zomato-Clone
  ls  # Verify files exist
  ```

- [ ] **All source files present**
  - [ ] src/index.html ✓
  - [ ] src/just.html ✓
  - [ ] src/style.css ✓
  - [ ] nginx/nginx.conf ✓
  - [ ] Dockerfile ✓
  - [ ] docker-compose.yml ✓
  - [ ] Jenkinsfile ✓

---

### Phase 2️⃣: Local Docker Testing

- [ ] **Build Docker image locally**
  ```bash
  docker build -t zomato_clone:latest .
  # Takes ~2-3 minutes first time
  docker images | grep zomato_clone
  ```

- [ ] **Verify image built successfully**
  - [ ] Image size: ~40MB ✓
  - [ ] Image tag: zomato_clone:latest ✓
  - [ ] Base image: nginx:alpine ✓

- [ ] **Test with Docker run**
  ```bash
  docker run -d -p 8080:80 --name zomato-test zomato_clone:latest
  # Wait 5 seconds
  curl http://localhost:8080
  # Should return HTML
  docker stop zomato-test
  docker rm zomato-test
  ```

- [ ] **Test with Docker Compose**
  ```bash
  docker-compose up -d
  # Wait 5 seconds
  curl http://localhost:8080
  # Should return HTML
  docker-compose ps  # Should show container running
  docker-compose logs web  # Check for errors
  docker-compose down
  ```

- [ ] **Verify application in browser**
  - [ ] Navigate to http://localhost:8080
  - [ ] Homepage loads ✓
  - [ ] All images display ✓
  - [ ] CSS styling applied ✓
  - [ ] No 404 errors ✓
  - [ ] Health check passes ✓

---

### Phase 3️⃣: DockerHub Setup

- [ ] **Create DockerHub Account** (if not existing)
  - Go to: https://hub.docker.com/signup
  - Verify email
  - Save username and password

- [ ] **Create Personal Access Token** (recommended instead of password)
  - DockerHub Profile → Settings → Security → Access Tokens
  - Click "New Access Token"
  - Name: `jenkins-deployment`
  - Permissions: Read, Write, Delete
  - Copy token (save securely)

- [ ] **Test DockerHub login locally**
  ```bash
  docker login
  # Enter username and token
  # Should show: Login Succeeded
  docker logout
  ```

- [ ] **Create DockerHub Repository**
  - Go to: https://hub.docker.com/repositories
  - Click "Create repository"
  - Name: `zomato-clone`
  - Visibility: Public
  - Description: "Zomato UI with Jenkins CI/CD"
  - Click "Create"

- [ ] **Save DockerHub information**
  - [ ] Username: ____________
  - [ ] Repository: `USERNAME/zomato-clone`
  - [ ] Full URL: `https://hub.docker.com/r/USERNAME/zomato-clone`
  - [ ] Access Token: ____________ (saved securely)

---

### Phase 4️⃣: Tag and Push to DockerHub

- [ ] **Tag Docker image for DockerHub**
  ```bash
  docker tag zomato_clone:latest USERNAME/zomato-clone:latest
  docker tag zomato_clone:latest USERNAME/zomato-clone:v1.0
  docker images | grep zomato-clone
  # Should show 3 images total
  ```

- [ ] **Login to DockerHub**
  ```bash
  docker login
  # Use username and token
  ```

- [ ] **Push image to DockerHub**
  ```bash
  docker push USERNAME/zomato-clone:latest
  docker push USERNAME/zomato-clone:v1.0
  # Wait for push to complete (might take 2-3 minutes)
  ```

- [ ] **Verify image on DockerHub**
  - Go to: https://hub.docker.com/r/USERNAME/zomato-clone
  - Check:
    - [ ] Repository exists ✓
    - [ ] Tags visible (latest, v1.0) ✓
    - [ ] Image size ~25.42 MB ✓
    - [ ] Compressed size shows ✓
    - [ ] Pushed date/time correct ✓

- [ ] **Test pull from DockerHub** (on different machine or clean setup)
  ```bash
  # Stop local container first
  docker-compose down
  docker image rm USERNAME/zomato-clone:latest
  
  # Now pull from DockerHub
  docker pull USERNAME/zomato-clone:latest
  docker run -d -p 9999:80 USERNAME/zomato-clone:latest
  curl http://localhost:9999
  # Should work!
  ```

---

### Phase 5️⃣: AWS EC2 Setup (For Production)

- [ ] **AWS Account ready**
  - [ ] Have AWS account (https://aws.amazon.com)
  - [ ] Can access EC2 console
  - [ ] Can create instances

- [ ] **Create EC2 Instance**
  - [ ] Instance type: t3.small or larger
  - [ ] OS: Ubuntu 20.04 LTS or newer
  - [ ] Security Group: Allow port 8080, 22 (SSH)
  - [ ] Key Pair: Created and saved (.pem file)
  - [ ] Public IP: Assigned

- [ ] **EC2 Instance Details Saved**
  - [ ] Instance ID: ____________
  - [ ] Public IP: ____________
  - [ ] Key file location: ____________
  - [ ] Security Group: ____________
  - [ ] Region: ____________

- [ ] **SSH into EC2**
  ```bash
  ssh -i your-key.pem ubuntu@YOUR_EC2_IP
  # Should connect successfully
  exit  # Exit SSH
  ```

- [ ] **Install Docker on EC2**
  ```bash
  ssh -i your-key.pem ubuntu@YOUR_EC2_IP
  sudo apt update && sudo apt upgrade -y
  sudo apt install docker.io docker-compose -y
  sudo usermod -aG docker ubuntu
  docker --version  # Verify
  exit
  ```

---

### Phase 6️⃣: Jenkins Setup (For CI/CD)

- [ ] **Jenkins Server Available**
  - [ ] Jenkins running (local or cloud)
  - [ ] Accessible at: http://your-jenkins:8080
  - [ ] Admin access available
  - [ ] Can access "Manage Jenkins"

- [ ] **Required Jenkins Plugins Installed**
  - [ ] Git plugin
  - [ ] Docker plugin (Docker Pipeline)
  - [ ] Pipeline: Stage View plugin
  - Command: Jenkins → Manage Jenkins → Manage Plugins

- [ ] **Docker installed on Jenkins Agent**
  - [ ] Jenkins agent has Docker installed
  - [ ] Docker available in agent's PATH
  - [ ] Jenkins user can run docker commands

- [ ] **Add DockerHub Credentials**
  - Jenkins → Manage Credentials → Global Credentials
  - Click "Add Credentials"
  - Type: Username with password
  - Username: Your DockerHub username
  - Password: Your DockerHub token
  - ID: `dockerhubcred` (must match Jenkinsfile)
  - Click "Create"
  - Verify in credentials list

- [ ] **Create Jenkins Pipeline Job**
  - Jenkins → New Item
  - Name: `Declarative Pipeline`
  - Type: Pipeline
  - Click OK
  - Pipeline Definition: Pipeline script from SCM
  - SCM: Git
  - Repository URL: `https://github.com/himanshu1029g/Zomato-Clone.git`
  - Branch: `*/main`
  - Script Path: `Jenkinsfile`
  - Click Save

---

### Phase 7️⃣: GitHub Webhook Configuration

- [ ] **Get Jenkins Webhook URL**
  - Format: `http://JENKINS_IP:8080/github-webhook/`
  - Example: `http://16.16.124.83:8080/github-webhook/`
  - Save this URL

- [ ] **Configure GitHub Webhook** (on your fork)
  - Go to: GitHub Repository → Settings → Webhooks
  - Click "Add webhook"
  - Payload URL: `http://JENKINS_IP:8080/github-webhook/`
  - Content type: `application/json`
  - Events: "Push events" (checked)
  - Active: ✓ (checked)
  - Click "Add webhook"

- [ ] **Verify Webhook** (after creating)
  - On Webhooks page, you should see new webhook
  - Click to expand and check "Recent Deliveries"
  - Most recent delivery should show green checkmark

---

### Phase 8️⃣: Test Jenkins Pipeline

- [ ] **Manual Build Test**
  - Jenkins → Job → "Build Now"
  - Monitor Console Output
  - Check each stage:
    - [ ] Code: Git clone ✓
    - [ ] Build: Docker build ✓
    - [ ] Test: Validation ✓
    - [ ] Push: DockerHub push ✓
    - [ ] Deploy: Docker Compose ✓
  - Total time: ~8-10 seconds
  - Status: SUCCESS ✓

- [ ] **Automated Trigger Test**
  - Make a small change to code
  - Git push to main: `git push origin main`
  - Jenkins should automatically start build
  - Monitor until complete
  - Verify job #2 or higher exists

- [ ] **Verify Deployment**
  - On EC2, check running container
  - ```bash
    ssh -i key.pem ubuntu@IP
    docker ps
    # Should show zomato-app running
    exit
    ```
  - Open browser: http://EC2_IP:8080
  - Should see Zomato homepage

---

### Phase 9️⃣: Production Verification

- [ ] **Application Accessibility**
  - [ ] Accessible from local machine
  - [ ] Accessible from AWS
  - [ ] Accessible from internet (if applicable)

- [ ] **Performance Verification**
  - [ ] Page loads < 2 seconds
  - [ ] All images display
  - [ ] CSS styling correct
  - [ ] Responsive design works
  - [ ] No console errors
  - [ ] No network errors

- [ ] **Health Check Status**
  - ```bash
    docker inspect zomato-app | grep -A 5 HealthStatus
    # Should show "healthy"
    ```

- [ ] **Container Logs Clear**
  - ```bash
    docker logs zomato-app
    # Should show normal startup messages
    # No ERROR or CRITICAL messages
    ```

- [ ] **Security Check**
  - [ ] HTTP headers configured (nginx.conf) ✓
  - [ ] Gzip compression enabled ✓
  - [ ] CSP headers present ✓
  - [ ] X-Frame-Options set ✓

---

### Phase 🔟: Documentation & Cleanup

- [ ] **Documentation Updated**
  - [ ] README.md complete ✓
  - [ ] DEPLOYMENT.md updated ✓
  - [ ] JENKINS_CI-CD.md updated ✓
  - [ ] CONTRIBUTING.md present ✓

- [ ] **GitHub Repository Ready**
  - [ ] Code pushed to main branch
  - [ ] README visible
  - [ ] All files checked in
  - [ ] No sensitive credentials in code
  - [ ] License file present

- [ ] **Credentials Secured**
  - [ ] Docker credentials not in code ✓
  - [ ] AWS keys not in code ✓
  - [ ] GitHub tokens not in code ✓
  - [ ] Only .env.example committed (not .env)

- [ ] **Backup Created**
  - [ ] Local backup of project
  - [ ] GitHub has remote backup
  - [ ] Jenkins config backed up

---

## 📋 Important Credentials Checklist

| Item | Value | Location | Status |
|------|-------|----------|--------|
| DockerHub Username | ____________ | .env | ✓ |
| DockerHub Token | ____________ | Jenkins Credentials | ✓ |
| GitHub Username | ____________ | GitHub | ✓ |
| EC2 Key File | ____________ | Local Machine | ✓ |
| EC2 Public IP | ____________ | AWS Console | ✓ |
| Jenkins URL | ____________ | Browser | ✓ |
| Jenkins Job URL | ____________ | Browser | ✓ |

---

## 🚀 Go-Live Workflow

Once everything is checked:

1. **Make final code changes** (optional)
2. **Git push to main branch**
3. **Jenkins builds automatically**
4. **Application deploys to EC2**
5. **Verify at http://EC2_IP:8080**
6. **Share link with others**
7. **Monitor logs for errors**

---

## 🆘 Troubleshooting Quick Reference

| Issue | Command | Solution |
|-------|---------|----------|
| Docker not running | `docker ps` | Start Docker Desktop |
| Container won't start | `docker logs CONTAINER_ID` | Check logs for errors |
| Port 8080 in use | `lsof -i :8080` | Kill process or change port |
| Image not pushing | `docker push IMAGE` | Check DockerHub login |
| Pipeline fails | Jenkins Console | Check build logs |
| EC2 not accessible | `ssh -i key.pem ubuntu@IP` | Check security group |
| No internet access | `ping 8.8.8.8` | Check network settings |

---

## ✨ Success Indicators

- [x] Docker image builds successfully locally
- [x] Image runs without errors
- [x] Image pushed to DockerHub
- [x] Jenkins pipeline executes all stages
- [x] Application accessible on EC2
- [x] GitHub webhooks trigger builds
- [x] Logs show no critical errors
- [x] Documentation complete

---

**Congratulations on deploying your Zomato Clone! 🎉**

For detailed guides, see:
- [DEPLOYMENT.md](./DEPLOYMENT.md) - Full deployment guide
- [DOCKER_SETUP.md](./DOCKER_SETUP.md) - Quick Docker setup
- [JENKINS_CI-CD.md](./JENKINS_CI-CD.md) - Jenkins pipeline guide

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
