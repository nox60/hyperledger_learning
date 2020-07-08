# 本文目标

配置软连接：

```mv
ln -s /root/codes/hyperledger_learning/docker3 /opt/local/codes/docker_ymy
```

## 生成相关证书文件

执行同级目录下的命令：
```aa
generate.sh
```

### 执行命令拉起所有容器：
```bb
start.sh
```

### 通过cli容器执行下列命令
```aa
docker run --rm -it \
    --name create.channel.client \
    --network ymy-net \
    -e CORE_PEER_LOCALMSPID=cecMSP \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.ymy.com/peers/peer0.cec.ymy.com/tls/ca.crt \
    -e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.ymy.com/users/Admin@cec.ymy.com/msp \
    -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config:/opt/crypto \
    -v /opt/local/codes/docker_ymy/hyperledger_data:/opt/channel-artifacts \
    hyperledger/fabric-tools:1.4.3 \
    peer channel create --outputBlock /opt/channel-artifacts/mychannel.block -o orderer.ymy.com:7050 \
    -c mychannel \
    -f /opt/channel-artifacts/channel.tx \
    --tls true \
    --cafile /opt/crypto/ordererOrganizations/ymy.com/msp/tlscacerts/tlsca.ymy.com-cert.pem
```

```k
docker run --rm -it \
    --name cec.join.channel.admin.client \
    --network ymy-net \
    -e CORE_PEER_LOCALMSPID=cecMSP \
    -e CORE_PEER_TLS_ENABLED="true"  \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.ymy.com/peers/peer0.cec.ymy.com/tls/ca.crt \
    -e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.ymy.com/users/Admin@cec.ymy.com/msp \
    -e CORE_PEER_ADDRESS=peer0.cec.ymy.com:7051 \
    -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config:/opt/crypto \
    -v /opt/local/codes/docker_ymy/hyperledger_data:/opt/channel-artifacts \
    hyperledger/fabric-tools:1.4.3 \
    peer channel join -b /opt/channel-artifacts/mychannel.block \
    --tls true \
    --cafile /opt/crypto/ordererOrganizations/ymy.com/msp/tlscacerts/tlsca.ymy.com-cert.pem
```

```dd
# aes组织加入通道
docker run --rm -it \
    --name aes.join.channel.admin.client \
    --network ymy-net \
    -e CORE_PEER_LOCALMSPID=aesMSP \
    -e CORE_PEER_TLS_ENABLED="true"  \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/aes.ymy.com/peers/peer0.aes.ymy.com/tls/ca.crt \
    -e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/aes.ymy.com/users/Admin@aes.ymy.com/msp \
    -e CORE_PEER_ADDRESS=peer0.aes.ymy.com:7051 \
    -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config:/opt/crypto \
    -v /opt/local/codes/docker_ymy/hyperledger_data:/opt/channel-artifacts \
    hyperledger/fabric-tools:1.4.3 \
    peer channel join -b /opt/channel-artifacts/mychannel.block \
    --tls true \
    --cafile /opt/crypto/ordererOrganizations/ymy.com/msp/tlscacerts/tlsca.ymy.com-cert.pem
```

```dd
# hos组织加入通道
docker run --rm -it \
    --name hos.join.channel.admin.client \
    --network ymy-net \
    -e CORE_PEER_LOCALMSPID=hosMSP \
    -e CORE_PEER_TLS_ENABLED="true"  \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/hos.ymy.com/peers/peer0.hos.ymy.com/tls/ca.crt \
    -e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/hos.ymy.com/users/Admin@hos.ymy.com/msp \
    -e CORE_PEER_ADDRESS=peer0.hos.ymy.com:7051 \
    -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config:/opt/crypto \
    -v /opt/local/codes/docker_ymy/hyperledger_data:/opt/channel-artifacts \
    hyperledger/fabric-tools:1.4.3 \
    peer channel join -b /opt/channel-artifacts/mychannel.block \
    --tls true \
    --cafile /opt/crypto/ordererOrganizations/ymy.com/msp/tlscacerts/tlsca.ymy.com-cert.pem
```

```dd
# gov组织加入通道
docker run --rm -it \
    --name gov.join.channel.admin.client \
    --network ymy-net \
    -e CORE_PEER_LOCALMSPID=govMSP \
    -e CORE_PEER_TLS_ENABLED="true"  \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/gov.ymy.com/peers/peer0.gov.ymy.com/tls/ca.crt \
    -e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/gov.ymy.com/users/Admin@gov.ymy.com/msp \
    -e CORE_PEER_ADDRESS=peer0.gov.ymy.com:7051 \
    -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config:/opt/crypto \
    -v /opt/local/codes/docker_ymy/hyperledger_data:/opt/channel-artifacts \
    hyperledger/fabric-tools:1.4.3 \
    peer channel join -b /opt/channel-artifacts/mychannel.block \
    --tls true \
    --cafile /opt/crypto/ordererOrganizations/ymy.com/msp/tlscacerts/tlsca.ymy.com-cert.pem
```










