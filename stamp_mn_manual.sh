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
STAMP_RPC_PASS=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 ; echo ""`

echo "Type the IP Address of this server, followed by [ENTER]:"
read MN_EXTERNAL_IP
echo ""
echo "Enter RPC Port 43453 for MN1, 43463 for MN2 or 43473 for MN3, followed by [ENTER]:"
read STAMP_RPC_PORT
echo ""
echo "Enter Masternode User Name (stampmn1, stampmn2 or stampmn3), followed by [ENTER]:"
read STAMP_USERNAME
echo ""
echo "Enter Masternode Password, followed by [ENTER]:"
read STAMP_USER_PASS

sudo userdel ${STAMP_USERNAME}
sudo useradd -U -m ${STAMP_USERNAME} -s /bin/bash
gpasswd -a ${STAMP_USERNAME} sudo
echo "${STAMP_USERNAME}:${STAMP_USER_PASS}" | sudo chpasswd
sudo wget $STAMP_LINUX_URL --directory-prefix /home/${STAMP_USERNAME}/
sudo tar -xzvf /home/${STAMP_USERNAME}/stamp-*-x86_64-linux-gnu.tar.gz -C /home/${STAMP_USERNAME}/
sudo rm /home/${STAMP_USERNAME}/stamp-*-x86_64-linux-gnu.tar.gz
sudo chown -R ${STAMP_USERNAME}:${STAMP_USERNAME} /home/${STAMP_USERNAME}/stamp*
sudo chmod 755 /home/${STAMP_USERNAME}/stamp*
echo "Copy STAMP files!"
sudo cp /home/${STAMP_USERNAME}/stamp*/bin/stampd /home/${STAMP_USERNAME}/
sudo cp /home/${STAMP_USERNAME}/stamp*/bin/stamp-cli /home/${STAMP_USERNAME}/
sudo rm -rf /home/${STAMP_USERNAME}/stamp*
sudo rm -rf /home/${STAMP_USERNAME}/.stamp/
exit 0;
CONF_DIR=/home/${STAMP_USERNAME}/.stamp/
CONF_FILE=stamp.conf

mkdir -p $CONF_DIR
echo "rpcuser=stampcoinrpc" >> $CONF_DIR/$CONF_FILE
echo "rpcpassword=${STAMP_RPC_PASS}" >> $CONF_DIR/$CONF_FILE
echo "rpcallowip=127.0.0.1" >> $CONF_DIR/$CONF_FILE
echo "rpcport=${STAMP_RPC_PORT}" >> $CONF_DIR/$CONF_FILE
echo "listen=1" >> $CONF_DIR/$CONF_FILE
echo "server=1" >> $CONF_DIR/$CONF_FILE
echo "daemon=1" >> $CONF_DIR/$CONF_FILE
echo "maxconnections=256" >> $CONF_DIR/$CONF_FILE
echo "port=43452" >> $CONF_DIR/$CONF_FILE
echo "bind=${MN_EXTERNAL_IP}:43452" >> $CONF_DIR/$CONF_FILE

sudo chown -R ${STAMP_USERNAME}:${STAMP_USERNAME} /home/${STAMP_USERNAME}/.stamp/
sudo chown 500 /home/${STAMP_USERNAME}/.stamp/stamp.conf

sudo tee /etc/systemd/system/${STAMP_USERNAME}.service <<EOF
[Unit]
Description=STAMP Coin, distributed currency daemon
After=syslog.target network.target

[Service]
Type=forking
User=${STAMP_USERNAME}
Group=${STAMP_USERNAME}
WorkingDirectory=/home/${STAMP_USERNAME}/
ExecStart=/home/${STAMP_USERNAME}/stampd
ExecStop=/home/${STAMP_USERNAME}/stamp-cli stop

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

sudo -H -u ${STAMP_USERNAME} /home/${STAMP_USERNAME}/stampd
echo "Booting STAMP node and creating keypool"
sleep 10

MNGENKEY=`sudo -H -u ${STAMP_USERNAME} /home/${STAMP_USERNAME}/stamp-cli masternode genkey`
echo -e "masternode=1\nmasternodeaddress=${MN_EXTERNAL_IP}:43452\nmasternodeprivkey=${MNGENKEY}" | sudo tee -a /home/${STAMP_USERNAME}/.stamp/stamp.conf
sudo -H -u ${STAMP_USERNAME} /home/${STAMP_USERNAME}/stamp-cli stop
sudo systemctl enable ${STAMP_USERNAME}
sudo systemctl start ${STAMP_USERNAME}

echo " "
echo " "
echo "==============================="
echo "STAMP Coin Masternode installed!"
echo "==============================="
echo "Copy and keep that information in secret:"
echo "Masternode key: ${MNGENKEY}"
echo "SSH password for user \"${STAMP_USERNAME}\": ${STAMP_USER_PASS}"
echo "Prepared masternode.conf string:"
echo "MNx ${MN_EXTERNAL_IP}:43452 ${MNGENKEY} INPUTTX INPUTINDEX"

exit 0


