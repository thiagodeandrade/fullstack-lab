#!/bin/bash

# Update and install required packages
apt-get update -y
apt-get install --fix-broken -y
apt-get install -y openjdk-11-jre-headless nginx unzip curl

# Download and extract JMeter
curl -L https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.5.zip -o jmeter.zip
unzip jmeter.zip
mv apache-jmeter-5.5 /opt/jmeter

# Extrai apenas o IP da variável app_server_ip
clean_ip=$(echo "${app_server_ip}" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
echo "${{clean_ip}}"

# Cria um script separado para esperar o HTTP 200 e executar o JMeter
cat <<'WAIT_EOF' > /root/run_app.sh
#!/bin/bash
clean_ip="$1"
# Wait for HTTP 200
while true; do
  code=$(curl -s -o /dev/null -w '%{http_code}' "http://$clean_ip")
  echo "Waiting app-server ($clean_ip) - HTTP response: $code"
  if [ "$code" = "200" ]; then
    break
  fi
  sleep 5
done
# Run JMeter
/opt/jmeter/bin/jmeter -n -t /opt/jmeter/loadtest/load-test.jmx -Jserver_url=http://$clean_ip -l /opt/jmeter/report/result.jtl -e -o /opt/jmeter/report
WAIT_EOF

chmod +x /root/run_app.sh
/root/run_app.sh "${{clean_ip}}"

# Configuração do JMeter
cat <<EOF > /root/load-test.jmx
${load_test_jmx}
EOF

# Setup NGINX to serve the report
cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /opt/jmeter/report;
    index index.html;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Restart nginx
systemctl restart nginx

echo "✅ VARIÁVEL FUNCIONANDO: ${app_server_ip}"