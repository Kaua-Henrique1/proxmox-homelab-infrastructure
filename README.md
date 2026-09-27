# Proxmox Homelab Infrastructure

Este repositório (Monorepo) contém toda a infraestrutura como código (IaC) e as aplicações do meu Homelab rodando em um servidor Proxmox. Ele gerencia desde o cluster de armazenamento distribuído até um Dashboard Web centralizado para controle e execução de automações.

## Estrutura do Projeto

- **`apps/`**: Contém as aplicações do painel de controle.
  - `backend/`: API em Node.js responsável por executar os scripts no host e comunicar com os serviços.
  - `frontend/`: Interface Web (HTML/Tailwind) para acessar os consoles e disparar automações.
- **`infra/`**: Configurações de infraestrutura de baixo nível.
  - `juicefs-node/`: Dockerfile e configurações para os nós do sistema de arquivos distribuído JuiceFS.
- **`scripts/`**: Scripts em Bash para automações (ex: `enviar-jogo.sh` para sincronizar jogos no Xbox 360 via FTP).
- **`storage-cluster/`**: Configurações específicas e documentação isolada do cluster de armazenamento (MinIO + Redis + JuiceFS).

## Como Iniciar

### 1. Pré-requisitos

> Antes de subir a infraestrutura, certifique-se de que o ambiente físico e o sistema operacional básico estão devidamente configurados:

- Hardware & Servidor:
- Proxmox VE (PVE): Recomendado para gerenciar containers e máquinas virtuais.
    - Opções de Instalação:
        - **Hardware Dedicado (Bare Metal)**: Instalação direta em um computador/mini-PC antigo ou servidor usando um pendrive bootável (gerado com ferramentas como Rufus, BalenaEtcher ou Ventoy).
        - **Virtualização**: Instalação em uma VM dentro de hipervisores como VMware, VirtualBox ou Hyper-V para testes.
 
### Documentação Auxiliar de Instalação e Checagem
> Clique aqui para verificar os comandos do servidor
> - [Instalação do Servidor](comandos-servidor/instalacao-recursos-servidor.md)
> - [Recursos do Servidor](comandos-servidor/verificar-recursos-servidor.md)

### 2. Configurando as Variáveis de Ambiente
Antes de subir os containers, você precisa configurar os arquivos `.env` com as suas senhas e caminhos locais.

1. Copie o arquivo de exemplo na raiz do projeto:
   ```bash
   cp .env.example .env
   ```

2. Abra os arquivos `.env` gerados (`nano .env`) e preencha as informações:
   - Defina usuários e senhas (ex: `MINIO_PASSWORD`).
   - Ajuste os caminhos absolutos do seu servidor onde os dados serão salvos (ex: `MINIO_STORAGE_PATH=/mnt/hd-dados/...`).
   - Insira os IPs e credenciais das automações (ex: Xbox).

### 3. Subindo a Infraestrutura
Com o `.env` configurado, volte para a raiz do projeto e execute o Docker Compose para construir as imagens e iniciar os serviços em segundo plano:

```bash
docker compose up -d --build
```
---
### 4. Acesso e Conectividade Global via Tailscale
O **Tailscale** cria uma rede privada segura (VPN Mesh baseada em WireGuard) permitindo acessar todo o ambiente do Proxmox, os containers e a Dashboard de controle a partir de qualquer lugar do mundo (4G/5G, Wi-Fi público ou outra rede), sem precisar abrir portas no roteador (Port Forwarding) e ultrapassando bloqueios de CGNAT da operadora.

#### **A**. Configuração no Servidor (Proxmox VE) Assumindo que o pacote `tailscale` já foi instalado via `apt`:

1. **Autenticar e Vincular o Servidor à sua Conta Tailscale:**
   ```bash
   tailscale up
   ```
    O terminal exibirá um link exclusivo (ex: https://login.tailscale.com/a/...). Copie esse link, cole no navegador do seu PC e faça login na sua conta do Tailscale.

2. **Descobrir o IP Privado (Tailscale IP) do Servidor:**
    ```bash
    tailscale ip -4
    ```
    Guarde este IP (começa com 100.x.y.z). Ele será o IP fixo universal do seu Proxmox em qualquer lugar do mundo.

#### **B**. Configuração no Computador Pessoal (Cliente)
Para que seu computador pessoal ou celular consiga "conversar" com o Proxmox remotamente, ele precisa estar conectado na mesma conta da rede Tailscale (Tailnet) ou no mesmo WIFE.
1. **Instalar o Tailscale no Linux:**
    ```bash
    curl -fsSL [https://tailscale.com/install.sh](https://tailscale.com/install.sh) | sh
    ```
2. **Iniciar e Autenticar a máquina local:**
    ```bash
    sudo tailscale up
    ```
    Acesse o URL exibido e autorize a entrada do seu computador na mesma conta do Tailscale.
3. **Verificar os nós ativos na sua rede:**
    ```bash
    tailscale status
    ```
    Você deverá ver o seu PC e o servidor Proxmox listados com seus respectivos IPs 100.x.y.z.

#### Em outros Dispositivos (Windows / macOS / Android / iOS):
- Baixe o aplicativo oficial diretamente em [tailscale.com/download](https://tailscale.com/download).
- Instale o app e faça login com a mesma conta cadastrada no servidor.
- Ative a chave no aplicativo para se conectar à rede privada.

### 5. Acessando os Serviços
Estando fora da sua rede local (ex: roteado pelo 4G do celular ou em outra rede Wi-Fi), teste o acesso usando o IP do Tailscale (100.x.y.z):
Após os containers subirem com sucesso, acesse pelo navegador (substitua `IP_DO_SERVIDOR` pelo IP local do seu Proxmox):
- **Acesso SSH ao Proxmox:** `ssh root@100.x.y.z (ip do servidor ou tailscale)`
- **Homelab Control Center (Dashboard):** `http://100.x.y.z:8080 (ip do servidor ou tailscale)`
- **MinIO Console (S3):** `http://100.x.y.z:9001 (ip do servidor ou tailscale)`
- **API do Backend:** `http://100.x.y.z:3001 (ip do servidor ou tailscale)`

## Execução de Scripts (Automação)
O Dashboard possui uma "Central de Scripts" que permite disparar rotinas do servidor com um clique. Para adicionar novos scripts:
1. Crie o arquivo `.sh` na pasta `scripts/`.
2. Dê permissão de execução: `chmod +x scripts/seu-script.sh`.
3. Adicione o botão correspondente no `apps/frontend/index.html`.

LINK: [Explicação do cluster](storage-cluster/README.md).