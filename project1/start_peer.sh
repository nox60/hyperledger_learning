#!/bin/bash

# 此处配置SCP无密码方式，去ORDERER机器上获取hyperledger_data目录

ps -ef | grep peer | grep -v grep | awk '{print $2}' | xargs kill -9

echo 'start peer'
nohup peer node start > hyperledger_data/peer.log 2>&1 &

sleep 2
echo 'create channel'

# create channel
peer channel create \
-o orderer.test.com:7050 \
-c mychannel \
-f hyperledger_data/channel.tx \
--tls true \
--outputBlock hyperledger_data/mychannel.block \
--cafile hyperledger_data/crypto-config/ordererOrganizations/test.com/tlsca/tlsca.test.com-cert.pem
