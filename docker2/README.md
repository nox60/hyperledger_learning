首先需要执行同级目录下的：
```aa
generate.sh
```
脚本文件。

然后执行：
```bb
start.sh
```
拉起所有容器。


创建通道
```aa
peer channel create -o orderer.dams.com:7050 \
-c mychannel \
-f /opt/channel-artifacts/channel.tx \
--tls true --cafile \
/opt/crypto/ordererOrganizations/dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem
```

加入通道
```k
export CORE_PEER_LOCALMSPID=cecMSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/Admin@cec.dams.com/msp
export CORE_PEER_ADDRESS=peer0.cec.dams.com:7051
peer channel join -b mychannel.block
```

```dd
export CORE_PEER_LOCALMSPID=ia3MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/ia3.dams.com/peers/peer0.ia3.dams.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/ia3.dams.com/users/Admin@ia3.dams.com/msp
export CORE_PEER_ADDRESS=peer0.ia3.dams.com:7151
peer channel join -b mychannel.block
```

```ss
export CORE_PEER_LOCALMSPID=ic3MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/ic3.dams.com/peers/peer0.ic3.dams.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/ic3.dams.com/users/Admin@ic3.dams.com/msp
export CORE_PEER_ADDRESS=peer0.ic3.dams.com:7251
peer channel join -b mychannel.block
```

```d
export CORE_PEER_LOCALMSPID=govMSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/gov.dams.com/peers/peer0.gov.dams.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/gov.dams.com/users/Admin@gov.dams.com/msp
export CORE_PEER_ADDRESS=peer0.gov.dams.com:7351
peer channel join -b mychannel.block
```


```d
export CORE_PEER_LOCALMSPID=cecMSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/Admin@cec.dams.com/msp
export CORE_PEER_ADDRESS=peer0.cec.dams.com:7051
peer channel update \
-o orderer.dams.com:7050 \
-c mychannel \
-f /opt/channel-artifacts/cecMSPanchors.tx \
--tls true \
--cafile /opt/crypto/ordererOrganizations/dams.com/orderers/orderer.dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem
```

```2
export CORE_PEER_LOCALMSPID=ia3MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/ia3.dams.com/peers/peer0.ia3.dams.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/ia3.dams.com/users/Admin@ia3.dams.com/msp
export CORE_PEER_ADDRESS=peer0.ia3.dams.com:7151
peer channel list
```

```dd
export CORE_PEER_LOCALMSPID=ic3MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/ic3.dams.com/peers/peer0.ic3.dams.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/ic3.dams.com/users/Admin@ic3.dams.com/msp
export CORE_PEER_ADDRESS=peer0.ic3.dams.com:7251
peer channel list
```

```dd
export CORE_PEER_LOCALMSPID=cecMSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/Admin@cec.dams.com/msp
export CORE_PEER_ADDRESS=peer0.cec.dams.com:7051
peer chaincode install \
-n authority \
-v 1.0 \
-l golang \
-p authority
```

```ddd
peer chaincode instantiate -o orderer.dams.com:7050 \
--tls true --cafile /opt/crypto/ordererOrganizations/dams.com/orderers/orderer.dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem \
-C mychannel \
-n authority \
-l golang \
-v 1.0 \
-c '{"Args":["init","a","100","b","200"]}' -P 'AND ('\''cecMSP.peer'\'','\''ia3MSP.peer'\'')'
```

```dd
# view installed chain codes of cec peer0
export CORE_PEER_LOCALMSPID=cecMSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/Admin@cec.dams.com/msp
export CORE_PEER_ADDRESS=peer0.cec.dams.com:7051
peer chaincode list \
-C mychannel \
--installed
```

```dd
# view instantiated chain codes of cec peer0
export CORE_PEER_LOCALMSPID=cecMSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/Admin@cec.dams.com/msp
export CORE_PEER_ADDRESS=peer0.cec.dams.com:7051
peer chaincode list \
-C mychannel \
--instantiated
```


```kk
# view installed chain codes of cec peer0
export CORE_PEER_LOCALMSPID=cecMSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt
export CORE_PEER_TLS_CERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/server.key
export CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/Admin@cec.dams.com/msp
export CORE_PEER_ADDRESS=peer0.cec.dams.com:7051
peer chaincode list \
-C mychannel \
--installed
```

```ss
# view installed chain codes
export CORE_PEER_LOCALMSPID=ia3MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/ia3.dams.com/peers/peer0.ia3.dams.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/ia3.dams.com/users/Admin@ia3.dams.com/msp
export CORE_PEER_ADDRESS=peer0.ia3.dams.com:7151
peer chaincode list \
-C mychannel \
--installed
```


```dd
Sending invoke transaction on peer0.cec peer0.ia3...
+ peer chaincode invoke -o orderer.dams.com:7050 --tls true 
--cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/dams.com/orderers/orderer.dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem 
-C mychannel -n mycc 
--peerAddresses peer0.cec.dams.com:7051 
--tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt 
--peerAddresses peer0.ia3.dams.com:9051 
--tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ia3.dams.com/peers/peer0.ia3.dams.com/tls/ca.crt 
-c '{"Args":["invoke","a","b","10"]}'
```


```dd
#-----
export CORE_PEER_LOCALMSPID=cecMSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/Admin@cec.dams.com/msp
export CORE_PEER_ADDRESS=peer0.cec.dams.com:7051
peer chaincode invoke -C mychannel \
-n authority \
-c '{"Args":["add","add","b","10"]}'
```

```dd
#-----
export CORE_PEER_LOCALMSPID=cecMSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/Admin@cec.dams.com/msp
export CORE_PEER_ADDRESS=peer0.cec.dams.com:7051
peer chaincode query -C mychannel \
-n authority \
-c '{"Args":["query","b"]}'
```
