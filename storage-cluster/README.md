### 1. Visão Geral da Arquitetura

- **Conceito:** Armazenamento em nuvem baseado em uma arquitetura desacoplada, com separação entre metadados e blocos de dados
- **Camada de Metadados — Redis:** Gerencia a árvore de diretórios, permissões de arquivos e ponteiros em memória RAM, proporcionando alta velocidade e baixa latência.
    - Consumo médio: **1,47 MB**
- **Camada de Objetos — MinIO (S3):** Armazena os dados brutos fatiados em blocos (*chunks*) diretamente no HD físico do Proxmox.
    - Localização (exemplo): `/var/lib/minio/data`
- **Sistema de Arquivos POSIX — JuiceFS FUSE:** Atua como uma interface que unifica o MinIO (S3) e o Redis, permitindo montar o volume como uma pasta local comum nos nós do cluster.
    - Ponto de montagem: `/mnt/compartilhado`

---

### 2. Acesso Remoto e Segurança

- **VPN Mesh — Tailscale:** Permite uma conexão segura e criptografada entre o notebook e a infraestrutura Proxmox, sem a necessidade de expor portas diretamente para a internet pública, contornando limitações como **CGNAT** e regras de **Firewall**.
- **Demonstração de IP:** O acesso remoto é realizado utilizando o IP dedicado da rede mesh:

### 3. Demonstração Prática ao Viv

#### 3.1. Sincronização em Tempo Real — POSIX vs S3

1. Envie um arquivo pelo **MinIO Console** utilizando o notebook.
2. Mostre o arquivo aparecendo instantaneamente no terminal do Proxmox, dentro do container do JuiceFS.
3. Utilize o comando:

```bash
docker exec -it cluster-no1 ls -la /mnt/compartilhado
```

#### 3.2. 💾 Prova de Persistência e Tolerância a Falhas — Crash Test
- Apresente a checagem do **Hash MD5** gerado antes e depois de um `docker restart` nos containers de serviços.
- Demonstre que o hash permanece igual após o reinício dos containers.
- Explique por que os dados não são perdidos:

> O processamento ocorre em containers que podem ser reiniciados ou recriados, enquanto o armazenamento dos blocos permanece em um **volume persistente localizado no HD físico**.o ocorre em containers que podem ser reiniciados ou recriados, enquanto o armazenamento dos blocos permanece em um volume persistente localizado no HD físico.
    
    ┌───────────────────────────┐
    │       Containers          │
    │   Processamento/Serviços  │
    └─────────────┬─────────────┘
                  │
                  ▼
    ┌───────────────────────────┐
    │        JuiceFS            │
    └─────────────┬─────────────┘
                  │
                  ▼
    ┌───────────────────────────┐
    │       MinIO / S3          │
    └─────────────┬─────────────┘
                  │
                  ▼
    ┌───────────────────────────┐
    │      HD Físico Proxmox    │
    │ /mnt/hd-dados/minio-data  │
    └───────────────────────────┘

### 4. Conclusão e Considerações Finais

- **Escalabilidade:** O cluster permite expandir a capacidade de armazenamento adicionando novos discos ou novas instâncias do MinIO, sem a necessidade de interromper o serviço.

- **Custo-Benefício:** A solução foi construída integralmente utilizando ferramentas **open-source de nível de produção**, reduzindo custos de licenciamento e permitindo maior flexibilidade na infraestrutura.

---

## Resumo da Arquitetura
- O MinIO e o Redis sobem
  - O no1 cria a "tabela" do sistema de arquivos no Redis e aponta os dados pro MinIO.
    - O no1, no2 e no3 montam a pasta /mnt/compartilhado.
    - Qualquer arquivo criado dentro de /mnt/compartilhado no no1 aparece na mesma hora para o no2 e no3.



                                      ┌───────────────────┐
                                      │  Notebook 1(no1)  │
                                      │   (Seu Note)      │
                                      └─────────┬─────────┘
                                                │                           
                                                ▼                           
                                      ┌───────────────────┐                 
                                      │Tailscale VPN Mesh │
                                      └─────────┬─────────┘
                                                │
                                                ▼
                                      ┌───────────────────┐
                                      │   Servidor Casa   │
                                      │ (PC Antigo / PVE) │
                                      │   [Proxmox Host]  │
                                      └─────────┬─────────┘
                                                │
                  ┌─────────────────────────────┴─────────────────────────────┐
                  │                                                           │
                  ▼                                                           ▼
            ┌─────────────┐                                             ┌─────────────┐
            │    Redis    │                                             │    MinIO    │
            │  Metadados  │                                             │ S3/Objetos  │
            │   1,47 MB   │                                             │             │
            └──────┬──────┘                                             └──────┬──────┘
                   │                                                           │
                   └─────────────────────────────┬─────────────────────────────┘
                                                 │
                                                 ▼
                                      ┌────────────────────┐
                                      │   JuiceFS (FUSE)   │
                                      └──────────┬─────────┘
                                                 │
                                                 ▼
                                      ┌────────────────────┐
                                      │ /mnt/compartilhado │
                                      └────────────────────┘
