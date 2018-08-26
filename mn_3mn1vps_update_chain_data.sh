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
sudo systemctl stop stampmn1
sudo systemctl stop stampmn2
sudo systemctl stop stampmn3
sleep 10

sudo cp ./stamp/stamp* /home/stampmn1/
sudo cp ./stamp/stamp* /home/stampmn2/
sudo cp ./stamp/stamp* /home/stampmn3/
sudo rm ./stamp-2.4.1.tar.gz
sudo rm -rf ./stamp


sudo wget https://github.com/zSAM-Project/stamp/releases/download/v2.4.1.1/stamp-chain-40900-bootstrap.dat.zip
sudo unzip stamp-chain-40900-bootstrap.dat.zip
sudo rm ./stamp-chain-40900-bootstrap.dat.zip

sudo rm -rf /home/stampmn1/.stamp/blocks
sudo rm -rf /home/stampmn1/.stamp/chainstate
sudo rm -rf /home/stampmn1/.stamp/zerocoin
sudo rm -rf /home/stampmn1/.stamp/sporks
sudo rm /home/stampmn1/.stamp/peers.dat
sudo rm /home/stampmn1/.stamp/banlist.dat 

sudo rm -rf /home/stampmn2/.stamp/blocks
sudo rm -rf /home/stampmn2/.stamp/chainstate
sudo rm -rf /home/stampmn2/.stamp/zerocoin
sudo rm -rf /home/stampmn2/.stamp/sporks
sudo rm /home/stampmn2/.stamp/peers.dat
sudo rm /home/stampmn2/.stamp/banlist.dat 

sudo rm -rf /home/stampmn3/.stamp/blocks
sudo rm -rf /home/stampmn3/.stamp/chainstate
sudo rm -rf /home/stampmn3/.stamp/zerocoin
sudo rm -rf /home/stampmn3/.stamp/sporks
sudo rm /home/stampmn3/.stamp/peers.dat
sudo rm /home/stampmn3/.stamp/banlist.dat 

sudo cp -r /root/bootstrap.dat /home/stampmn1/.stamp/
sudo cp -r /root/bootstrap.dat /home/stampmn2/.stamp/
sudo cp -r /root/bootstrap.dat /home/stampmn3/.stamp/

sudo chown -R stampmn1:stampmn1 /home/stampmn1/.stamp/bootstrap.dat
sudo chown -R stampmn2:stampmn2 /home/stampmn2/.stamp/bootstrap.dat
sudo chown -R stampmn3:stampmn3 /home/stampmn3/.stamp/bootstrap.dat

rm bootstrap.dat

sudo systemctl start stampmn1
sudo systemctl start stampmn2
sudo systemctl start stampmn3
sleep 30
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
