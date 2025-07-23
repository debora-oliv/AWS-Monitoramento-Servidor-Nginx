#!/bin/bash

apt-get update -y
apt-get upgrade -y

apt-get install -y git nginx
systemctl start nginx
systemctl enable nginx

git clone https://github.com/debora-oliv/AWS-Monitoramento-Servidor-Nginx.git /temp/site

cp -r /temp/site/html/* /var/www/html/

chown -R www-data:www-data /var/www/html
chmod -R 750 /var/www/html

cat > /etc/nginx-monitoramento-secrets.env <<'EOF'
DISCORD_WEBHOOK="LINK_DO_SEU_WEBHOOK"
NGINX_URL="http://localhost"
EOF

chown root:root /etc/nginx-monitoramento-secrets.env
chmod 600 /etc/nginx-monitoramento-secrets.env

cat > /usr/local/bin/nginx_monitoramento.sh <<'EOF'
#!/bin/bash

LOG_DIR="/var/log/"
LOG_FILE="$LOG_DIR/nginx-monitoramento.log"

mkdir -p "$LOG_DIR"

if curl -s -I "$NGINX_URL" | grep -q "200 OK"; then
    STATUS="Servidor Nginx ONLINE - $(date '+%d/%m %H:%M')"
    echo "$STATUS" >> "$LOG_FILE"
else
    STATUS="Servidor Nginx OFFLINE - $(date '+%d/%m %H:%M')"
    echo "$STATUS" >> "$LOG_FILE"
    curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"$STATUS\"}" "$DISCORD_WEBHOOK"

    systemctl restart nginx
    echo "Tentativa de reiniciar Nginx - $(date '+%d/%m %H:%M')" >> "$LOG_FILE"
    
    sleep 10
    if ! curl -s -I "$NGINX_URL" | grep -q "200 OK"; then
        curl -sS -H "Content-Type: application/json" -X POST \
            -d "{\"content\":\"$STATUS\"}" "$DISCORD_WEBHOOK" \
            || echo "[ERRO] Falha ao enviar para Discord - $(date '+%d/%m %H:%M')" >> "$LOG_FILE"
    fi
fi
EOF

chmod +x /usr/local/bin/nginx_monitoramento.sh

cat > /etc/systemd/system/nginx-monitoramento.service <<'EOF'
[Unit]
Description=Monitoramento do Servidor Nginx
After=nginx.service

[Service]
Type=simple
EnvironmentFile=/etc/nginx-monitoramento-secrets.env
ExecStart=/usr/local/bin/nginx_monitoramento.sh
Restart=always
RestartSec=30
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start nginx-monitoramento
systemctl enable nginx-monitoramento
systemctl restart nginx
