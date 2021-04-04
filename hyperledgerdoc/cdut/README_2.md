# 创建网络

docker network rm bc-net

docker network create --subnet=172.18.0.0/16 bc-net

# 用docker 启动一个ca server
```用docker启动一个ca-server
docker rm -f ca.com
docker run \
  -it -d \
  --name ca.com \
      --network bc-net \
      -e FABRIC_CA_HOME="/opt/ca-home" \
      -e FABRIC_CA_SERVER_CA_NAME="ca.com" \
      -e FABRIC_CA_SERVER_CSR_CN=ca.com \
      -e FABRIC_CA_SERVER_CSR_HOSTS=ca.com \
      -e FABRIC_CA_SERVER_PORT=7054 \
      -v /root/temp/test-ca-home:/opt/ca-home \
      --entrypoint="fabric-ca-server" hyperledger/fabric-ca:1.4.3  start  -b admin:adminpw -d
```

# 把ca的admin的msp拉出来
```go
docker run --rm -it \
    --name enroll.test.ca.client \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client enroll \
    -u http://admin:adminpw@ca.com:7054
```

mv /root/temp/test-ca-admin-home/msp/cacerts/* /root/temp/test-ca-admin-home/msp/cacerts/ca.pem

mkdir -p /root/temp/test-ca-admin-home/msp/admincerts


# 创建config.yaml文件

```shell
cat>/root/temp/test-ca-admin-home/msp/config.yaml<<EOF
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: orderer
EOF
```

列出affiliation
```go
#fabric-ca-client affiliation add org3.department1
docker run --rm -it \
    --name add-affiliation \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client affiliation list
```

先注册affiliation
```go
#fabric-ca-client affiliation add org3.department1
docker run --rm -it \
    --name add-affiliation \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client affiliation add ordererOrg
```

增加org3组织
```go
#fabric-ca-client affiliation add org3.department1
docker run --rm -it \
    --name add-affiliation \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client  affiliation add org3
```

增加org3组织的department1
```go
#fabric-ca-client affiliation add org3.department1
docker run --rm -it \
    --name add-affiliation \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client  affiliation add org3.department1
```

```go
docker run --rm -it \
    --name add-affiliation \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client affiliation add ordererOrg.ordererMSP
```

0. 注册orderer
```go
rm -rf /root/temp/order-home
docker run --rm -it \
    --name register.orderer \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client register \
    --id.name orderer.com --id.type orderer \
    --id.affiliation ordererOrg \
    --id.secret ordererpw 
```

拉取orderer的tls
```go
docker run --rm -it \
  --name enroll.orderer \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/opt/orderer-home \
      -v /root/temp/orderer-home/tls:/opt/orderer-home \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      --enrollment.profile tls --csr.hosts orderer.com \
      -u http://orderer.com:ordererpw@ca.com:7054
```

修改tls中的私钥文件名
```shell script
mv /root/temp/orderer-home/tls/msp/keystore/* /root/temp/orderer-home/tls/msp/keystore/server.key
mv /root/temp/orderer-home/tls/msp/signcerts/* /root/temp/orderer-home/tls/msp/signcerts/server.crt
mv /root/temp/orderer-home/tls/msp/tlscacerts/* /root/temp/orderer-home/tls/msp/tlscacerts/ca.crt
```

# 拉取order的msp
```go
docker run --rm -it \
  --name enroll.cec.orderer \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/opt/orderer-home-msp \
      -v /root/temp/orderer-home/msp:/opt/orderer-home-msp \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -M /opt/orderer-home-msp/msp \
      -u http://orderer.com:ordererpw@ca.com:7054
```
mv /root/temp/orderer-home/msp/msp/cacerts/* /root/temp/orderer-home/msp/msp/cacerts/ca.pem
mkdir -p /root/temp/orderer-home/msp/msp/tlscacerts
cp /root/temp/orderer-home/msp/msp/cacerts/ca.pem  /root/temp/orderer-home/msp/msp/tlscacerts/

# 给orderer节点创建config.yaml文件

```shell
cat>/root/temp/orderer-home/msp/msp/config.yaml<<EOF
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: orderer
EOF
```

mkdir -p /root/temp/orderer-home/msp/msp/admincerts


接下来要测试的，

1. 是通过这个CA注册一个peer，然后和这个peer通信的时候，关掉这个ca，看看root ca是否能验证成功。这里好像是不需要，因为generate出来的各种ca证书，也是没有root ca服务供验证的
完成上面的注册peer, 然后把peer的msp拉下来。启动peer

注册org1.peer0
```go
rm -rf /root/temp/org1/peer0-home
docker run --rm -it \
    --name register.org1.peer0 \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client register \
    --id.name org1.peer0 --id.type peer  --id.secret peerpw 
```

拉取tls
```go
docker run --rm -it \
  --name enroll.cec.org1.peer0 \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/opt/peer0-home \
      -v /root/temp/org1/peer0-home/tls:/opt/peer0-home \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      --enrollment.profile tls --csr.hosts org1.peer0.com \
      -u http://org1.peer0:peerpw@ca.com:7054
```

修改tls中的私钥文件名
```shell script
mv /root/temp/org1/peer0-home/tls/msp/keystore/* /root/temp/org1/peer0-home/tls/msp/keystore/server.key
mv /root/temp/org1/peer0-home/tls/msp/signcerts/* /root/temp/org1/peer0-home/tls/msp/signcerts/server.crt
mv /root/temp/org1/peer0-home/tls/msp/tlscacerts/* /root/temp/org1/peer0-home/tls/msp/tlscacerts/ca.crt
```

拉取msp
```go
docker run --rm -it \
  --name enroll.cec.org1.peer0 \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/opt/peer0-home-msp \
      -v /root/temp/org1/peer0-home/msp:/opt/peer0-home-msp \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -M /opt/peer0-home-msp/msp \
      -u http://org1.peer0:peerpw@ca.com:7054
```

mv /root/temp/org1/peer0-home/msp/msp/cacerts/* /root/temp/org1/peer0-home/msp/msp/cacerts/ca.pem
mkdir -p /root/temp/org1/peer0-home/msp/msp/tlscacerts
cp /root/temp/org1/peer0-home/msp/msp/cacerts/ca.pem  /root/temp/org1/peer0-home/msp/msp/tlscacerts/

# 给peer0节点创建 config.yaml文件
```shell
cat>/root/temp/org1/peer0-home/msp/msp/config.yaml<<EOF
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: orderer
EOF
```





注册org2.peer0
```go
rm -rf /root/temp/org2/peer0-home
docker run --rm -it \
    --name register.org2.peer0 \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client register \
    --id.name org2.peer0 --id.type peer  --id.secret peerpw 
```

拉取tls
```go
docker run --rm -it \
  --name enroll.cec.org2.peer0 \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/opt/peer0-home \
      -v /root/temp/org2/peer0-home/tls:/opt/peer0-home \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      --enrollment.profile tls --csr.hosts org2.peer0.com \
      -u http://org2.peer0:peerpw@ca.com:7054
```

修改tls中的私钥文件名
```shell script
mv /root/temp/org2/peer0-home/tls/msp/keystore/* /root/temp/org2/peer0-home/tls/msp/keystore/server.key
mv /root/temp/org2/peer0-home/tls/msp/signcerts/* /root/temp/org2/peer0-home/tls/msp/signcerts/server.crt
mv /root/temp/org2/peer0-home/tls/msp/tlscacerts/* /root/temp/org2/peer0-home/tls/msp/tlscacerts/ca.crt
```

拉取msp
```go
docker run --rm -it \
  --name enroll.cec.org2.peer0 \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/opt/peer0-home-msp \
      -v /root/temp/org2/peer0-home/msp:/opt/peer0-home-msp \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -M /opt/peer0-home-msp/msp \
      -u http://org2.peer0:peerpw@ca.com:7054
```

mv /root/temp/org2/peer0-home/msp/msp/cacerts/* /root/temp/org2/peer0-home/msp/msp/cacerts/ca.pem
mkdir -p /root/temp/org2/peer0-home/msp/msp/tlscacerts
cp /root/temp/org2/peer0-home/msp/msp/cacerts/ca.pem  /root/temp/org2/peer0-home/msp/msp/tlscacerts/

# 给peer0节点创建 config.yaml文件
```shell
cat>/root/temp/org2/peer0-home/msp/msp/config.yaml<<EOF
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: orderer
EOF
```



# 生成configtx.yaml文件 ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！

-1. 各种msp生成完毕之后，生成创世区块
```go
docker run --rm -it \
  --name configtxgen.generate.files \
      --network bc-net \
      -e FABRIC_CFG_PATH=/etc/hyperledger/ \
      -v /root/temp/:/opt/data \
      -v /root/temp/configtx.yaml:/etc/hyperledger/configtx.yaml \
      -v /root/temp/org1/peer0-home/msp/msp:/opt/org1/peer0-home/msp \
      -v /root/temp/org2/peer0-home/msp/msp:/opt/org2/peer0-home/msp \
      -v /root/temp/orderer-home/msp/msp:/opt/orderer-home/msp \
      -w /etc/hyperledger \
      hyperledger/fabric-tools:1.4.3 \
      configtxgen \
      -outputBlock /opt/data/orderer.genesis.block \
      -channelID byfn-sys-channel \
      -profile TwoOrgsOrdererGenesis
```

创建通道 channel.tx文件
```go
docker run --rm -it \
  --name configtxgen.generate.files.channel.tx.file \
      -e FABRIC_LOGGING_SPEC="DEBUG" \
      --network bc-net \
      -e FABRIC_CFG_PATH=/etc/hyperledger/ \
      -v /root/temp/:/opt/data \
      -v /root/temp/configtx.yaml:/etc/hyperledger/configtx.yaml \
      -v /root/temp/org1/peer0-home/msp/msp:/opt/org1/peer0-home/msp \
      -v /root/temp/org2/peer0-home/msp/msp:/opt/org2/peer0-home/msp \
      -v /root/temp/orderer-home/msp/msp:/opt/orderer-home/msp \
      -w /etc/hyperledger \
      hyperledger/fabric-tools:1.4.3 \
      configtxgen \
      -profile TwoOrgsChannel \
      -outputCreateChannelTx /opt/data/channel.tx \
      -channelID mychannel
```

启动 orderer服务 
```go

docker rm -f orderer.com
docker run -it -d  \
  --name orderer.com \
      --network bc-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e ORDERER_GENERAL_LISTENADDRESS="0.0.0.0" \
      -e ORDERER_GENERAL_GENESISMETHOD="file" \
      -e ORDERER_GENERAL_GENESISFILE="/etc/hyperledger/orderer_data/orderer.genesis.block" \
      -e ORDERER_GENERAL_LOCALMSPID="ordererMSP" \
      -e ORDERER_GENERAL_LOCALMSPDIR="/etc/hyperledger/fabric/msp" \
      -e ORDERER_GENERAL_TLS_ENABLED="true" \
      -e ORDERER_GENERAL_TLS_PRIVATEKEY="/etc/hyperledger/orderer/tls/keystore/server.key" \
      -e ORDERER_GENERAL_TLS_CERTIFICATE="/etc/hyperledger/orderer/tls/signcerts/server.crt" \
      -e ORDERER_GENERAL_TLS_ROOTCAS="[/etc/hyperledger/orderer/tls/tlscacerts/ca.crt]" \
      -e ORDERER_KAFKA_TOPIC_REPLICATIONFACTOR="1" \
      -e ORDERER_KAFKA_VERBOSE="true" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -e ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE="/etc/hyperledger/orderer/tls/signcerts/server.crt" \
      -e ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY="/etc/hyperledger/orderer/tls/keystore/server.key" \
      -e ORDERER_GENERAL_CLUSTER_ROOTCAS="[/etc/hyperledger/orderer/tls/tlscacerts/ca.crt]" \
      -v /root/temp/orderer-home/tls/msp:/etc/hyperledger/orderer/tls \
      -v /root/temp/orderer-home/msp/msp:/etc/hyperledger/fabric/msp \
      -v /root/temp/orderer.genesis.block:/etc/hyperledger/orderer_data/orderer.genesis.block \
      -v /var/run:/var/run \
      hyperledger/fabric-orderer:1.4.3
```


启动org1.peer0的couchdb
```go
docker rm -f couchdb_org1_peer0
docker run -it -d  \
    --name couchdb_org1_peer0 \
    --network bc-net \
    -e COUCHDB_USER=admin \
    -e COUCHDB_PASSWORD=dev@2019  \
    -v /root/temp/org1/peer0-home/couchdb:/opt/couchdb/data \
    -p 5984:5984 \
    -p 9100:9100 \
    -d hyperledger/fabric-couchdb
```

启动org2.peer0的couchdb
```go
docker rm -f couchdb_org2_peer0
docker run -it -d  \
    --name couchdb_org2_peer0 \
    --network bc-net \
    -e COUCHDB_USER=admin \
    -e COUCHDB_PASSWORD=dev@2019  \
    -v /root/temp/org2/peer0-home/couchdb:/opt/couchdb/data \
    -d hyperledger/fabric-couchdb
```

//http://192.168.81.128:5984/_utils/

启动org1.peer0
```go

docker rm -f org1.peer0.com
docker run -it -d \
  --name org1.peer0.com \
      --network bc-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/signcerts/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/keystore/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/tlscacerts/ca.crt" \
      -e CORE_PEER_ID="org1.peer0.com" \
      -e CORE_PEER_ADDRESS="org1.peer0.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="org1.peer0.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="org1.peer0.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="org1.peer0.com:7051" \
      -e CORE_PEER_LOCALMSPID="org1MSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_org1_peer0:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_NOTEOUS_ENABLE="false" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="bc-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /root/temp/org1/peer0-home/msp/msp:/etc/hyperledger/fabric/msp \
      -v /root/temp/org1/peer0-home/tls/msp:/etc/hyperledger/fabric/tls \
      -v /root/temp/org1/peer0-home/production:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3
```

启动org2.peer0
```go

docker rm -f org2.peer0.com
docker run -it -d \
  --name org2.peer0.com \
      --network bc-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/signcerts/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/keystore/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/tlscacerts/ca.crt" \
      -e CORE_PEER_ID="org2.peer0.com" \
      -e CORE_PEER_ADDRESS="org2.peer0.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="org2.peer0.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="org2.peer0.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="org2.peer0.com:7051" \
      -e CORE_PEER_LOCALMSPID="org2MSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_org2_peer0:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_NOTEOUS_ENABLE="false" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="bc-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /root/temp/org2/peer0-home/msp/msp:/etc/hyperledger/fabric/msp \
      -v /root/temp/org2/peer0-home/tls/msp:/etc/hyperledger/fabric/tls \
      -v /root/temp/org2/peer0-home/production:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3
```

注册orderer机构管理员
```go
docker run --rm -it \
    --name register.orderer.order.admin \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client register \
    --id.name order.admin \
    --id.type admin \
    --id.affiliation ordererOrg \
    --id.attrs 'hf.Revoker=true,admin=true' --id.secret adminpw 
```

把这个管理员order.admin的msp拉到本地
```go
docker run --rm -it \
    --name register.test.ca.client \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin2-home \
    -v /root/temp/orderer-admin-home:/opt/test-admin2-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client enroll \
    -u http://order.admin:adminpw@ca.com:7054
```

mv /root/temp/orderer-admin-home/msp/cacerts/* /root/temp/orderer-admin-home/msp/cacerts/ca.pem
mkdir -p /root/temp/orderer-admin-home/msp/tlscacerts
cp /root/temp/orderer-admin-home/msp/cacerts/ca.pem  /root/temp/orderer-admin-home/msp/tlscacerts/

```shell
cat>/root/temp/orderer-admin-home/msp/config.yaml<<EOF
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: orderer
EOF
```


注册org1机构管理员
```go
docker run --rm -it \
    --name register.org1.admin \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client register \
    --id.name org1.admin \
    --id.type admin \
    --id.affiliation org1 \
    --id.attrs 'hf.Revoker=true,admin=true' --id.secret adminpw 
```

把管理员org1.admin的msp拉到本地
```go
docker run --rm -it \
    --name enroll.org1.admin.ca.client \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin2-home \
    -v /root/temp/org1-admin-home:/opt/test-admin2-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client enroll \
    -u http://org1.admin:adminpw@ca.com:7054
```

mv /root/temp/org1-admin-home/msp/cacerts/* /root/temp/org1-admin-home/msp/cacerts/ca.pem
mkdir -p /root/temp/org1-admin-home/msp/tlscacerts
cp /root/temp/org1-admin-home/msp/cacerts/ca.pem  /root/temp/org1-admin-home/msp/tlscacerts/

```shell
cat>/root/temp/org1-admin-home/msp/config.yaml<<EOF
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: orderer
EOF
```




注册org2机构管理员
```go
docker run --rm -it \
    --name register.org1.admin \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client register \
    --id.name org2.admin \
    --id.type admin \
    --id.affiliation org2 \
    --id.attrs 'hf.Revoker=true,admin=true' --id.secret adminpw 
```

把管理员org2.admin的msp拉到本地
```go
docker run --rm -it \
    --name enroll.org2.admin.ca.client \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin2-home \
    -v /root/temp/org2-admin-home:/opt/test-admin2-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client enroll \
    -u http://org2.admin:adminpw@ca.com:7054
```

mv /root/temp/org2-admin-home/msp/cacerts/* /root/temp/org2-admin-home/msp/cacerts/ca.pem
mkdir -p /root/temp/org2-admin-home/msp/tlscacerts
cp /root/temp/org2-admin-home/msp/cacerts/ca.pem  /root/temp/org2-admin-home/msp/tlscacerts/

```shell
cat>/root/temp/org2-admin-home/msp/config.yaml<<EOF
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: orderer
EOF
```


//------------------其他角色的用户


//------------------writer角色的用户
注册org1机构writer, id.type=client用户
```go
docker run --rm -it \
    --name register.org1.writer \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client register \
    --id.name org1.writer \
    --id.type client \
    --id.affiliation org1 \
    --id.attrs 'hf.Revoker=true' --id.secret client 
```

把用户org1.writer的msp拉到本地
```go
docker run --rm -it \
    --name enroll.org1.writer.ca.client \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-writer-home \
    -v /root/temp/org1-writer-home:/opt/test-writer-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client enroll \
    -u http://org1.writer:client@ca.com:7054
```

mv /root/temp/org1-writer-home/msp/cacerts/* /root/temp/org1-writer-home/msp/cacerts/ca.pem
mkdir -p /root/temp/org1-writer-home/msp/tlscacerts
cp /root/temp/org1-writer-home/msp/cacerts/ca.pem  /root/temp/org1-writer-home/msp/tlscacerts/

```shell
cat>/root/temp/org1-writer-home/msp/config.yaml<<EOF
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: orderer
EOF
```
//-----------------------------------



//------------------reader角色的用户
注册org1机构reader, id.type=peer用户
```go
docker run --rm -it \
    --name register.org1.reader \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client register \
    --id.name org1.reader \
    --id.type peer \
    --id.affiliation org1 \
    --id.attrs 'hf.Revoker=true' --id.secret peer 
```

把用户org1.reader的msp拉到本地
```go
docker run --rm -it \
    --name enroll.org1.reader.ca.client \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-reader-home \
    -v /root/temp/org1-reader-home:/opt/test-reader-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client enroll \
    -u http://org1.reader:peer@ca.com:7054
```

mv /root/temp/org1-reader-home/msp/cacerts/* /root/temp/org1-reader-home/msp/cacerts/ca.pem
mkdir -p /root/temp/org1-reader-home/msp/tlscacerts
cp /root/temp/org1-reader-home/msp/cacerts/ca.pem  /root/temp/org1-reader-home/msp/tlscacerts/

```shell
cat>/root/temp/org1-reader-home/msp/config.yaml<<EOF
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: orderer
EOF
```
//-----------------------------------


# 创建通道
```go
docker run --rm -it \
    --name create.channel.client \
    --network bc-net \
    -e CORE_PEER_LOCALMSPID=org1MSP \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/msp/cacerts/ca.pem \
    -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp \
    -v /root/temp/org1-admin-home/msp:/etc/hyperledger/fabric/msp \
    -v /root/temp:/opt/orderer_data \
    hyperledger/fabric-tools:1.4.3 \
    peer channel create --outputBlock /opt/orderer_data/mychannel.block -o orderer.com:7050 \
    -c mychannel \
    -f /opt/orderer_data/channel.tx \
    --tls true \
    --cafile /etc/hyperledger/fabric/msp/cacerts/ca.pem
```

# 加入通道 
```go
docker run --rm -it \
    --name create.channel.client \
    --network bc-net \
    -e CORE_PEER_LOCALMSPID=org1MSP \
    -e CORE_PEER_TLS_ENABLED="true"  \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/msp/cacerts/ca.pem \
    -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp \
    -e CORE_PEER_ADDRESS=org1.peer0.com:7051 \
    -v /root/temp/org1-admin-home/msp:/etc/hyperledger/fabric/msp \
    -v /root/temp:/opt/orderer_data \
    hyperledger/fabric-tools:1.4.3 \
    peer channel join -b /opt/orderer_data/mychannel.block \
    --tls true \
    --cafile /etc/hyperledger/fabric/msp/cacerts/ca.pem
```

# 列出通道
```go
docker run --rm -it \
    --name create.channel.client \
    --network bc-net \
    -e CORE_PEER_LOCALMSPID=org1MSP \
    -e CORE_PEER_TLS_ENABLED="true"  \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/msp/cacerts/ca.pem \
    -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp \
    -e CORE_PEER_ADDRESS=org1.peer0.com:7051 \
    -v /root/temp/org1-admin-home/msp:/etc/hyperledger/fabric/msp \
    hyperledger/fabric-tools:1.4.3 \
    peer channel list
```


# org2加入通道 
```go
docker run --rm -it \
    --name create.channel.client \
    --network bc-net \
    -e CORE_PEER_LOCALMSPID=org2MSP \
    -e CORE_PEER_TLS_ENABLED="true"  \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/msp/cacerts/ca.pem \
    -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp \
    -e CORE_PEER_ADDRESS=org2.peer0.com:8051 \
    -v /root/temp/org2-admin-home/msp:/etc/hyperledger/fabric/msp \
    -v /root/temp:/opt/orderer_data \
    hyperledger/fabric-tools:1.4.3 \
    peer channel join -b /opt/orderer_data/mychannel.block \
    --tls true \
    --cafile /etc/hyperledger/fabric/msp/cacerts/ca.pem
```

# 列出通道
```go
docker run --rm -it \
    --name create.channel.client \
    --network bc-net \
    -e CORE_PEER_LOCALMSPID=org1MSP \
    -e CORE_PEER_TLS_ENABLED="true"  \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/msp/cacerts/ca.pem \
    -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp \
    -e CORE_PEER_ADDRESS=org1.peer0.com:7051 \
    -v /root/temp/org1-admin-home/msp:/etc/hyperledger/fabric/msp \
    hyperledger/fabric-tools:1.4.3 \
    peer channel list
```

# 安装合约
```go
docker run --rm -it \
    --name create.channel.client \
    --network bc-net \
    -e CORE_PEER_LOCALMSPID=org1MSP \
    -e CORE_PEER_TLS_ENABLED="true"  \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/msp/cacerts/ca.pem \
    -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp \
    -e CORE_PEER_ADDRESS=peer0.com:7051 \
    -v /root/temp/org1-admin-home/msp:/etc/hyperledger/fabric/msp \
    chaincode:0.1 \
    peer chaincode install \
    -n mychaincode \
    -v 1.1 \
    -l golang \
    -p mychaincode
```

# 实例化合约
```go
docker run --rm  -it \
    -e FABRIC_LOGGING_SPEC="DEBUG" \
    --name create.channel.client \
    --network bc-net \
    -e CORE_PEER_LOCALMSPID=org1MSP \
    -e CORE_PEER_TLS_ENABLED="true"  \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/msp/cacerts/ca.pem \
    -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp \
    -e CORE_PEER_ADDRESS=peer0.com:7051 \
    -v /root/temp/org1-admin-home/msp:/etc/hyperledger/fabric/msp \
    hyperledger/fabric-tools:1.4.3 \
    peer chaincode instantiate  -o orderer.com:7050\
    -C mychannel \
    -n mychaincode \
    -v 1.1 \
    -l golang \
    -c '{"Args":["init","a","100","b","200"]}' -P 'OR ('\''org1MSP.peer'\'')' \
    --tls true \
    --cafile /etc/hyperledger/fabric/msp/cacerts/ca.pem
```

# 如果不把合约依赖的库打入镜像，此处会慢


Error: could not assemble transaction, err proposal response was not successful, error code 500, msg instantiation policy violation: signature set did not satisfy policy
权限还是有问题。要研究。

查看已安装的合约
```go
docker run --rm -it \
    --name create.channel.client \
    --network bc-net \
    -e CORE_PEER_LOCALMSPID=org1MSP \
    -e CORE_PEER_TLS_ENABLED="true"  \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/msp/cacerts/ca.pem \
    -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp \
    -e CORE_PEER_ADDRESS=peer0.com:7051 \
    -v /root/temp/org1-reader-home/msp:/etc/hyperledger/fabric/msp \
    hyperledger/fabric-tools:1.4.3 \
    peer chaincode list\
    -C mychannel \
    --installed \
    --tls true \
    --cafile /etc/hyperledger/fabric/msp/cacerts/ca.pem
```

查看已实例化合约
```go
docker run --rm -it \
    --name create.channel.client \
    --network bc-net \
    -e CORE_PEER_LOCALMSPID=org1MSP \
    -e CORE_PEER_TLS_ENABLED="true"  \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/msp/cacerts/ca.pem \
    -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp \
    -e CORE_PEER_ADDRESS=peer0.com:7051 \
    -v /root/temp/org1-reader-home/msp:/etc/hyperledger/fabric/msp \
    hyperledger/fabric-tools:1.4.3 \
    peer chaincode list\
    -C mychannel \
    --instantiated \
    --tls true \
    --cafile /etc/hyperledger/fabric/msp/cacerts/ca.pem
```


```go用writer可以。权限合适
docker run --rm -it \
    --name create.channel.client \
    --network bc-net \
    -e CORE_PEER_LOCALMSPID=org1MSP \
    -e CORE_PEER_TLS_ENABLED="true"  \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/msp/cacerts/ca.pem \
    -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp \
    -e CORE_PEER_ADDRESS=peer0.com:7051 \
    -v /root/temp/org1-writer-home/msp:/etc/hyperledger/fabric/msp \
    hyperledger/fabric-tools:1.4.3 \
    peer chaincode list\
    -C mychannel \
    --instantiated \
    --tls true \
    --cafile /etc/hyperledger/fabric/msp/cacerts/ca.pem
```

执行合约

```docker
docker run --rm -it \
    --name apply.chain.code \
    --network bc-net \
    -e CORE_PEER_LOCALMSPID=org1MSP \
    -e CORE_PEER_TLS_ENABLED="true"  \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/msp/cacerts/ca.pem \
    -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp \
    -e CORE_PEER_ADDRESS=peer0.com:7051 \
    -v /root/temp/org1-admin-home/msp:/etc/hyperledger/fabric/msp \
    hyperledger/fabric-tools:1.4.3 \
    peer chaincode invoke \
    -o orderer.com:7050 \
    -C mychannel \
    -n mychaincode \
    -c '{"Args":["add","a","10"]}' \
    --tls true \
    --cafile /etc/hyperledger/fabric/msp/cacerts/ca.pem
```


# 测试用 "hf.Type":"user" 的用户来执行合约

```docker
docker run --rm -it \
    --name apply.chain.code \
    --network bc-net \
    -e CORE_PEER_LOCALMSPID=org1MSP \
    -e CORE_PEER_TLS_ENABLED="true"  \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/msp/cacerts/ca.pem \
    -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp \
    -e CORE_PEER_ADDRESS=peer0.com:7051 \
    -v /root/temp/org1-admin-home/msp:/etc/hyperledger/fabric/msp \
    hyperledger/fabric-tools:1.4.3 \
    peer chaincode invoke \
    -o orderer.com:7050 \
    -C mychannel \
    -n mychaincode \
    -c '{"Args":["add","c","10"]}' \
    --tls true \
    --cafile /etc/hyperledger/fabric/msp/cacerts/ca.pem
```

//Error: error endorsing invoke: rpc error: code = Unknown desc = access denied: channel [mychannel] creator org [org1MSP] - proposal response: <nil>





# 测试用 "hf.Type":"writer" 的用户来执行合约

```docker
docker run --rm -it \
    --name apply.chain.code \
    --network bc-net \
    -e CORE_PEER_LOCALMSPID=org1MSP \
    -e CORE_PEER_TLS_ENABLED="true"  \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/msp/cacerts/ca.pem \
    -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp \
    -e CORE_PEER_ADDRESS=peer0.com:7051 \
    -v /root/temp/org1-writer-home/msp:/etc/hyperledger/fabric/msp \
    -v /root/chaincode:/opt/gopath/src/mychaincode \
    hyperledger/fabric-tools:1.4.3 \
    peer chaincode invoke \
    -o orderer.com:7050 \
    -C mychannel \
    -n mychaincode \
    -c '{"Args":["add","d","10"]}' \
    --tls true \
    --cafile /etc/hyperledger/fabric/msp/cacerts/ca.pem
```

//Error: error endorsing invoke: rpc error: code = Unknown desc = access denied: channel [mychannel] creator org [org1MSP] - proposal response: <nil>




2. 如果1成立，那么验证一个公钥是否是合法的公钥，就是看该公钥对应的rootca是否合法，这里如果我们手动替换一个rootca，看看能否通过。





此处要说明一下，为什么 FABRIC_CA_CLIENT_HOME 是 admin而不是admin2，因为此处执行操作的是admin账户，admin2成功注册之后不会生成账户msp信息，只会在ca的数据库中存在，需要在后面的操作中通过enroll操作才会将admin2的账户信息拉取到本地。



configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json


```docker
docker run --rm -it \
    --name apply.chain.code \
    --network bc-net \
    -v /root/temp:/root/temp \
    hyperledger/fabric-tools:1.4.3 \
    configtxlator proto_decode --input /root/temp/mychannel.block \
    --type common.Block  > /root/temp/config1.json
```



































# 创建网络

docker network rm bc-net

docker network create --subnet=172.18.0.0/16 bc-net

# 用docker 启动一个ca server
```用docker启动一个ca-server
docker rm -f ca.com
docker run \
  -it -d \
  --name ca.com \
      --network bc-net \
      -e FABRIC_CA_HOME="/opt/ca-home" \
      -e FABRIC_CA_SERVER_CA_NAME="ca.com" \
      -e FABRIC_CA_SERVER_CSR_CN=ca.com \
      -e FABRIC_CA_SERVER_CSR_HOSTS=ca.com \
      -e FABRIC_CA_SERVER_PORT=7054 \
      -v /root/temp/test-ca-home:/opt/ca-home \
      --entrypoint="fabric-ca-server" hyperledger/fabric-ca:1.4.3  start  -b admin:adminpw -d
```

# 把ca的admin的msp拉出来
```go
docker run --rm -it \
    --name enroll.test.ca.client \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client enroll \
    -u http://admin:adminpw@ca.com:7054
```

mv /root/temp/test-ca-admin-home/msp/cacerts/* /root/temp/test-ca-admin-home/msp/cacerts/ca.pem

mkdir -p /root/temp/test-ca-admin-home/msp/admincerts


# 创建config.yaml文件

```shell
cat>/root/temp/test-ca-admin-home/msp/config.yaml<<EOF
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: orderer
EOF
```

列出affiliation
```go
#fabric-ca-client affiliation add org3.department1
docker run --rm -it \
    --name add-affiliation \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client affiliation list
```

先注册affiliation
```go
#fabric-ca-client affiliation add org3.department1
docker run --rm -it \
    --name add-affiliation \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client affiliation add ordererOrg
```

增加org3组织
```go
#fabric-ca-client affiliation add org3.department1
docker run --rm -it \
    --name add-affiliation \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client  affiliation add org3
```

增加org3组织的department1
```go
#fabric-ca-client affiliation add org3.department1
docker run --rm -it \
    --name add-affiliation \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client  affiliation add org3.department1
```

```go
docker run --rm -it \
    --name add-affiliation \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client affiliation add ordererOrg.ordererMSP
```

0. 注册orderer
```go
rm -rf /root/temp/order-home
docker run --rm -it \
    --name register.orderer \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client register \
    --id.name orderer.com --id.type orderer \
    --id.affiliation ordererOrg \
    --id.secret ordererpw 
```

拉取orderer的tls
```go
docker run --rm -it \
  --name enroll.orderer \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/opt/orderer-home \
      -v /root/temp/orderer-home/tls:/opt/orderer-home \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      --enrollment.profile tls --csr.hosts orderer.com \
      -u http://orderer.com:ordererpw@ca.com:7054
```

修改tls中的私钥文件名
```shell script
mv /root/temp/orderer-home/tls/msp/keystore/* /root/temp/orderer-home/tls/msp/keystore/server.key
mv /root/temp/orderer-home/tls/msp/signcerts/* /root/temp/orderer-home/tls/msp/signcerts/server.crt
mv /root/temp/orderer-home/tls/msp/tlscacerts/* /root/temp/orderer-home/tls/msp/tlscacerts/ca.crt
```

# 拉取order的msp
```go
docker run --rm -it \
  --name enroll.cec.orderer \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/opt/orderer-home-msp \
      -v /root/temp/orderer-home/msp:/opt/orderer-home-msp \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -M /opt/orderer-home-msp/msp \
      -u http://orderer.com:ordererpw@ca.com:7054
```
mv /root/temp/orderer-home/msp/msp/cacerts/* /root/temp/orderer-home/msp/msp/cacerts/ca.pem
mkdir -p /root/temp/orderer-home/msp/msp/tlscacerts
cp /root/temp/orderer-home/msp/msp/cacerts/ca.pem  /root/temp/orderer-home/msp/msp/tlscacerts/

# 给orderer节点创建config.yaml文件

```shell
cat>/root/temp/orderer-home/msp/msp/config.yaml<<EOF
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: orderer
EOF
```

mkdir -p /root/temp/orderer-home/msp/msp/admincerts


接下来要测试的，

1. 是通过这个CA注册一个peer，然后和这个peer通信的时候，关掉这个ca，看看root ca是否能验证成功。这里好像是不需要，因为generate出来的各种ca证书，也是没有root ca服务供验证的
   完成上面的注册peer, 然后把peer的msp拉下来。启动peer

注册org1.peer0
```go
rm -rf /root/temp/org1/peer0-home
docker run --rm -it \
    --name register.org1.peer0 \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client register \
    --id.name org1.peer0 --id.type peer  --id.secret peerpw 
```

拉取tls
```go
docker run --rm -it \
  --name enroll.cec.org1.peer0 \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/opt/peer0-home \
      -v /root/temp/org1/peer0-home/tls:/opt/peer0-home \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      --enrollment.profile tls --csr.hosts org1.peer0.com \
      -u http://org1.peer0:peerpw@ca.com:7054
```

修改tls中的私钥文件名
```shell script
mv /root/temp/org1/peer0-home/tls/msp/keystore/* /root/temp/org1/peer0-home/tls/msp/keystore/server.key
mv /root/temp/org1/peer0-home/tls/msp/signcerts/* /root/temp/org1/peer0-home/tls/msp/signcerts/server.crt
mv /root/temp/org1/peer0-home/tls/msp/tlscacerts/* /root/temp/org1/peer0-home/tls/msp/tlscacerts/ca.crt
```

拉取msp
```go
docker run --rm -it \
  --name enroll.cec.org1.peer0 \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/opt/peer0-home-msp \
      -v /root/temp/org1/peer0-home/msp:/opt/peer0-home-msp \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -M /opt/peer0-home-msp/msp \
      -u http://org1.peer0:peerpw@ca.com:7054
```

mv /root/temp/org1/peer0-home/msp/msp/cacerts/* /root/temp/org1/peer0-home/msp/msp/cacerts/ca.pem
mkdir -p /root/temp/org1/peer0-home/msp/msp/tlscacerts
cp /root/temp/org1/peer0-home/msp/msp/cacerts/ca.pem  /root/temp/org1/peer0-home/msp/msp/tlscacerts/

# 给peer0节点创建 config.yaml文件
```shell
cat>/root/temp/org1/peer0-home/msp/msp/config.yaml<<EOF
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: orderer
EOF
```





注册org2.peer0
```go
rm -rf /root/temp/org2/peer0-home
docker run --rm -it \
    --name register.org2.peer0 \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client register \
    --id.name org2.peer0 --id.type peer  --id.secret peerpw 
```

拉取tls
```go
docker run --rm -it \
  --name enroll.cec.org2.peer0 \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/opt/peer0-home \
      -v /root/temp/org2/peer0-home/tls:/opt/peer0-home \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      --enrollment.profile tls --csr.hosts org2.peer0.com \
      -u http://org2.peer0:peerpw@ca.com:7054
```

修改tls中的私钥文件名
```shell script
mv /root/temp/org2/peer0-home/tls/msp/keystore/* /root/temp/org2/peer0-home/tls/msp/keystore/server.key
mv /root/temp/org2/peer0-home/tls/msp/signcerts/* /root/temp/org2/peer0-home/tls/msp/signcerts/server.crt
mv /root/temp/org2/peer0-home/tls/msp/tlscacerts/* /root/temp/org2/peer0-home/tls/msp/tlscacerts/ca.crt
```

拉取msp
```go
docker run --rm -it \
  --name enroll.cec.org2.peer0 \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/opt/peer0-home-msp \
      -v /root/temp/org2/peer0-home/msp:/opt/peer0-home-msp \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -M /opt/peer0-home-msp/msp \
      -u http://org2.peer0:peerpw@ca.com:7054
```

mv /root/temp/org2/peer0-home/msp/msp/cacerts/* /root/temp/org2/peer0-home/msp/msp/cacerts/ca.pem
mkdir -p /root/temp/org2/peer0-home/msp/msp/tlscacerts
cp /root/temp/org2/peer0-home/msp/msp/cacerts/ca.pem  /root/temp/org2/peer0-home/msp/msp/tlscacerts/

# 给peer0节点创建 config.yaml文件
```shell
cat>/root/temp/org2/peer0-home/msp/msp/config.yaml<<EOF
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: orderer
EOF
```



# 生成configtx.yaml文件 ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！

-1. 各种msp生成完毕之后，生成创世区块
```go
docker run --rm -it \
  --name configtxgen.generate.files \
      --network bc-net \
      -e FABRIC_CFG_PATH=/etc/hyperledger/ \
      -v /root/temp/:/opt/data \
      -v /root/temp/configtx.yaml:/etc/hyperledger/configtx.yaml \
      -v /root/temp/org1/peer0-home/msp/msp:/opt/org1/peer0-home/msp \
      -v /root/temp/org2/peer0-home/msp/msp:/opt/org2/peer0-home/msp \
      -v /root/temp/orderer-home/msp/msp:/opt/orderer-home/msp \
      -w /etc/hyperledger \
      hyperledger/fabric-tools:1.4.3 \
      configtxgen \
      -outputBlock /opt/data/orderer.genesis.block \
      -channelID byfn-sys-channel \
      -profile TwoOrgsOrdererGenesis
```

创建通道 channel.tx文件
```go
docker run --rm -it \
  --name configtxgen.generate.files.channel.tx.file \
      -e FABRIC_LOGGING_SPEC="DEBUG" \
      --network bc-net \
      -e FABRIC_CFG_PATH=/etc/hyperledger/ \
      -v /root/temp/:/opt/data \
      -v /root/temp/configtx.yaml:/etc/hyperledger/configtx.yaml \
      -v /root/temp/org1/peer0-home/msp/msp:/opt/org1/peer0-home/msp \
      -v /root/temp/org2/peer0-home/msp/msp:/opt/org2/peer0-home/msp \
      -v /root/temp/orderer-home/msp/msp:/opt/orderer-home/msp \
      -w /etc/hyperledger \
      hyperledger/fabric-tools:1.4.3 \
      configtxgen \
      -profile TwoOrgsChannel \
      -outputCreateChannelTx /opt/data/channel.tx \
      -channelID mychannel
```

启动 orderer服务
```go

docker rm -f orderer.com
docker run -it -d  \
  --name orderer.com \
      --network bc-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e ORDERER_GENERAL_LISTENADDRESS="0.0.0.0" \
      -e ORDERER_GENERAL_GENESISMETHOD="file" \
      -e ORDERER_GENERAL_GENESISFILE="/etc/hyperledger/orderer_data/orderer.genesis.block" \
      -e ORDERER_GENERAL_LOCALMSPID="ordererMSP" \
      -e ORDERER_GENERAL_LOCALMSPDIR="/etc/hyperledger/fabric/msp" \
      -e ORDERER_GENERAL_TLS_ENABLED="true" \
      -e ORDERER_GENERAL_TLS_PRIVATEKEY="/etc/hyperledger/orderer/tls/keystore/server.key" \
      -e ORDERER_GENERAL_TLS_CERTIFICATE="/etc/hyperledger/orderer/tls/signcerts/server.crt" \
      -e ORDERER_GENERAL_TLS_ROOTCAS="[/etc/hyperledger/orderer/tls/tlscacerts/ca.crt]" \
      -e ORDERER_KAFKA_TOPIC_REPLICATIONFACTOR="1" \
      -e ORDERER_KAFKA_VERBOSE="true" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -e ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE="/etc/hyperledger/orderer/tls/signcerts/server.crt" \
      -e ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY="/etc/hyperledger/orderer/tls/keystore/server.key" \
      -e ORDERER_GENERAL_CLUSTER_ROOTCAS="[/etc/hyperledger/orderer/tls/tlscacerts/ca.crt]" \
      -v /root/temp/orderer-home/tls/msp:/etc/hyperledger/orderer/tls \
      -v /root/temp/orderer-home/msp/msp:/etc/hyperledger/fabric/msp \
      -v /root/temp/orderer.genesis.block:/etc/hyperledger/orderer_data/orderer.genesis.block \
      -v /var/run:/var/run \
      hyperledger/fabric-orderer:1.4.3
```


启动org1.peer0的couchdb
```go
docker rm -f couchdb_org1_peer0
docker run -it -d  \
    --name couchdb_org1_peer0 \
    --network bc-net \
    -e COUCHDB_USER=admin \
    -e COUCHDB_PASSWORD=dev@2019  \
    -v /root/temp/org1/peer0-home/couchdb:/opt/couchdb/data \
    -p 5984:5984 \
    -p 9100:9100 \
    -d hyperledger/fabric-couchdb
```

启动org2.peer0的couchdb
```go
docker rm -f couchdb_org2_peer0
docker run -it -d  \
    --name couchdb_org2_peer0 \
    --network bc-net \
    -e COUCHDB_USER=admin \
    -e COUCHDB_PASSWORD=dev@2019  \
    -v /root/temp/org2/peer0-home/couchdb:/opt/couchdb/data \
    -d hyperledger/fabric-couchdb
```

//http://192.168.81.128:5984/_utils/

启动org1.peer0
```go

docker rm -f org1.peer0.com
docker run -it -d \
  --name org1.peer0.com \
      --network bc-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/signcerts/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/keystore/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/tlscacerts/ca.crt" \
      -e CORE_PEER_ID="org1.peer0.com" \
      -e CORE_PEER_ADDRESS="org1.peer0.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="org1.peer0.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="org1.peer0.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="org1.peer0.com:7051" \
      -e CORE_PEER_LOCALMSPID="org1MSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_org1_peer0:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_NOTEOUS_ENABLE="false" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="bc-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /root/temp/org1/peer0-home/msp/msp:/etc/hyperledger/fabric/msp \
      -v /root/temp/org1/peer0-home/tls/msp:/etc/hyperledger/fabric/tls \
      -v /root/temp/org1/peer0-home/production:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3
```

启动org2.peer0
```go

docker rm -f org2.peer0.com
docker run -it -d \
  --name org2.peer0.com \
      --network bc-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/signcerts/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/keystore/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/tlscacerts/ca.crt" \
      -e CORE_PEER_ID="org2.peer0.com" \
      -e CORE_PEER_ADDRESS="org2.peer0.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="org2.peer0.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="org2.peer0.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="org2.peer0.com:7051" \
      -e CORE_PEER_LOCALMSPID="org2MSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_org2_peer0:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_NOTEOUS_ENABLE="false" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="bc-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /root/temp/org2/peer0-home/msp/msp:/etc/hyperledger/fabric/msp \
      -v /root/temp/org2/peer0-home/tls/msp:/etc/hyperledger/fabric/tls \
      -v /root/temp/org2/peer0-home/production:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3
```

注册orderer机构管理员
```go
docker run --rm -it \
    --name register.orderer.order.admin \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client register \
    --id.name order.admin \
    --id.type admin \
    --id.affiliation ordererOrg \
    --id.attrs 'hf.Revoker=true,admin=true' --id.secret adminpw 
```

把这个管理员order.admin的msp拉到本地
```go
docker run --rm -it \
    --name register.test.ca.client \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin2-home \
    -v /root/temp/orderer-admin-home:/opt/test-admin2-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client enroll \
    -u http://order.admin:adminpw@ca.com:7054
```

mv /root/temp/orderer-admin-home/msp/cacerts/* /root/temp/orderer-admin-home/msp/cacerts/ca.pem
mkdir -p /root/temp/orderer-admin-home/msp/tlscacerts
cp /root/temp/orderer-admin-home/msp/cacerts/ca.pem  /root/temp/orderer-admin-home/msp/tlscacerts/

```shell
cat>/root/temp/orderer-admin-home/msp/config.yaml<<EOF
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: orderer
EOF
```


注册org1机构管理员
```go
docker run --rm -it \
    --name register.org1.admin \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client register \
    --id.name org1.admin \
    --id.type admin \
    --id.affiliation org1 \
    --id.attrs 'hf.Revoker=true,admin=true' --id.secret adminpw 
```

把管理员org1.admin的msp拉到本地
```go
docker run --rm -it \
    --name enroll.org1.admin.ca.client \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin2-home \
    -v /root/temp/org1-admin-home:/opt/test-admin2-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client enroll \
    -u http://org1.admin:adminpw@ca.com:7054
```

mv /root/temp/org1-admin-home/msp/cacerts/* /root/temp/org1-admin-home/msp/cacerts/ca.pem
mkdir -p /root/temp/org1-admin-home/msp/tlscacerts
cp /root/temp/org1-admin-home/msp/cacerts/ca.pem  /root/temp/org1-admin-home/msp/tlscacerts/

```shell
cat>/root/temp/org1-admin-home/msp/config.yaml<<EOF
NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca.pem
    OrganizationalUnitIdentifier: orderer
EOF
```
