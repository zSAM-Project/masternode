#!/bin/bash

################################################################################
# Author:   Supawat A
# Date:     July, 16th 2018
# 
# Program:
#
#   Install STAMP Coin masternode on clean VPS with Ubuntu 16.04 
#
################################################################################

echo && echo 
echo "****************************************************************************"
echo "*                                                                          *"
echo "*  This script will install and configure your STAMP Coin masternode.      *"
echo "*                                                                          *"
echo "****************************************************************************"
echo && echo

#set -o errexit

cd ~
sudo locale-gen en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

STAMP_LINUX_URL=https://github.com/zSAM-Project/stamp/releases/download/v2.0.0.1/stamp-2.0.0-x86_64-linux-gnu.tar.gz
STAMP_USER_PASS=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo ""`
STAMP_RPC_PASS=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 ; echo ""`
MN_EXTERNAL_IP=`curl -s -4 ifconfig.co`

sudo userdel stampcoin
gpasswd -a stampcoin sudo
sudo useradd -U -m stampcoin -s /bin/bash
echo "stampcoin:${STAMP_USER_PASS}" | sudo chpasswd
sudo wget $STAMP_LINUX_URL --directory-prefix /home/stampcoin/
sudo tar -xzvf /home/stampcoin/stamp-*-x86_64-linux-gnu.tar.gz -C /home/stampcoin/
sudo rm /home/stampcoin/stamp-*-x86_64-linux-gnu.tar.gz
sudo chown -R stampcoin:stampcoin /home/stampcoin/stamp*
sudo chmod 755 /home/stampcoin/stamp*
echo "Copy STAMP files!"
sudo cp /home/stampcoin/stamp*/bin/stampd /usr/local/bin
sudo cp /home/stampcoin/stamp*/bin/stamp-cli /usr/local/bin
sudo rm -rf /home/stampcoin/stamp*
sudo rm -rf /home/stampcoin/.stamp/

CONF_DIR=/home/stampcoin/.stamp/
CONF_FILE=stamp.conf

mkdir -p $CONF_DIR
echo "rpcuser=stampcoinrpc" >> $CONF_DIR/$CONF_FILE
echo "rpcpassword=${STAMP_RPC_PASS}" >> $CONF_DIR/$CONF_FILE
echo "rpcallowip=127.0.0.1" >> $CONF_DIR/$CONF_FILE
echo "rpcport=43453" >> $CONF_DIR/$CONF_FILE
echo "listen=1" >> $CONF_DIR/$CONF_FILE
echo "server=1" >> $CONF_DIR/$CONF_FILE
echo "daemon=1" >> $CONF_DIR/$CONF_FILE
echo "maxconnections=256" >> $CONF_DIR/$CONF_FILE
echo "port=43452" >> $CONF_DIR/$CONF_FILE
echo "bind=${MN_EXTERNAL_IP}:43452" >> $CONF_DIR/$CONF_FILE

sudo chown -R stampcoin:stampcoin /home/stampcoin/.stamp/
sudo chown 500 /home/stampcoin/.stamp/stamp.conf

sudo tee /etc/systemd/system/stampcoin.service <<EOF
[Unit]
Description=STAMP Coin, distributed currency daemon
After=syslog.target network.target

[Service]
Type=forking
User=stampcoin
Group=stampcoin
WorkingDirectory=/home/stampcoin/
ExecStart=/usr/local/bin/stampd
ExecStop=/usr/local/bin/stamp-cli stop

Restart=on-failure
RestartSec=120
PrivateTmp=true
TimeoutStopSec=120
TimeoutStartSec=120
StartLimitInterval=120
StartLimitBurst=3

[Install]
WantedBy=multi-user.target
EOF

sudo -H -u stampcoin /usr/local/bin/stampd
echo "Booting STAMP node and creating keypool"
sleep 10

MNGENKEY=`sudo -H -u stampcoin /usr/local/bin/stamp-cli masternode genkey`
echo -e "masternode=1\nmasternodeaddress=${MN_EXTERNAL_IP}:43452\nmasternodeprivkey=${MNGENKEY}" | sudo tee -a /home/stampcoin/.stamp/stamp.conf
sudo -H -u stampcoin /usr/local/bin/stamp-cli stop
sudo systemctl enable stampcoin
sudo systemctl start stampcoin

echo " "
echo " "
echo "==============================="
echo "STAMP Coin Masternode installed!"
echo "==============================="
echo "Copy and keep that information in secret:"
echo "Masternode key: ${MNGENKEY}"
echo "SSH password for user \"stampcoin\": ${STAMP_USER_PASS}"
echo "Prepared masternode.conf string:"
echo "MNx ${MN_EXTERNAL_IP}:43452 ${MNGENKEY} INPUTTX INPUTINDEX"

exit 0



