#!/bin/bash

################################################################################
# Author:   Supawat A
# Date:     July, 16th 2018
# 
# Program:
#
#   Prepare Masternode on clean VPS with Ubuntu 16.04 
#
################################################################################

echo && echo 
echo "****************************************************************************"
echo "*                                                                          *"
echo "*  This script will install the package need for your STAMP Coin.          *"
echo "*                                                                          *"
echo "****************************************************************************"
echo && echo

# Install necessary stuff

cd ~
sudo locale-gen en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
sudo apt-get install -y nano htop git
sudo apt-get install -y software-properties-common
sudo apt-get install -y build-essential libtool autotools-dev pkg-config libssl-dev
sudo apt-get install -y libboost-all-dev
sudo apt-get install -y libevent-dev
sudo apt-get install -y libzmq3-dev
sudo apt-get install -y libminiupnpc-dev
sudo apt-get install -y autoconf
sudo apt-get install -y automake unzip
sudo add-apt-repository  -y  ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev
sudo apt-get install -y  curl wget git python3 python3-pip python-virtualenv

cd /var
sudo touch swap.img
sudo chmod 600 swap.img
sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
sudo mkswap /var/swap.img
sudo swapon /var/swap.img
sudo free
sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
cd

sudo apt-get install -y ufw
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow 43452/tcp
sudo ufw allow 43453/tcp
sudo ufw allow 43463/tcp
sudo ufw allow 43473/tcp
sudo ufw logging on
sudo ufw --force enable
sudo ufw status

echo "Your VPS for Masternode is now ready!"
