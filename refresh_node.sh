#!/bin/bash
clear

xdna-cli stop

sleep 10

rm -rf ~/.xdna/blocks
rm -rf ~/.xdna/database
rm -rf ~/.xdna/chainstate
rm -rf ~/.xdna/peers.dat

cp ~/.xdna/xdna.conf ~/.xdna/xdna.conf.backup
sed -i '/^addnode/d' ~/.xdna/xdna.conf
cat <<EOL >>  ~/.xdna/xdna.conf
EOL

xdnad
