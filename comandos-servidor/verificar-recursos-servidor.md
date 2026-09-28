## Verificar programas instalados no sistema (Debian/Proxmox):

```bash
# Listar todos os pacotes instalados
dpkg -l

# Buscar se um pacote específico está instalado (ex: git ou docker)
dpkg -l | grep -i git
dpkg -l | grep -i docker
```

## Verificar o IP Local do Servidor:
```bash
ip a
# ou apenas a linha da interface principal:
hostname -I
```

## Verificar se o Servidor e a Conexão com a Internet estão Ativos:
```bash
# Testar conectividade de rede externa (ping no DNS do Google)
ping -c 4 8.8.8.8

# Testar se a porta SSH (22) está ouvindo no servidor
ss -tulpn | grep :22
```

## Verificar o Uso de Hardware (CPU, RAM e Disco):
```bash
# Ver espaço em disco dos pontos de montagem
df -h

# Ver memória RAM disponível
free -h

# Monitor de recursos em tempo real (Pressione 'q' para sair)
htop
```

# 1.1. Reiniciar e ativar o serviço do Tailscale:10 segundos.Force o serviço do Tailscale a iniciar e se habilitar no boot
systemctl enable --now tailscaled
systemctl restart tailscaled
