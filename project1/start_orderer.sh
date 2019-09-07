#!/bin/bash

rm -rf hyperledger_data

ps -ef | grep orderer | grep -v grep | awk '{print $2}' | xargs kill -9

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
