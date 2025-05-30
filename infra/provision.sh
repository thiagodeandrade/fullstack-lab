#!/bin/bash

# Update repository packages
apt-get update -y
apt-get install --fix-broken -y

# Install nginx, nodejs, and git
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs nginx git apache2-utils

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

# Configure NGINX (com /prometheus/ e /metrics/)
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
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_http_version 1.1;

        sub_filter_once off;
        sub_filter 'href="/' 'href="/prometheus/';
        sub_filter 'src="/' 'src="/prometheus/';
        sub_filter 'action="/' 'action="/prometheus/';
        proxy_set_header Accept-Encoding "";
        add_header Content-Security-Policy "default-src 'self' 'unsafe-inline'";
    }

    location /metrics/ {
        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/.htpasswd;
        proxy_pass http://localhost:9100/;
        proxy_set_header Host \$host;
    }
}
EOF

# Setup Basic Auth for Prometheus and Metrics
htpasswd -cb /etc/nginx/.htpasswd admin lablab2025...

# Reinicia NGINX
systemctl reload nginx

# Instala Node Exporter
useradd --no-create-home --shell /usr/sbin/nologin node_exporter

NODE_EXPORTER_VERSION="1.7.0"
cd /tmp
curl -LO https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
tar xvf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter

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

# Instala Prometheus
PROM_VERSION="2.52.0"
cd /tmp
curl -LO https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz
tar xvf prometheus-${PROM_VERSION}.linux-amd64.tar.gz
mv prometheus-${PROM_VERSION}.linux-amd64 /opt/prometheus

cat <<EOF > /opt/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
EOF

external_ip=$(curl -s ifconfig.me)

cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/opt/prometheus/prometheus \\
  --config.file=/opt/prometheus/prometheus.yml \\
  --web.listen-address=":9090" \\
  --web.external-url="http://${external_ip}/prometheus/"
Restart=always

[Install]
WantedBy=default.target
EOF

# Start both services
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now node_exporter
systemctl enable --now prometheus