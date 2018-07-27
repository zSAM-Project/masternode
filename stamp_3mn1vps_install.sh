#/bin/bash

################################################################################
# Author:   Supawat A
# Date:     July, 16th 2018
# 
# Program:
#
#   Install STAMP Coin masternode on clean VPS with Ubuntu 16.04 
#	Need 3 IP on VPS
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
STAMP_RPC_PORT1=43453
STAMP_RPC_PORT2=43463
STAMP_RPC_PORT3=43473

echo "Type the IP #1 of this server, followed by [ENTER]:"
read IP1
echo ""
echo "Type the IP #2 of this server, followed by [ENTER]:"
read IP2
echo ""
echo "Type the IP #3 of this server, followed by [ENTER]:"
read IP3
echo ""
echo "Enter Masternode Account Login Password"
read STAMP_USER_PASS

sudo userdel stampmn1
sudo useradd -U -m stampmn1 -s /bin/bash
echo "stampmn1:${STAMP_USER_PASS}" | sudo chpasswd

sudo userdel stampmn2
sudo useradd -U -m stampmn2 -s /bin/bash
echo "stampmn2:${STAMP_USER_PASS}" | sudo chpasswd

sudo userdel stampmn3
sudo useradd -U -m stampmn3 -s /bin/bash
echo "stampmn3:${STAMP_USER_PASS}" | sudo chpasswd

sudo wget $STAMP_LINUX_URL --directory-prefix /root/
sudo tar -xzvf /root/stamp-*-x86_64-linux-gnu.tar.gz -C /root/
sudo rm /root/stamp-*-x86_64-linux-gnu.tar.gz

echo "Copy STAMP files to MN1!"
sudo cp /root/stamp*/bin/stampd /home/stampmn1
sudo cp /root/stamp*/bin/stamp-cli /home/stampmn1
sudo chown -R stampmn1:stampmn1 /home/stampmn1/stamp*

echo "Copy STAMP files to MN2!"
sudo cp /root/stamp*/bin/stampd /home/stampmn2
sudo cp /root/stamp*/bin/stamp-cli /home/stampmn2
sudo chown -R stampmn2:stampmn2 /home/stampmn2/stamp*

echo "Copy STAMP files to MN3!"
sudo cp /root/stamp*/bin/stampd /home/stampmn3
sudo cp /root/stamp*/bin/stamp-cli /home/stampmn3
sudo chown -R stampmn3:stampmn3 /home/stampmn3/stamp*

sudo rm -rf /root/stamp*

sudo rm -rf /home/stampmn1/.stamp/
CONF_DIR=/home/stampmn1/.stamp/
CONF_FILE=stamp.conf
mkdir -p $CONF_DIR
echo "rpcuser=stampcoinrpc" >> $CONF_DIR/$CONF_FILE
echo "rpcpassword=${STAMP_RPC_PASS}" >> $CONF_DIR/$CONF_FILE
echo "rpcallowip=127.0.0.1" >> $CONF_DIR/$CONF_FILE
echo "rpcport=${STAMP_RPC_PORT1}" >> $CONF_DIR/$CONF_FILE
echo "listen=1" >> $CONF_DIR/$CONF_FILE
echo "server=1" >> $CONF_DIR/$CONF_FILE
echo "daemon=1" >> $CONF_DIR/$CONF_FILE
echo "maxconnections=256" >> $CONF_DIR/$CONF_FILE
echo "port=43452" >> $CONF_DIR/$CONF_FILE
echo "bind=${IP1}:43452" >> $CONF_DIR/$CONF_FILE
sudo chown -R stampmn1:stampmn1 /home/stampmn1/.stamp/
sudo chown 500 /home/stampmn1/.stamp/stamp.conf

sudo rm -rf /home/stampmn2/.stamp/
CONF_DIR=/home/stampmn2/.stamp/
mkdir -p $CONF_DIR
echo "rpcuser=stampcoinrpc" >> $CONF_DIR/$CONF_FILE
echo "rpcpassword=${STAMP_RPC_PASS}" >> $CONF_DIR/$CONF_FILE
echo "rpcallowip=127.0.0.1" >> $CONF_DIR/$CONF_FILE
echo "rpcport=${STAMP_RPC_PORT2}" >> $CONF_DIR/$CONF_FILE
echo "listen=1" >> $CONF_DIR/$CONF_FILE
echo "server=1" >> $CONF_DIR/$CONF_FILE
echo "daemon=1" >> $CONF_DIR/$CONF_FILE
echo "maxconnections=256" >> $CONF_DIR/$CONF_FILE
echo "port=43452" >> $CONF_DIR/$CONF_FILE
echo "bind=${IP2}:43452" >> $CONF_DIR/$CONF_FILE
sudo chown -R stampmn2:stampmn2 /home/stampmn2/.stamp/
sudo chown 500 /home/stampmn2/.stamp/stamp.conf

