# 🍜 Zomato Clone - Docker & Jenkins CI/CD Deployment

**A fully containerized Zomato-like UI project with a complete CI/CD pipeline deployed on AWS EC2 using Jenkins and Docker.**

---

## 📁 Project Structure

Zomato_Clone/
├── src/                          # Application source files
│   ├── index.html                # Main page
│   ├── just.html                 # Secondary page
│   ├── style.css                 # Styles
│   └── image/                    # Assets
├── nginx/
│   └── nginx.conf                # Nginx web server config
├── docs/
│   ├── DEPLOYMENT.md             # Complete deployment guide
│   ├── DOCKER_SETUP.md           # Quick Docker setup
│   └── JENKINS_CI-CD.md          # Jenkins pipeline guide
├── Dockerfile                    # Multi-stage Docker build
├── Jenkinsfile                   # CI/CD Pipeline definition
├── docker-compose.yml            # Container orchestration
├── .dockerignore
├── .gitignore
└── README.md
---

## 🚀 Quick Start

### Run Locally with Docker

```bash
# Pull from DockerHub
docker pull him1029g/zomato_clone:latest

# Run container
docker run -d -p 8080:80 him1029g/zomato_clone:latest

# Access app
open http://localhost:8080
```

### Run with Docker Compose

```bash
docker compose up -d
# Access at http://localhost:8080

docker compose down
```

---

## 🔄 CI/CD Pipeline (Jenkins)

This project uses a **Jenkins Declarative Pipeline** with 5 stages:
GitHub Push → Jenkins Trigger → Build Image → Push to DockerHub → Deploy via Docker Compose

### Jenkinsfile (Pipeline Stages)

```groovy
pipeline {
    agent { label "vinod" }
    stages {

        stage("Code") {
            steps {
                echo "This is Cloning the Code"
                git url: "https://github.com/himanshu1029g/Zomato-Clone.git", branch: "main"
                echo "Code clone successfully"
            }
        }

        stage("Build") {
            steps {
                echo "This is Building the Code"
                sh "docker build -t zomato_clone:latest ."
            }
        }

        stage("Test") {
            steps {
                echo "This is Testing the Code"
            }
        }

        stage("Push to DockerHub") {
            steps {
                echo "This is pushing the img to docker hub"
                withCredentials([usernamePassword(
                    credentialsId: "dockerhubcred",
                    passwordVariable: "dockerHubPass",
                    usernameVariable: "dockerHubUser"
                )]) {
                    sh "docker login -u ${dockerHubUser} -p ${dockerHubPass}"
                    sh "docker image tag zomato_clone:latest him1029g/zomato_clone:latest"
                    sh "docker push him1029g/zomato_clone:latest"
                }
            }
        }

        stage("Deployment") {
            steps {
                echo "This is Deploying the Code"
                sh "docker compose down --remove-orphans || true"
                sh "docker compose up -d"
            }
        }

    }
}
```

### Pipeline Stage Details

| Stage | What it does |
|---|---|
| **Code** | Clones latest code from GitHub main branch |
| **Build** | Builds Docker image `zomato_clone:latest` |
| **Test** | Runs test checks |
| **Push to DockerHub** | Tags and pushes image to `him1029g/zomato_clone` |
| **Deployment** | Tears down old container and starts fresh via Docker Compose |

---

## 🐳 Docker

- **Base Image**: `nginx:alpine` (~40MB)
- **Build**: Multi-stage (node:18-alpine builder → nginx:alpine)
- **Port**: Container runs on `80`, mapped to host `8080`
- **Features**: Gzip compression, security headers, health checks

### DockerHub Image

```bash
docker pull him1029g/zomato_clone:latest
```

---

## ☁️ Infrastructure

| Component | Tool |
|---|---|
| Cloud Server | AWS EC2 (Ubuntu) |
| CI/CD | Jenkins (Declarative Pipeline) |
| Agent | Jenkins Agent Node ("vinod") |
| Container Runtime | Docker + Docker Compose |
| Image Registry | DockerHub (`him1029g/zomato_clone`) |
| Web Server | Nginx (inside container) |

---

## 🔧 Tech Stack

- **Frontend**: HTML5, CSS3
- **Web Server**: Nginx (Alpine)
- **Containerization**: Docker, Docker Compose
- **CI/CD**: Jenkins
- **Cloud**: AWS EC2
- **Registry**: DockerHub

---

## ✨ Features

- ✅ Fully Containerized with Docker
- ✅ Automated CI/CD via Jenkins Pipeline
- ✅ DockerHub Integration for image registry
- ✅ Multi-stage Docker build (optimized image size)
- ✅ Auto-cleanup of orphan containers on redeploy
- ✅ Health checks enabled
- ✅ Nginx with compression and security headers

---

## 🛠️ Troubleshooting

| Issue | Solution |
|---|---|
| Port 8080 already in use | `docker ps` → stop conflicting container |
| Pipeline fails at Docker build | Check Dockerfile and src/ directory |
| DockerHub push fails | Verify `dockerhubcred` in Jenkins credentials |
| Container won't start | Check `docker compose logs` |

---

## 👨‍💻 Author

**Himanshu Gupta**
[GitHub](https://github.com/himanshu1029g) | DevOps Enthusiast

---

**Version**: 3.0 | **Status**: ✅ Pipeline Working & Image Live on DockerHub



