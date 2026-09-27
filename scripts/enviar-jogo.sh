#!/bin/bash
echo "Iniciando sincronização com o Xbox em ${XBOX_IP}..."

# Executa o lftp mapeando a pasta interna do container (/xboxjogos)
lftp -u "${XBOX_USER},${XBOX_PASS}" "${XBOX_IP}" -e "mirror -R --only-missing /xboxjogos /Hdd1/games; quit"

echo "Sincronização concluída!"