sudo rm -rf /home/stampmn3/.stamp/
CONF_DIR=/home/stampmn3/.stamp/
mkdir -p $CONF_DIR
echo "rpcuser=stampcoinrpc" >> $CONF_DIR/$CONF_FILE
echo "rpcpassword=${STAMP_RPC_PASS}" >> $CONF_DIR/$CONF_FILE
echo "rpcallowip=127.0.0.1" >> $CONF_DIR/$CONF_FILE
echo "rpcport=${STAMP_RPC_PORT3}" >> $CONF_DIR/$CONF_FILE
echo "listen=1" >> $CONF_DIR/$CONF_FILE
echo "server=1" >> $CONF_DIR/$CONF_FILE
echo "daemon=1" >> $CONF_DIR/$CONF_FILE
echo "maxconnections=256" >> $CONF_DIR/$CONF_FILE
echo "port=43452" >> $CONF_DIR/$CONF_FILE
echo "bind=${IP3}:43452" >> $CONF_DIR/$CONF_FILE
sudo chown -R stampmn3:stampmn3 /home/stampmn3/.stamp/
sudo chown 500 /home/stampmn3/.stamp/stamp.conf

sudo tee /etc/systemd/system/stampmn1.service <<EOF
[Unit]
Description=STAMP Coin, distributed currency daemon
After=syslog.target network.target

[Service]
Type=forking
User=stampmn1
Group=stampmn1
WorkingDirectory=/home/stampmn1/
ExecStart=/home/stampmn1/stampd
ExecStop=/home/stampmn1/stamp-cli stop

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

sudo tee /etc/systemd/system/stampmn2.service <<EOF
[Unit]
Description=STAMP Coin, distributed currency daemon
After=syslog.target network.target

[Service]
Type=forking
User=stampmn2
Group=stampmn2
WorkingDirectory=/home/stampmn2/
ExecStart=/home/stampmn2/stampd
ExecStop=/home/stampmn2/stamp-cli stop

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

sudo tee /etc/systemd/system/stampmn3.service <<EOF
[Unit]
Description=STAMP Coin, distributed currency daemon
After=syslog.target network.target

[Service]
Type=forking
User=stampmn3
Group=stampmn3
WorkingDirectory=/home/stampmn3/
ExecStart=/home/stampmn3/stampd
ExecStop=/home/stampmn3/stamp-cli stop

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

sudo -H -u stampmn1 /home/stampmn1/stampd
echo "Booting STAMP MN1 and creating keypool"
sleep 10
MNGENKEY1=`sudo -H -u stampmn1 /home/stampmn1/stamp-cli masternode genkey`
echo -e "#masternode=1\n#masternodeaddress=${IP1}:43452\n#masternodeprivkey=${MNGENKEY1}" | sudo tee -a /home/stampmn1/.stamp/stamp.conf
sudo -H -u stampmn1 /home/stampmn1/stamp-cli stop
sudo systemctl enable stampmn1
sudo systemctl start stampmn1

sudo -H -u stampmn2 /home/stampmn2/stampd
echo "Booting STAMP MN2 and creating keypool"
sleep 10
MNGENKEY2=`sudo -H -u stampmn2 /home/stampmn2/stamp-cli masternode genkey`
echo -e "#masternode=1\n#masternodeaddress=${IP2}:43452\n#masternodeprivkey=${MNGENKEY2}" | sudo tee -a /home/stampmn2/.stamp/stamp.conf
sudo -H -u stampmn2 /home/stampmn2/stamp-cli stop
sudo systemctl enable stampmn2
sudo systemctl start stampmn2

sudo -H -u stampmn3 /home/stampmn3/stampd
echo "Booting STAMP MN3 and creating keypool"
sleep 10
MNGENKEY3=`sudo -H -u stampmn3 /home/stampmn3/stamp-cli masternode genkey`
echo -e "#masternode=1\n#masternodeaddress=${IP3}:43452\n#masternodeprivkey=${MNGENKEY3}" | sudo tee -a /home/stampmn3/.stamp/stamp.conf
sudo -H -u stampmn3 /home/stampmn3/stamp-cli stop
sudo systemctl enable stampmn3
sudo systemctl start stampmn3

echo " "
echo " "
echo "==============================="
echo "STAMP Coin Masternode installed!"
echo "==============================="
echo "Copy and keep that information in secret:"
echo "Masternode #1 key: ${MNGENKEY1}"
echo "Masternode #2 key: ${MNGENKEY2}"
echo "Masternode #3 key: ${MNGENKEY3}"
echo "SSH password for user \"stampmn1@${IP1},stampmn2@${IP2},stampmn3@${IP3}\": ${STAMP_USER_PASS}"
echo "Prepared masternode.conf string:"
echo "MN1 ${IP1}:43452 ${MNGENKEY1} INPUTTX INPUTINDEX"
echo "MN2 ${IP2}:43452 ${MNGENKEY2} INPUTTX INPUTINDEX"
echo "MN3 ${IP3}:43452 ${MNGENKEY3} INPUTTX INPUTINDEX"

exit 0



