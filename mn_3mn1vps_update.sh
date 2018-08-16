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
sudo systemctl stop stampmn1
sudo systemctl stop stampmn2
sudo systemctl stop stampmn3
sleep 10

sudo cp ~/stamp/stamp* /home/stampmn1/
sudo cp ~/stamp/stamp* /home/stampmn2/
sudo cp ~/stamp/stamp* /home/stampmn3/
sudo rm ~/stamp.tar.gz 
sudo rm -rf /root/stamp

sudo systemctl start stampmn1
sudo systemctl start stampmn2
sudo systemctl start stampmn3
sleep 10
INFO1=`sudo -H -u stampmn1 /home/stampmn1/stamp-cli getinfo`
INFO2=`sudo -H -u stampmn2 /home/stampmn2/stamp-cli getinfo`
INFO3=`sudo -H -u stampmn3 /home/stampmn3/stamp-cli getinfo`

echo " "
echo " "
echo "==============================="
echo "STAMP Coin MN1 updated!        "
echo "==============================="
echo "${INFO1}"
echo " "
echo "==============================="
echo "STAMP Coin MN2 updated!        "
echo "==============================="
echo "${INFO2}"
echo " "
echo "==============================="
echo "STAMP Coin MN3 updated!        "
echo "==============================="
echo "${INFO3}"

exit 0
