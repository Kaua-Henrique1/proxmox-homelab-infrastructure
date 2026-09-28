#!/bin/bash

# Script: tailscale-autostart.sh
# Descrição: Garante a conexão e persistência do Tailscale no boot do Proxmox

set -e

echo "[*] Aguardando estabilização da interface de rede física..."
sleep 10

echo "[*] Verificando status do Tailscale..."
for i in {1..5}; do
    if tailscale status > /dev/null 2>&1; then
        echo "[✓] Tailscale conectado e operacional!"
        exit 0
    else
        echo "[!] Tentativa $i/5: Tailscale desconectado. Forçando reconexão..."
        tailscale up --reset || true
        sleep 5
    fi
done

echo "[X] Falha ao estabelecer conexão com o Tailscale após 5 tentativas."
exit 1