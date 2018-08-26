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
sudo wget https://github.com/zSAM-Project/stamp/releases/download/v2.4.1.1/stamp-2.4.1.tar.gz
sudo tar -xzvf stamp-2.4.1.tar.gz
sudo systemctl stop stampcoin
sleep 10
sudo cp ~/stamp/stamp* /usr/local/bin/
sudo rm ~/stamp-2.4.1.tar.gz
sudo rm -rf /root/stamp
sudo systemctl start stampcoin
sleep 10
INFO=`sudo -H -u stampcoin /usr/local/bin/stamp-cli getinfo`

echo " "
echo " "
echo "==============================="
echo "STAMP Coin Masternode updated! "
echo "==============================="
echo "${INFO}"

exit 0
