#!/bin/bash

# Update and install required packages
apt-get update -y
apt-get install --fix-broken -y
apt-get install -y openjdk-11-jre-headless nginx unzip curl

# Download and extract JMeter
curl -L https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.5.zip -o jmeter.zip
unzip jmeter.zip
mv apache-jmeter-5.5 /opt/jmeter

# Extract the clean ip
clean_ip=$(echo "${app_server_ip}" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')

echo "----"
echo $clean_ip
echo "----"
# Create jmx file from terraform template
cat <<'EOF' > /root/load-test.jmx
${load_test_jmx}
EOF

# Script to wait for application server to be up and run jmeter tests
cat <<'WAIT_EOF' > /root/run_app.sh
#!/bin/bash
clean_ip="$1"
while true; do
  code=$(curl -s -o /dev/null -w '%%{http_code}' "http://$clean_ip")
  echo "Waiting app-server ($clean_ip) - HTTP response: $code"
  if [ "$code" = "200" ]; then
    break
  fi
  sleep 5
done
/opt/jmeter/bin/jmeter -n -t /root/load-test.jmx -Jserver_url=http://$clean_ip -Jjmeter.save.saveservice.output_format=csv -Jjmeter.save.saveservice.successful=true -Jjmeter.save.saveservice.label=true -Jjmeter.save.saveservice.response_code=true -Jjmeter.save.saveservice.response_message=true -l /opt/jmeter/report/result.jtl -j /opt/jmeter/report/jmeter.log && rm -rf /opt/jmeter/report/html && /opt/jmeter/bin/jmeter -g /opt/jmeter/report/result.jtl -o /opt/jmeter/report/html -Jjmeter.save.saveservice.output_format=csv -Jjmeter.reportgenerator.overall_filter="^GET /$"
WAIT_EOF

chmod +x /root/run_app.sh
/root/run_app.sh "$clean_ip"

# AppServer with the nodejs example
cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /opt/jmeter/report/html;
    index index.html;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

systemctl restart nginx
echo "Provisioning finalizado - IP: ${app_server_ip}" | tee /var/log/jmeter.log
