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
sleep 10
sudo cp ~/stamp/stamp* /usr/local/bin/
sudo rm ~/stamp.tar.gz 
sudo rm -rf /root/stamp

sudo wget https://github.com/zSAM-Project/stamp/releases/download/masternode/chain.tar.gz
sudo tar -xzvf chain.tar.gz

sudo mv /home/stampcoin/.stamp/blocks /home/stampcoin/.stamp/blocks_bak
sudo mv /home/stampcoin/.stamp/chainstate /home/stampcoin/.stamp/chainstate_bak

sudo cp -r blocks/ /home/stampcoin/.stamp/
sudo cp -r chainstate/ /home/stampcoin/.stamp/

sudo rm /home/stampcoin/.stamp/peers.dat 
sudo rm /home/stampcoin/.stamp/banlist.dat 

sudo chown -R stampcoin:stampcoin /home/stampcoin/.stamp/blocks
sudo chown -R stampcoin:stampcoin /home/stampcoin/.stamp/chainstate

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
