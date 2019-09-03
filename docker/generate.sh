#!/bin/bash

rm -rf hyperledger_data

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
