#!/bin/bash
clear

# Set these to change the version of XDNA to install
TARBALLURL="https://github.com/XDNA-Core/XDNA/releases/download/v1.0.1.0/ubuntu16.04-daemon.zip"
TARBALLNAME="ubuntu16.04-daemon.zip"
XDNAVERSION="1.0.1.0"
# Get our current IP
EXTERNALIP=`dig +short myip.opendns.com @resolver1.opendns.com`
clear

STRING1="Make sure you double check before hitting enter! Only one shot at these!"
STRING2="If you found this helpful, please donate: "
STRING3="XHEUZuevQUEuoPoiJSfMsNtV9DCkqZJhGP"
STRING4="Updating system and installing required packages."
STRING5="Switching to Aptitude"
STRING6="Some optional installs"
STRING7="Starting your masternode"
STRING8="Now, you need to finally start your masternode in the following order:"
STRING9="Go to your windows wallet and from the Control wallet Console please enter"
STRING10="startmasternode alias false <mymnalias>"
STRING11="where <mymnalias> is the name of your masternode alias (without brackets)"
STRING12="once completed please return to VPS and press the space bar"
STRING13=""
STRING14="Please Wait a minimum of 5 minutes before proceeding, the node wallet must be synced"

echo $STRING1

read -e -p "Masternode Private Key (e.g. 88slDBwobwx6u9NfBwjS6y7dL8f6Rtnv31wwj1qJPNALYNnLt8 # THE KEY YOU GENERATED EARLIER) : " key
read -e -p "Install Fail2ban? [Y/n] : " install_fail2ban
read -e -p "Install UFW and configure ports? [Y/n] : " UFW

clear
echo $STRING2
echo $STRING13
echo $STRING3
echo $STRING13
echo $STRING4
sleep 10

# update package and upgrade Ubuntu
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y autoremove
sudo apt-get -y install wget nano htop
sudo apt-get -y install build-essential && sudo apt-get -y install libtool autotools-dev autoconf automake && sudo apt-get -y install libssl-dev && sudo apt-get -y install libboost-all-dev && sudo apt install software-properties-common && sudo add-apt-repository ppa:bitcoin/bitcoin && sudo apt update && sudo apt-get -y install libdb4.8-dev && sudo apt-get -y install libdb4.8++-dev && sudo apt-get -y install libminiupnpc-dev && sudo apt-get -y install libqt4-dev libprotobuf-dev protobuf-compiler && sudo apt-get -y install libqrencode-dev && sudo apt-get -y install git && sudo apt-get -y install pkg-config
sudo apt-get -y install libboost-all-dev libdb4.8-dev libdb4.8++-dev libminiupnpc-dev libzmq3-dev
clear
echo $STRING5
sudo apt-get -y install aptitude

#Generating Random Passwords
password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
password2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

echo $STRING6
if [[ ("$install_fail2ban" == "y" || "$install_fail2ban" == "Y" || "$install_fail2ban" == "") ]]; then
  cd ~
  sudo aptitude -y install fail2ban
  sudo service fail2ban restart
fi
if [[ ("$UFW" == "y" || "$UFW" == "Y" || "$UFW" == "") ]]; then
  sudo apt-get -y install ufw
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow ssh
  sudo ufw allow 1945/tcp
  sudo ufw enable -y
fi

#Install XDNA Daemon
wget $TARBALLURL
sudo unzip $TARBALLNAME && mv bin xdna-$XDNAVERSION
sudo rm $TARBALLNAME
sudo cp ./xdna-$XDNAVERSION/xdnad /usr/bin
sudo cp ./xdna-$XDNAVERSION/xdna-cli /usr/bin
sudo cp ./xdna-$XDNAVERSION/xdna-tx /usr/bin
xdnad -daemon
clear

#Setting up coin
clear
echo $STRING2
echo $STRING13
echo $STRING3
echo $STRING13
echo $STRING4
sleep 10

#Create xdna.conf
echo '
rpcuser='$password'
rpcpassword='$password2'
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
logtimestamps=1
maxconnections=256
externalip='$EXTERNALIP'
bind='$EXTERNALIP':1945
masternodeaddr='$EXTERNALIP':1945
masternodeprivkey='$key'
masternode=1
' | sudo -E tee ~/.xdna/xdna.conf >/dev/null 2>&1
sudo chmod 0600 ~/.xdna/xdna.conf

#Starting coin
cat > /etc/systemd/system/xdnad.service << EOL
[Unit]
Description=XDNA Core daemon
After=network.target
[Service]
Type=forking
User=${USER}
WorkingDirectory=${USERHOME}
ExecStart=/usr/local/bin/xdnad -conf=${USERHOME}/.xdna/xdna.conf -datadir=${USERHOME}/.xdna
ExecStop=/usr/local/bin/xdna-cli -conf=${USERHOME}/.xdna/xdna.conf -datadir=${USERHOME}/.xdna stop
Restart=on-failure
RestartSec=1m
StartLimitIntervalSec=5m
StartLimitInterval=5m
StartLimitBurst=3
[Install]
WantedBy=multi-user.target
EOL
systemctl enable xdnad
echo "Starting xdnad..."
systemctl start xdnad

clear
echo $STRING2
echo $STRING13
echo $STRING3
echo $STRING13
echo $STRING4
sleep 10
echo $STRING7
echo $STRING13
echo $STRING8
echo $STRING13
echo $STRING9
echo $STRING13
echo $STRING10
echo $STRING13
echo $STRING11
echo $STRING13
echo $STRING12
echo $STRING14
sleep 5m

read -p "Press any key to continue... " -n1 -s
xdna-cli startmasternode local false
xdna-cli masternode status
