#!/bin/bash

rm -rf hyperledger_data

cryptogen generate \
--config=./crypto-config.yaml \
--output="hyperledger_data/crypto-config"

echo 'Create genesis block'

# 创世区块
configtxgen -outputBlock hyperledger_data/orderer.genesis.block \
-channelID byfn-sys-channel \
-profile TwoOrgsOrdererGenesis

echo 'Create tx'
# tx
configtxgen -profile TwoOrgsChannel \
-outputCreateChannelTx hyperledger_data/channel.tx \
-channelID mychannel

echo 'Generating anchor peer update for cecMSP '

configtxgen -profile TwoOrgsChannel \
-outputAnchorPeersUpdate hyperledger_data/cecMSPanchors.tx \
-channelID mychannel \
-asOrg cecMSP

configtxgen -profile TwoOrgsChannel \
-outputAnchorPeersUpdate hyperledger_data/ia3MSPanchors.tx \
-channelID mychannel \
-asOrg ia3MSP

configtxgen -profile TwoOrgsChannel \
-outputAnchorPeersUpdate hyperledger_data/ic3MSPanchors.tx \
-channelID mychannel \
-asOrg ic3MSP

configtxgen -profile TwoOrgsChannel \
-outputAnchorPeersUpdate hyperledger_data/govMSPanchors.tx \
-channelID mychannel \
-asOrg govMSP
