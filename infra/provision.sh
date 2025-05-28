#!/bin/bash

# update and install nginx, curl
apt-get update -y
apt-get install -y nginx curl

# Install Node.js LTS
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Create environment app
mkdir -p /var/www/app
echo "<h1>Deploy funcionando!</h1>" > /var/www/app/index.html

# Configuring NGINX
cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/app;
    index index.html index.htm;

    server_name fullstack-lab;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Restart NGINX
systemctl restart nginx