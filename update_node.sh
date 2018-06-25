#!/bin/bash

TARBALLURL="https://github.com/XDNA-Core/XDNA/releases/download/v1.0.1.0/ubuntu16.04-daemon.zip"
TARBALLNAME="ubuntu16.04-daemon.zip"
XDNAVERSION="1.0.1.0"

clear
echo "This script will update your masternode to version 1.0.1.0"
read -p "Press Ctrl-C to abort or any other key to continue. " -n1 -s
clear
echo "Please enter your password to enter administrator mode:"
sudo true
echo "Shutting down masternode..."
xdna-cli stop
echo "Installing XDNA 1.0.1.0"
mkdir ./xdna-temp && cd ./xdna-temp
wget $TARBALLURL
unzip $TARBALLNAME && mv bin xdna-$XDNAVERSION
yes | sudo cp -rf ./xdna-$XDNAVERSION/xdnad /usr/bin
yes | sudo cp -rf ./xdna-$XDNAVERSION/xdna-cli /usr/bin
cd ..
rm -rf ./xdna-temp
sed -i '/^addnode/d' ~/.xdna/xdna.conf
cat <<EOL >>  ~/.xdna/xdna.conf
EOL
echo "Restarting XDNA daemon..."
xdnad -daemon
clear
read -p "Please wait at least 5 minutes for the wallet to load, then press any key to continue." -n1 -s
clear
echo "Starting masternode..." # TODO: Need to wait for wallet to load before starting...
xdna-cli startmasternode local false
xdna-cli masternode status
