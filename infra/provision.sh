#!/bin/bash

# update repository packages
apt-get update -y

# Install nginx and nodejs
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs nginx

# Create custom index
mkdir -p /var/www/app
echo "<h1>Deploy to Fullstack LAB!</h1>" > /var/www/app/index.html

# Configuring o NGINX
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