#!/bin/bash

rm -rf /root/codes/temp/crypto-config
rm -rf /root/codes/temp/orderer_ledger
rm -rf /root/codes/temp/peer_ledger
rm -rf /root/codes/temp/channel.tx
rm -rf /root/codes/temp/genesis_block.pb

ps -ef | grep orderer | grep -v grep | awk '{print $2}' | xargs kill -9
ps -ef | grep peer | grep -v grep | awk '{print $2}' | xargs kill -9

cryptogen generate \
--config=./crypto-config.yaml \
--output="crypto-config"

echo 'Create genesis block'
# 创世区块
configtxgen -outputBlock genesis_block.pb \
-profile TwoOrgsOrdererGenesis 

echo 'Create tx'
# tx
configtxgen -profile TwoOrgsChannel \
-outputCreateChannelTx /root/codes/temp/channel.tx \
-channelID mychannel

echo 'start orderer'
# start orderer
nohup orderer > orderer.log   2>&1 &

sleep 12

echo 'start peer'
nohup peer node start > peer.log 2>&1 &

sleep 12

echo 'create channel'

# create channel
peer channel create -o orderer.test.com:7050 \
-c mychannel \
-f /root/codes/temp/channel.tx \
--tls true \
--cafile /root/codes/temp/crypto-config/ordererOrganizations/test.com/tlsca/tlsca.test.com-cert.pem


