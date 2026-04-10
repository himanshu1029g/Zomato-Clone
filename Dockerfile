# Use an official Nginx image as a base
FROM nginx:alpine

# Copy static HTML and CSS files to Nginx's default location
COPY ./html /usr/share/nginx/html

# Expose port 80 to allow traffic
EXPOSE 80

# Command to run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
