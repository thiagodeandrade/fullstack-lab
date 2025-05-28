#!/bin/bash

# Update repository packages
apt-get update -y

# Install nginx, nodejs, and git
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs nginx git

# Clone your project
git clone https://github.com/thiagodeandrade/fullstack-lab.git /opt/app

# Install dependencies and build app
cd /opt/app
npm install
npm run build

# Create app directory and move built files
mkdir -p /var/www/app
cp -r build/* /var/www/app/

# Configuring NGINX
cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/app;
    index index.html;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Restart NGINX
systemctl restart nginx