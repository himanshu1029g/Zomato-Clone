
# Multi-stage build for Zomato Clone
FROM node:18-alpine AS builder

WORKDIR /app

# For static sites, we can skip npm build
# If you add Node.js later, uncomment below:
# COPY package*.json ./
# RUN npm install

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx config
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Copy static files
COPY src/ /usr/share/nginx/html/

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1



CMD ["nginx", "-g", "daemon off;"]
