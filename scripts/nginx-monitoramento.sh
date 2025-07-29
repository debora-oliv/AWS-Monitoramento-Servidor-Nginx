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
