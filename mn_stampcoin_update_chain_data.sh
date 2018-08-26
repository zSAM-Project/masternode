#!/bin/bash

################################################################################
# Author:   Supawat A
# Date:     August, 16th 2018
# 
# Program:
#
#   Update STAMP Coin for single masternode
################################################################################

echo && echo 
echo "****************************************************************************"
echo "*                                                                          *"
echo "*  This script will updaten latest version of STAMP Coin for masternode.   *"
echo "*                                                                          *"
echo "****************************************************************************"
echo && echo

cd ~
sudo wget https://github.com/zSAM-Project/stamp/releases/download/masternode/stamp.tar.gz
sudo tar -xzvf stamp.tar.gz

sudo systemctl stop stampcoin
sleep 15

sudo cp ./stamp/stamp* /usr/local/bin/
sudo rm ./stamp.tar.gz
sudo rm -rf ./stamp

sudo wget https://github.com/zSAM-Project/stamp/releases/download/v2.4.1.1/stamp-chain-40900-bootstrap.dat.zip
sudo unzip stamp-chain-40900-bootstrap.dat.zip

sudo cp -r /root/bootstrap.dat /home/stampcoin/.stamp/

sudo chown -R stampcoin:stampcoin /home/stampcoin/.stamp/bootstrap.dat

sudo rm -rf /home/stampcoin/.stamp/blocks
sudo rm -rf /home/stampcoin/.stamp/chainstate
sudo rm -rf /home/stampcoin/.stamp/zerocoin
sudo rm -rf /home/stampcoin/.stamp/sporks
sudo rm /home/stampcoin/.stamp/peers.dat
sudo rm /home/stampcoin/.stamp/banlist.dat 

rm stamp-chain-40900-bootstrap.dat.zip
rm bootstrap.dat

sudo systemctl start stampcoin
sleep 30
INFO=`sudo -H -u stampcoin /usr/local/bin/stamp-cli getinfo`

echo " "
echo " "
echo "==============================="
echo "STAMP Coin Masternode updated! "
echo "==============================="
echo "${INFO}"

exit 0
