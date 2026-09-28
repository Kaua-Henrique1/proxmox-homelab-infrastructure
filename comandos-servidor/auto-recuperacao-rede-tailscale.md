Resiliência e Auto-Recuperação da Rede (Tailscale Watchdog)

Para garantir disponibilidade contínua do acesso remoto e prevenir quedas de conexão causadas por falhas de DNS, alterações de IP local ou reinicializações de interface, implementamos um serviço de **Watchdog em segundo plano**.

O script monitora o status do daemon a cada 30 segundos e força a reconexão automática caso a malha perca a conectividade.

---

### 1. Criar o Script Watchdog (`/usr/local/bin/tailscale-watchdog.sh`)

Crie o arquivo executável responsável pela checagem e recuperação do serviço:

```bash
cat << 'EOF' > /usr/local/bin/tailscale-watchdog.sh
#!/bin/bash
# ==============================================================================
# Script: tailscale-watchdog.sh
# Descrição: Monitora e reativa a conexão do Tailscale em caso de queda.
# ==============================================================================

INTERVALO=30

echo "[*] Monitoramento do Tailscale iniciado (intervalo de ${INTERVALO}s)..."

while true; do
    if ! tailscale status > /dev/null 2>&1; then
        echo "[!] [$(date '+%Y-%m-%d %H:%M:%S')] Tailscale inativo/desconectado. Reativando..."
        systemctl restart tailscaled
        tailscale up --reset || true
    fi
    sleep $INTERVALO
done
EOF

# Garante permissões de execução
chmod 755 /usr/local/bin/tailscale-watchdog.sh
```
### 2. Criar e Ativar o Serviço Systemd (/etc/systemd/system/tailscale-watchdog.service)
Para rodar o monitoramento de forma persistente no sistema:
```bash
cat << 'EOF' > /etc/systemd/system/tailscale-watchdog.service
[Unit]
Description=Watchdog para manter o Tailscale sempre ativo
After=network-online.target tailscaled.service
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/tailscale-watchdog.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Recarrega as configurações do systemd e inicia o serviço no boot
systemctl daemon-reload
systemctl enable --now tailscale-watchdog.service
```
### Comandos de Operação para o Usuário
Verificar se o watchdog está rodando:
```bash
systemctl status tailscale-watchdog.service
```
Acompanhar logs de eventos e reconexões em tempo real:
```bash
journalctl -u tailscale-watchdog.service -f
```
Pausar ou reiniciar o monitoramento:
```bash
systemctl stop tailscale-watchdog.service
systemctl restart tailscale-watchdog.service
```
