```bash
# 1. Atualizar os repositórios do sistema
apt update && apt upgrade -y

# 2. Instalar utilitários essenciais, Docker, Tailscale, Samba e LFTP
apt install -y \
  git \
  curl \
  wget \
  net-tools \
  htop \
  tmux \
  lftp \
  tailscale \
  docker.io \
  docker-compose \
  -o Acquire::Retries=5 samba

# 3. Habilitar e iniciar os serviços essenciais
systemctl enable --now docker tailscale
```
