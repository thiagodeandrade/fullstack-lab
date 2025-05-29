#!/bin/bash

# Update repository packages
apt-get update -y
apt-get install --fix-broken -y

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
cp index.html /var/www/app/

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

    location /prometheus/ {
        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/.htpasswd;
        proxy_pass http://localhost:9090/;
        proxy_set_header Host \$host;
    }

    location /metrics/ {
        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/.htpasswd;
        proxy_pass http://localhost:9100/;
        proxy_set_header Host \$host;
    }
}
EOF

apt install -y apache2-utils
htpasswd -cb /etc/nginx/.htpasswd admin lablab2025...
systemctl reload nginx


# Restart NGINX
systemctl restart nginx

# Instala o Node Exporter no app-server
useradd --no-create-home --shell /usr/sbin/nologin node_exporter

NODE_EXPORTER_VERSION="1.7.0"
cd /tmp
curl -LO https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
tar xvf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Cria o service systemd
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=default.target
EOF

# Inicia o serviço
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now node_exporter
