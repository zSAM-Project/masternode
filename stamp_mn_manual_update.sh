#!/bin/bash

################################################################################
# Author:   Supawat A
# Date:     August, 30 2018
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

echo "Enter Masternode User Name (stampmn1, stampmn2 or stampmn3), followed by [ENTER]:"
read STAMP_USERNAME
export STAMP_USERNAME=$STAMP_USERNAME

cd ~
sudo wget https://github.com/zSAM-Project/stamp/releases/download/masternode/stamp.tar.gz
sudo tar -xzvf stamp.tar.gz

sudo systemctl stop ${STAMP_USERNAME}
sleep 15

sudo cp ./stamp/stamp* /home/${STAMP_USERNAME}/

sudo rm ./stamp.tar.gz
sudo rm -rf ./stamp


sudo wget https://github.com/zSAM-Project/stamp/releases/download/v2.4.1.1/stamp-chain-40900-bootstrap.dat.zip
sudo unzip stamp-chain-40900-bootstrap.dat.zip
sudo rm ./stamp-chain-40900-bootstrap.dat.zip

sudo rm -rf /home/${STAMP_USERNAME}/.stamp/blocks
sudo rm -rf /home/${STAMP_USERNAME}/.stamp/chainstate
sudo rm -rf /home/${STAMP_USERNAME}/.stamp/zerocoin
sudo rm -rf /home/${STAMP_USERNAME}/.stamp/sporks
sudo rm /home/${STAMP_USERNAME}/.stamp/peers.dat
sudo rm /home/${STAMP_USERNAME}/.stamp/banlist.dat 

sudo cp -r /root/bootstrap.dat /home/${STAMP_USERNAME}/.stamp/

sudo chown -R ${STAMP_USERNAME}:${STAMP_USERNAME} /home/${STAMP_USERNAME}/.stamp/bootstrap.dat

rm bootstrap.dat

sudo systemctl start ${STAMP_USERNAME}
sleep 30

INFO1=`sudo -H -u ${STAMP_USERNAME} /home/${STAMP_USERNAME}/stamp-cli getinfo`

echo " "
echo " "
echo "========================================="
echo "STAMP Coin ${STAMP_USERNAME} updated!    "
echo "========================================="
echo "${INFO1}"

exit 0
