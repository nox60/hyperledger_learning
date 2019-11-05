#!/bin/bash

rm -rf hyperledger_data

cryptogen generate \
--config=./crypto-config.yaml \
--output="hyperledger_data/crypto-config"

echo 'Create genesis block'

# 创世区块
configtxgen -outputBlock hyperledger_data/orderer.genesis.block \
-channelID ymy-sys-channel \
-profile FourOrgsOrdererGenesis

echo 'Create tx'
# tx
configtxgen -profile FourOrgsChannel \
-outputCreateChannelTx hyperledger_data/channel.tx \
-channelID mychannel