
# ==========================================
# Zomato Clone - Multi-Stage Docker Build
# ==========================================
# Stage 1: Builder (Node.js Alpine)
# Used for compiling/building if needed
# Size: ~400MB (not included in final image)

FROM node:18-alpine AS builder

WORKDIR /app

# For future Node.js builds (currently static HTML/CSS)
# Uncomment below if you add npm dependencies:
# COPY package*.json ./
# RUN npm ci --only=production

# ==========================================
# Stage 2: Runtime (Nginx Alpine)
# Final production image
# Size: ~40MB (highly optimized)
# ==========================================

FROM nginx:alpine

# Metadata
LABEL maintainer="Himanshu Gupta"
LABEL description="Zomato Clone - Production Container"
LABEL version="3.0"

# Remove default nginx config (avoid conflicts)
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration
# Includes: gzip compression, security headers, caching, SSL-ready config
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Copy static application files to nginx document root
# From: src/ (local HTML, CSS, images)
# To: /usr/share/nginx/html/ (nginx default serving path)
COPY src/ /usr/share/nginx/html/

# Expose container port 80 (HTTP)
# Will be mapped to host port 8080 via docker run -p 8080:80
EXPOSE 80

# Health check configuration
# Ensures container is healthy before serving traffic
# - Interval: Check every 30 seconds
# - Timeout: 3 seconds to respond
# - Start Period: Wait 5 seconds before first check
# - Retries: Mark unhealthy after 3 failed checks
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Default command to start nginx in foreground mode
# -g "daemon off;" keeps nginx running (not as background service)
CMD ["nginx", "-g", "daemon off;"]

