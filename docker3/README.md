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
# 创建通道
docker exec -it cli \
peer channel create -o orderer.ymy.com:7050 \
-c mychannel \
-f /opt/channel-artifacts/channel.tx \
--tls true \
--cafile /opt/crypto/ordererOrganizations/ymy.com/msp/tlscacerts/tlsca.ymy.com-cert.pem
```

```k
# cec组织加入通道
docker exec -it \
-e CORE_PEER_LOCALMSPID=cecMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.ymy.com/peers/peer0.cec.ymy.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.ymy.com/users/Admin@cec.ymy.com/msp \
-e CORE_PEER_ADDRESS=peer0.cec.ymy.com:7051 \
cli \
peer channel join -b mychannel.block
```

```dd
# aes组织加入通道
docker exec -it \
-e CORE_PEER_LOCALMSPID=aesMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/aes.ymy.com/peers/peer0.aes.ymy.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/aes.ymy.com/users/Admin@aes.ymy.com/msp \
-e CORE_PEER_ADDRESS=peer0.aes.ymy.com:7051 \
cli \
peer channel join -b mychannel.block
```

```ss
# hos组织加入通道
docker exec -it \
-e CORE_PEER_LOCALMSPID=hosMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/hos.ymy.com/peers/peer0.hos.ymy.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/hos.ymy.com/users/Admin@hos.ymy.com/msp \
-e CORE_PEER_ADDRESS=peer0.hos.ymy.com:7051 \
cli \
peer channel join -b mychannel.block
```

```d
# gov组织加入通道
docker exec -it \
-e CORE_PEER_LOCALMSPID=govMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/gov.ymy.com/peers/peer0.gov.ymy.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/gov.ymy.com/users/Admin@gov.ymy.com/msp \
-e CORE_PEER_ADDRESS=peer0.gov.ymy.com:7051 \
cli \
peer channel join -b mychannel.block
```

```2
docker exec -it \
-e CORE_PEER_LOCALMSPID=aesMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/aes.ymy.com/peers/peer0.aes.ymy.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/aes.ymy.com/users/Admin@aes.ymy.com/msp \
-e CORE_PEER_ADDRESS=peer0.aes.ymy.com:7051 \
cli \
peer channel list
```

```dd
docker exec -it \
-e CORE_PEER_LOCALMSPID=hosMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/hos.ymy.com/peers/peer0.hos.ymy.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/hos.ymy.com/users/Admin@hos.ymy.com/msp \
-e CORE_PEER_ADDRESS=peer0.hos.ymy.com:7051 \
cli \
peer channel list
```

```dd2
# 安装合约
docker exec -it \
-e CORE_PEER_LOCALMSPID=cecMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.ymy.com/peers/peer0.cec.ymy.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.ymy.com/users/Admin@cec.ymy.com/msp \
-e CORE_PEER_ADDRESS=peer0.cec.ymy.com:7051 \
cli \
peer chaincode install \
-n mychaincode \
-v 1.0 \
-l golang \
-p mychaincode
```

```ddd
# 初始化合约
docker exec -it \
cli \
peer chaincode instantiate -o orderer.ymy.com:7050 \
--tls true --cafile /opt/crypto/ordererOrganizations/ymy.com/orderers/orderer.ymy.com/msp/tlscacerts/tlsca.ymy.com-cert.pem \
-C mychannel \
-n mychaincode \
-l golang \
-v 1.0 \
-c '{"Args":["init","a","100","b","200"]}' -P 'OR ('\''cecMSP.peer'\'')'
```

```dd
# 查看已经安装的智能合约
# view installed chain codes of cec peer0
docker exec -it \
-e CORE_PEER_LOCALMSPID=cecMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.ymy.com/peers/peer0.cec.ymy.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.ymy.com/users/Admin@cec.ymy.com/msp \
-e CORE_PEER_ADDRESS=peer0.cec.ymy.com:7051 \
cli \
peer chaincode list \
-C mychannel \
--installed
```

```dd44
# 查看已经实例化的智能合约
docker exec -it \
-e CORE_PEER_LOCALMSPID=cecMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.ymy.com/peers/peer0.cec.ymy.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.ymy.com/users/Admin@cec.ymy.com/msp \
-e CORE_PEER_ADDRESS=peer0.cec.ymy.com:7051 \
cli \
peer chaincode list \
-C mychannel \
--instantiated
```

```kk
# view installed chain codes of cec peer0
docker exec -it \
-e CORE_PEER_LOCALMSPID=cecMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.ymy.com/peers/peer0.cec.ymy.com/tls/ca.crt \
-e CORE_PEER_TLS_CERT_FILE=/opt/crypto/peerOrganizations/cec.ymy.com/peers/peer0.cec.ymy.com/tls/server.crt \
-e CORE_PEER_TLS_KEY_FILE=/opt/crypto/peerOrganizations/cec.ymy.com/peers/peer0.cec.ymy.com/tls/server.key \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.ymy.com/users/Admin@cec.ymy.com/msp \
-e CORE_PEER_ADDRESS=peer0.cec.ymy.com:7051 \
cli \
peer chaincode list \
-C mychannel \
--installed
```

```ss
# view installed chain codes
docker exec -it \
-e CORE_PEER_LOCALMSPID=aesMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/aes.ymy.com/peers/peer0.aes.ymy.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/aes.ymy.com/users/Admin@aes.ymy.com/msp \
-e CORE_PEER_ADDRESS=peer0.aes.ymy.com:7051 \
cli \
peer chaincode list \
-C mychannel \
--installed
```

```ddkk
docker exec -it \
-e FABRIC_LOGGING_SPEC="INFO" \
-e CORE_PEER_LOCALMSPID=cecMSP  \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.ymy.com/peers/peer0.cec.ymy.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.ymy.com/users/Admin@cec.ymy.com/msp \
-e CORE_PEER_ADDRESS=peer0.cec.ymy.com:7051 \
cli \
peer chaincode invoke \
-o orderer.ymy.com:7050 \
-C mychannel \
-n mychaincode \
-c '{"Args":["add","a","10"]}' \
--tls true \
--cafile /opt/crypto/ordererOrganizations/ymy.com/orderers/orderer.ymy.com/msp/tlscacerts/tlsca.ymy.com-cert.pem
```

```dd
docker exec -it cli \
peer chaincode invoke \
-o orderer.ymy.com:7050 \
-C mychannel \
-n mychaincode \
-c '{"Args":["query","a"]}' \
--tls true \
--cafile /opt/crypto/ordererOrganizations/ymy.com/orderers/orderer.ymy.com/msp/tlscacerts/tlsca.ymy.com-cert.pem
```
