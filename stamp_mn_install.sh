#/bin/bash

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

set -o errexit

cd ~
sudo locale-gen en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

STAMP_LINUX_URL=https://github.com/zSAM-Project/stamp/releases/download/1.1.0.2/stamp-1.1.0-x86_64-linux-gnu.tar.gz
STAMP_USER_PASS=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo ""`
STAMP_RPC_PASS=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 ; echo ""`
MN_NAME_PREFIX=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 6 ; echo ""`
MN_EXTERNAL_IP=`curl -s -4 ifconfig.co`

sudo userdel stampcoin
sudo useradd -U -m stampcoin -s /bin/bash
echo "stampcoin:${STAMP_USER_PASS}" | sudo chpasswd
sudo wget $STAMP_LINUX_URL --directory-prefix /home/stampcoin/
sudo tar -xzvf /home/stampcoin/stamp-*-x86_64-linux-gnu.tar.gz -C /home/stampcoin/
sudo rm /home/stampcoin/stamp-*-x86_64-linux-gnu.tar.gz
sudo chown -R stampcoin:stampcoin /home/stampcoin/stamp*
sudo chmod 755 /home/stampcoin/stamp*
echo "Copy STAMP files!"
sudo cp /home/stampcoin/stamp*/bin/stampd /usr/bin
sudo cp /home/stampcoin/stamp*/bin/stamp-cli /usr/bin
sudo rm -rf /home/stampcoin/stamp*
sudo rm -rf /home/stampcoin/.stamp/

CONF_DIR=/home/stampcoin/.stamp/
CONF_FILE=stamp.conf

mkdir -p $CONF_DIR
echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> $CONF_DIR/$CONF_FILE
echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> $CONF_DIR/$CONF_FILE
echo "rpcallowip=127.0.0.1" >> $CONF_DIR/$CONF_FILE
echo "rpcport=33453" >> $CONF_DIR/$CONF_FILE
echo "listen=1" >> $CONF_DIR/$CONF_FILE
echo "server=1" >> $CONF_DIR/$CONF_FILE
echo "daemon=1" >> $CONF_DIR/$CONF_FILE
echo "maxconnections=256" >> $CONF_DIR/$CONF_FILE
echo "port=33452" >> $CONF_DIR/$CONF_FILE

sudo chown -R stampcoin:stampcoin /home/stampcoin/.stamp/
sudo chown 500 /home/stampcoin/.stamp/stamp.conf

sudo tee /etc/systemd/system/stampcoin.service <<EOF
[Unit]
Description=STAMPCoin, distributed currency daemon
After=network.target

[Service]
User=stampcoin
Group=stampcoin
WorkingDirectory=/home/stampcoin/
ExecStart=/usr/bin/stampd

Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=2s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF

sudo -H -u stampcoin /usr/bin/stampd
echo "Booting STAMP node and creating keypool"
sleep 15

MNGENKEY=`sudo -H -u stampcoin /usr/bin/stamp-cli masternode genkey`
echo -e "masternode=1\nmasternodeaddress=${MN_EXTERNAL_IP}:33452\nmasternodeprivkey=${MNGENKEY}" | sudo tee -a /home/stampcoin/.stamp/stamp.conf
sudo -H -u stampcoin /usr/bin/stamp-cli stop
sudo systemctl enable stampcoin
sudo systemctl start stampcoin

echo " "
echo " "
echo "==============================="
echo "Masternode installed!"
echo "==============================="
echo "Copy and keep that information in secret:"
echo "Masternode key: ${MNGENKEY}"
echo "SSH password for user \"stampcoin\": ${STAMP_USER_PASS}"
echo "Prepared masternode.conf string:"
echo "MN_${MN_NAME_PREFIX} ${MN_EXTERNAL_IP}:3234 ${MNGENKEY} INPUTTX INPUTINDEX"

exit 0



