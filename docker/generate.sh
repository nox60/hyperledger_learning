#!/bin/bash

rm -rf hyperledger_data

cryptogen generate \
--config=./crypto-config.yaml \
--output="hyperledger_data/crypto-config"

echo 'Create genesis block'
# 创世区块
configtxgen -outputBlock hyperledger_data/orderer.genesis.block \
-profile TwoOrgsOrdererGenesis

echo 'Create tx'
# tx
configtxgen -profile TwoOrgsChannel \
-outputCreateChannelTx hyperledger_data/channel.tx \
-channelID mychannel

echo 'Generating anchor peer update for Org1MSP '

configtxgen -profile TwoOrgsChannel \
-outputAnchorPeersUpdate hyperledger_data/Org1MSPanchors.tx \
-channelID mychannel \
-asOrg Org1MSP

configtxgen -profile TwoOrgsChannel \
-outputAnchorPeersUpdate hyperledger_data/Org2MSPanchors.tx \
-channelID mychannel \
-asOrg Org2MSP


