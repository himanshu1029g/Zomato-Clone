# 🔧 Docker Quick Start Guide - Zomato Clone

## Prerequisites ✅
- Docker installed ([Download](https://www.docker.com/products/docker-desktop))
- Docker Compose v3.8+
- 2GB free disk space

---

## Quick Start (3 Steps)

### 1️⃣ Build Docker Image
```bash
cd d:\Projects\Zomato_Clone
docker build -t zomato-clone:latest .
```

### 2️⃣ Run Container
```bash
# Using Docker Compose (Recommended)
docker-compose up -d

# OR Using Docker directly
docker run -d --name zomato -p 8080:80 zomato-clone:latest
```

### 3️⃣ Access Application
```
Open browser: http://localhost:8080
```

---

## Useful Commands

| Command | Description |
|---------|-------------|
| `docker-compose up -d` | Start container |
| `docker-compose down` | Stop container |
| `docker logs zomato-local` | View logs |
| `docker ps` | List running containers |
| `docker images` | List images |
| `docker exec -it zomato-local bash` | Access container shell |

---

## Environment Variables

Create `.env` file:
```bash
NODE_ENV=production
APP_NAME=zomato-clone
APP_PORT=8080
```

---

## What's Inside? 📦

- **Base Image**: `nginx:alpine` (lightweight web server)
- **Port**: 80 (mapped to 8080)
- **Health Check**: Enabled
- **Compression**: gzip enabled
- **Cache**: 7-day for static assets

---

**Need help?** See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed setup.
