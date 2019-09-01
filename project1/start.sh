#!/bin/bash

rm -rf hyperledger_data

ps -ef | grep orderer | grep -v grep | awk '{print $2}' | xargs kill -9
ps -ef | grep peer | grep -v grep | awk '{print $2}' | xargs kill -9

cryptogen generate \
--config=./crypto-config.yaml \
--output="hyperledger_data/crypto-config"


echo 'Create genesis block'
# 创世区块
configtxgen -outputBlock hyperledger_data/genesis_block.pb \
-profile TwoOrgsOrdererGenesis 

echo 'Create tx'
# tx
configtxgen -profile TwoOrgsChannel \
-outputCreateChannelTx hyperledger_data/channel.tx \
-channelID mychannel

echo 'start orderer'
# start orderer
nohup orderer > hyperledger_data/orderer.log   2>&1 &

sleep 2
echo 'start peer'
nohup peer node start > hyperledger_data/peer.log 2>&1 &

sleep 2
echo 'create channel'

# 官方例子中cafile 路径 ordererOrganizations/test.com/msp/tlscacerts/tlsca.test.com-cert.pem
# create channel
peer channel create -o orderer.test.com:7050 \
-c mychannel \
-f hyperledger_data/channel.tx \
--tls true \
--outputBlock hyperledger_data/mychannel.block \
--cafile hyperledger_data/crypto-config/ordererOrganizations/test.com/msp/tlscacerts/tlsca.test.com-cert.pem


# 官方例子
peer channel create \
-o orderer.example.com:7050 \
-c $CHANNEL_NAME \
-f ./channel-artifacts/channel.tx \
--tls \
--cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
