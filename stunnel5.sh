#!/bin/bash
# ---------------------------------------------------------
# Script de Instalação e Configuração do Stunnel 5
# Autor: Seu Nome
# Data: 4 de fevereiro de 2024
# Versão: 1.0
# ---------------------------------------------------------

# Constantes
URL_DOWNLOAD_STUNNEL="https://raw.githubusercontent.com/PhoenixxZ2023/SSL-PRO/main/stunnel5"
CAMINHO_CONF_STUNNEL="/etc/stunnel5/stunnel5.conf"

# Atualiza e instala pacotes necessários
apt-get update
apt-get install -y build-essential libssl-dev zlib1g-dev unzip

# Baixa e instala o Stunnel 5
echo "Baixando o Stunnel 5..."
cd /root/
wget -q -O stunnel5.zip "$URL_DOWNLOAD_STUNNEL/stunnel5.zip"
unzip -o stunnel5.zip
cd /root/stunnel

# Configura, compila e instala o Stunnel 5
echo "Configurando, compilando e instalando o Stunnel 5..."
./configure
make
make install

# Limpeza
cd /root
rm -r -f stunnel
rm -f stunnel5.zip

# Cria arquivo de configuração do Stunnel 5
echo "Criando arquivo de configuração do Stunnel 5..."
cat > "$CAMINHO_CONF_STUNNEL" <<-END
cert = /etc/xray/xray.crt
key = /etc/xray/xray.key
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 53
connect = 127.0.0.1:109

[ssh]
accept = 777
connect = 127.0.0.1:8000
END

# Cria serviço Systemd para o Stunnel 5
echo "Criando serviço Systemd para o Stunnel 5..."
cat > /etc/systemd/system/stunnel5.service << END
[Unit]
Description=Serviço Stunnel5
Documentation=https://stunnel.org
Documentation=https://nekopoi.care
After=syslog.target network-online.target

[Service]
ExecStart=/usr/local/bin/stunnel5 $CAMINHO_CONF_STUNNEL
Type=forking

[Install]
WantedBy=multi-user.target
END

# Baixa script Init.d para o Stunnel 5
echo "Baixando script Init.d para o Stunnel 5..."
wget -q -O /etc/init.d/stunnel5 "$URL_DOWNLOAD_STUNNEL/stunnel5.init"

# Define permissões
echo "Definindo permissões..."
chmod 600 "$CAMINHO_CONF_STUNNEL"
chmod +x /etc/init.d/stunnel5
cp /usr/local/bin/stunnel /usr/local/bin/stunnel5

# Remove versões antigas do Stunnel
echo "Removendo binários antigos do Stunnel..."
rm -f /usr/local/bin/stunnel
rm -f /usr/local/bin/stunnel3
rm -f /usr/local/bin/stunnel4

# Reinicia o Stunnel 5
echo "Reiniciando o Stunnel 5..."
systemctl stop stunnel5
systemctl enable stunnel5
systemctl start stunnel5
systemctl restart stunnel5
/etc/init.d/stunnel5 restart
/etc/init.d/stunnel5 status

echo "Instalação e configuração do Stunnel 5 concluídas com sucesso."
