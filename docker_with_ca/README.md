# 基于自建ca的docker

本文不单独阐述依赖的环境搭建。假设读者已经安装好docker, golang等相关程序了。

本文的最终目的是使用自建的CA来维护hyperledger网络中所有的证书信息，而不是使用cryptogen工具。需要说明的是，本过程是迭代的，所以一开始会用cryptogen来生成一些最早的证书信息。

本文重要的参考文档地址是：

https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/users-guide.html

首先分析一下docker_with_ca目录下的几个脚本文件作用：

clear.sh 现场清理

generate.sh 生成先关证书信息（注意，随着迭代进行，最后不会使用cryptogen工具来生成）

start.sh 拉起相应的容器。

# 操作流程

## 环境准备

### 1. 运行clear.sh清理现场。

```clearenv
./clear.sh
```

### 2. 运行generate.sh生成必要证书文件。

```greenplum
./generate.sh
```

### 3. 执行start.sh，拉起所需容器。

```greenplum
./start.sh
```


需要注意到的是，在start.sh脚本中会拉起ca容器，目前ca容器使用的tls证书还是来自于cryptogen工具生成，在后期迭代之后，会使用自建的ca服务来生成。


## 操作任务
### 1.1. enroll cec的admin用户，目前初始的cec admin用户相关信息是由cryptogen工具生成的。

```runad
docker run --rm -it \
--name enroll.cec.admin.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/cec-ca/admin \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/cec-ca/fabric-ca-server-config/ca.cec.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/users/admin:/etc/hyperledger/cec-ca/admin \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/ca:/etc/hyperledger/cec-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client enroll \
--home /etc/hyperledger/cec-ca/admin \
-u https://admin:adminpw@ca.cec.dams.com:7054
```

### 1.2. enroll ia3的admin用户，目前初始的ia3 admin用户相关信息是由cryptogen工具生成的。

```runad
docker run --rm -it \
--name enroll.ia3.admin.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ia3-ca/admin \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ia3-ca/fabric-ca-server-config/ca.ia3.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ia3.dams.com/users/admin:/etc/hyperledger/ia3-ca/admin \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ia3.dams.com/ca:/etc/hyperledger/ia3-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client enroll \
--home /etc/hyperledger/ia3-ca/admin \
-u https://admin:adminpw@ca.ia3.dams.com:7054
```

### 1.3. enroll ic3的admin用户，目前初始的ic3 admin用户相关信息是由cryptogen工具生成的。

```runad
docker run --rm -it \
--name enroll.ic3.admin.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ic3-ca/admin \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ic3-ca/fabric-ca-server-config/ca.ic3.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ic3.dams.com/users/admin:/etc/hyperledger/ic3-ca/admin \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ic3.dams.com/ca:/etc/hyperledger/ic3-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client enroll \
--home /etc/hyperledger/ic3-ca/admin \
-u https://admin:adminpw@ca.ic3.dams.com:7054
```

### 1.4. enroll gov的admin用户，目前初始的gov admin用户相关信息是由cryptogen工具生成的。

```runad
docker run --rm -it \
--name enroll.gov.admin.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/gov-ca/admin \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/gov-ca/fabric-ca-server-config/ca.gov.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/gov.dams.com/users/admin:/etc/hyperledger/gov-ca/admin \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/gov.dams.com/ca:/etc/hyperledger/gov-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client enroll \
--home /etc/hyperledger/gov-ca/admin \
-u https://admin:adminpw@ca.gov.dams.com:7054
```

上面的命令会拉起一个容器，比如名为enroll.cec.admin.ca.client，该容器会执行enroll命令并且获取到admin的相关证书信息，执行完之后该容器自动销毁。
获取到得证书文件等信息，在
```dir
/opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/users/admin 
```
目录中。

### 2.1 创建cec的第二个admin用户，使用密码 admin2pw，后续操作会使用这个新创建的admin用户来进行操作。

参数相关文档：
https://hyperledger-fabric-ca.readthedocs.io/en/release-1.1/users-guide.html#reenrolling-an-identity

```runad
docker run --rm -it \
--name register.cec.admin.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/cec-ca/admin \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/cec-ca/fabric-ca-server-config/ca.cec.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/users/admin:/etc/hyperledger/cec-ca/admin \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/ca:/etc/hyperledger/cec-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client register \
--id.name admin2 --id.type admin  --id.attrs 'hf.Revoker=true,admin=true' --id.secret admin2pw \
-u https://ca.cec.dams.com:7054
```


### 2.2 创建ia3第二个admin用户，使用密码 admin2pw，后续操作会使用这个新创建的admin用户来进行操作。

```runad
docker run --rm -it \
--name register.ia3.admin.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ia3-ca/admin \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ia3-ca/fabric-ca-server-config/ca.ia3.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ia3.dams.com/users/admin:/etc/hyperledger/ia3-ca/admin \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ia3.dams.com/ca:/etc/hyperledger/ia3-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client register \
--id.name admin2 --id.type admin  --id.attrs 'hf.Revoker=true,admin=true' --id.secret admin2pw \
-u https://ca.ia3.dams.com:7054
```

### 2.3 创建ic3的第二个admin用户，使用密码 admin2pw，后续操作会使用这个新创建的admin用户来进行操作。

```runad
docker run --rm -it \
--name register.ic3.admin.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ic3-ca/admin \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ic3-ca/fabric-ca-server-config/ca.ic3.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ic3.dams.com/users/admin:/etc/hyperledger/ic3-ca/admin \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ic3.dams.com/ca:/etc/hyperledger/ic3-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client register \
--id.name admin2 --id.type admin  --id.attrs 'hf.Revoker=true,admin=true' --id.secret admin2pw \
-u https://ca.ic3.dams.com:7054
```

### 2.4 创建gov的第二个admin用户，使用密码 admin2pw，后续操作会使用这个新创建的admin用户来进行操作。

```runad
docker run --rm -it \
--name register.gov.admin.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/gov-ca/admin \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/gov-ca/fabric-ca-server-config/ca.gov.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/gov.dams.com/users/admin:/etc/hyperledger/gov-ca/admin \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/gov.dams.com/ca:/etc/hyperledger/gov-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client register \
--id.name admin2 --id.type admin  --id.attrs 'hf.Revoker=true,admin=true' --id.secret admin2pw \
-u https://ca.gov.dams.com:7054
```

### 3.1 将该cec组织的admin用户(用户名admin2)的msp拉取到本地
```cgo
docker run --rm -it \
--name enroll.cec.admin2.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/cec-ca/admin2 \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/cec-ca/fabric-ca-server-config/ca.cec.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/users/admin2:/etc/hyperledger/cec-ca/admin2 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/ca:/etc/hyperledger/cec-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client enroll \
--home /etc/hyperledger/cec-ca/admin2 \
-u https://admin2:admin2pw@ca.cec.dams.com:7054
```

### 3.2 将该ia3组织的admin用户(用户名admin2)的msp拉取到本地
```cgo
docker run --rm -it \
--name enroll.ia3.admin2.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ia3-ca/admin2 \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ia3-ca/fabric-ca-server-config/ca.ia3.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ia3.dams.com/users/admin2:/etc/hyperledger/ia3-ca/admin2 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ia3.dams.com/ca:/etc/hyperledger/ia3-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client enroll \
--home /etc/hyperledger/ia3-ca/admin2 \
-u https://admin2:admin2pw@ca.ia3.dams.com:7054
```

### 3.3 将该ic3组织的admin用户(用户名admin2)的msp拉取到本地
```cgo
docker run --rm -it \
--name enroll.ic3.admin2.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ic3-ca/admin2 \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ic3-ca/fabric-ca-server-config/ca.ic3.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ic3.dams.com/users/admin2:/etc/hyperledger/ic3-ca/admin2 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ic3.dams.com/ca:/etc/hyperledger/ic3-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client enroll \
--home /etc/hyperledger/ic3-ca/admin2 \
-u https://admin2:admin2pw@ca.ic3.dams.com:7054
```

### 3.4 将该gov组织的admin用户(用户名admin2)的msp拉取到本地
```cgo
docker run --rm -it \
--name enroll.gov.admin2.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/gov-ca/admin2 \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/gov-ca/fabric-ca-server-config/ca.gov.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/gov.dams.com/users/admin2:/etc/hyperledger/gov-ca/admin2 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/gov.dams.com/ca:/etc/hyperledger/gov-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client enroll \
--home /etc/hyperledger/gov-ca/admin2 \
-u https://admin2:admin2pw@ca.gov.dams.com:7054
```

### 4. --此处有技术债务，需要拷贝一个config.yaml配置文件到新创建的admin用户的msp目录下，会在后续解释该配置文件。
```greenplum
cp /opt/local/codes/docker_with_ca/config_cec.yaml /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/users/admin2/msp/config.yaml
cp /opt/local/codes/docker_with_ca/config_ia3.yaml /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ia3.dams.com/users/admin2/msp/config.yaml
cp /opt/local/codes/docker_with_ca/config_ic3.yaml /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ic3.dams.com/users/admin2/msp/config.yaml
cp /opt/local/codes/docker_with_ca/config_gov.yaml /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/gov.dams.com/users/admin2/msp/config.yaml

```

### 5. 通道创建操作
```cgo
docker run --rm -it \
--name create.channel.client \
--network bc-net \
-e CORE_PEER_LOCALMSPID=cecMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/admin2/msp \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config:/opt/crypto \
-v /opt/local/codes/docker_with_ca/hyperledger_data:/opt/channel-artifacts \
hyperledger/fabric-tools:1.4.3 \
peer channel create --outputBlock /opt/channel-artifacts/mychannel.block -o orderer.dams.com:7050 \
-c mychannel \
-f /opt/channel-artifacts/channel.tx \
--tls true \
--cafile /opt/crypto/ordererOrganizations/dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem
```

### 6.1 cec加入通道操作
```greenplum
docker run --rm -it \
--name cec.join.channel.admin2.client \
--network bc-net \
-e CORE_PEER_LOCALMSPID=cecMSP \
-e CORE_PEER_TLS_ENABLED="true"  \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt \
-e CORE_PEER_TLS_CERT_FILE="/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/server.crt" \
-e CORE_PEER_TLS_KEY_FILE="/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/server.key" \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/admin2/msp \
-e CORE_PEER_ADDRESS=peer0.cec.dams.com:7051 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config:/opt/crypto \
-v /opt/local/codes/docker_with_ca/hyperledger_data:/opt/channel-artifacts \
hyperledger/fabric-tools:1.4.3 \
peer channel join -b /opt/channel-artifacts/mychannel.block \
--tls true \
--cafile /opt/crypto/ordererOrganizations/dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem
```

### 6.2 ia3加入通道操作
```greenplum
docker run --rm -it \
--name ia3.join.channel.admin2.client \
--network bc-net \
-e CORE_PEER_LOCALMSPID=ia3MSP \
-e CORE_PEER_TLS_ENABLED="true"  \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/ia3.dams.com/peers/peer0.ia3.dams.com/tls/ca.crt \
-e CORE_PEER_TLS_CERT_FILE="/opt/crypto/peerOrganizations/ia3.dams.com/peers/peer0.ia3.dams.com/tls/server.crt" \
-e CORE_PEER_TLS_KEY_FILE="/opt/crypto/peerOrganizations/ia3.dams.com/peers/peer0.ia3.dams.com/tls/server.key" \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/ia3.dams.com/users/admin2/msp \
-e CORE_PEER_ADDRESS=peer0.ia3.dams.com:7151 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config:/opt/crypto \
-v /opt/local/codes/docker_with_ca/hyperledger_data:/opt/channel-artifacts \
hyperledger/fabric-tools:1.4.3 \
peer channel join -b /opt/channel-artifacts/mychannel.block \
--tls true \
--cafile /opt/crypto/ordererOrganizations/dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem
```

### 6.3 ic3加入通道操作
```greenplum
docker run --rm -it \
--name ic3.join.channel.admin2.client \
--network bc-net \
-e CORE_PEER_LOCALMSPID=ic3MSP \
-e CORE_PEER_TLS_ENABLED="true"  \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/ic3.dams.com/peers/peer0.ic3.dams.com/tls/ca.crt \
-e CORE_PEER_TLS_CERT_FILE="/opt/crypto/peerOrganizations/ic3.dams.com/peers/peer0.ic3.dams.com/tls/server.crt" \
-e CORE_PEER_TLS_KEY_FILE="/opt/crypto/peerOrganizations/ic3.dams.com/peers/peer0.ic3.dams.com/tls/server.key" \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/ic3.dams.com/users/admin2/msp \
-e CORE_PEER_ADDRESS=peer0.ic3.dams.com:7251 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config:/opt/crypto \
-v /opt/local/codes/docker_with_ca/hyperledger_data:/opt/channel-artifacts \
hyperledger/fabric-tools:1.4.3 \
peer channel join -b /opt/channel-artifacts/mychannel.block \
--tls true \
--cafile /opt/crypto/ordererOrganizations/dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem
```

### 6.4 gov加入通道操作
```greenplum
docker run --rm -it \
--name gov.join.channel.admin2.client \
--network bc-net \
-e CORE_PEER_LOCALMSPID=govMSP \
-e CORE_PEER_TLS_ENABLED="true"  \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/gov.dams.com/peers/peer0.gov.dams.com/tls/ca.crt \
-e CORE_PEER_TLS_CERT_FILE="/opt/crypto/peerOrganizations/gov.dams.com/peers/peer0.gov.dams.com/tls/server.crt" \
-e CORE_PEER_TLS_KEY_FILE="/opt/crypto/peerOrganizations/gov.dams.com/peers/peer0.gov.dams.com/tls/server.key" \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/gov.dams.com/users/admin2/msp \
-e CORE_PEER_ADDRESS=peer0.gov.dams.com:7351 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config:/opt/crypto \
-v /opt/local/codes/docker_with_ca/hyperledger_data:/opt/channel-artifacts \
hyperledger/fabric-tools:1.4.3 \
peer channel join -b /opt/channel-artifacts/mychannel.block \
--tls true \
--cafile /opt/crypto/ordererOrganizations/dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem
```

### 7 列出cec节点加入的通道，其他节点修改相应的参数即可。
```greenplum
docker run --rm -it \
--name cec.list.channel.admin2.client \
--network bc-net \
-e CORE_PEER_LOCALMSPID=cecMSP \
-e CORE_PEER_TLS_ENABLED="true"  \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/admin2/msp \
-e CORE_PEER_ADDRESS=peer0.cec.dams.com:7051 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config:/opt/crypto \
-v /opt/local/codes/docker_with_ca/hyperledger_data:/opt/channel-artifacts \
hyperledger/fabric-tools:1.4.3 \
peer channel list 
```

### 8 安装智能合约
```greenplum
docker run --rm -it \
--name cec.install.chaincode.admin2.client \
--network bc-net \
-e CORE_PEER_LOCALMSPID=cecMSP \
-e CORE_PEER_TLS_ENABLED="true"  \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt \
-e CORE_PEER_TLS_CERT_FILE="/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/server.crt" \
-e CORE_PEER_TLS_KEY_FILE="/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/server.key" \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/admin2/msp \
-e CORE_PEER_ADDRESS=peer0.cec.dams.com:7051 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config:/opt/crypto \
-v /opt/local/codes/docker_with_ca/hyperledger_data:/opt/channel-artifacts \
-v /opt/local/codes/docker_with_ca/chaincode:/opt/gopath/src/mychaincode \
-v /opt/local/codes/docker_with_ca/chaincode/example_code:/opt/gopath/src/example_code \
hyperledger/fabric-tools:1.4.3 \
peer chaincode install \
-n mychaincode \
-v 1.0 \
-l golang \
-p mychaincode
```



### 9 实例化智能合约
```greenplum
docker run --rm -it \
--name cec.instantiate.chaincode.admin2.client \
--network bc-net \
-e CORE_PEER_LOCALMSPID=cecMSP \
-e CORE_PEER_TLS_ENABLED="true"  \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt \
-e CORE_PEER_TLS_CERT_FILE="/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/server.crt" \
-e CORE_PEER_TLS_KEY_FILE="/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/server.key" \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/admin2/msp \
-e CORE_PEER_ADDRESS=peer0.cec.dams.com:7051 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config:/opt/crypto \
-v /opt/local/codes/docker_with_ca/hyperledger_data:/opt/channel-artifacts \
hyperledger/fabric-tools:1.4.3 \
peer chaincode instantiate -o orderer.dams.com:7050 \
--tls true --cafile /opt/crypto/ordererOrganizations/dams.com/orderers/orderer.dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem \
-C mychannel \
-n mychaincode \
-l golang \
-v 1.0 \
-c '{"Args":["init","a","100","b","200"]}' -P 'OR ('\''cecMSP.peer'\'')'
```


















































# 基于自建ca的docker

本文不单独阐述依赖的环境搭建。假设读者已经安装好docker, golang等相关程序了。

本文的最终目的是使用自建的CA来维护hyperledger网络中所有的证书信息，而不是使用cryptogen工具。需要说明的是，本过程是迭代的，所以一开始会用cryptogen来生成一些最早的证书信息。

本文重要的参考文档地址是：

https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/users-guide.html

首先分析一下docker_with_ca目录下的几个脚本文件作用：

clear.sh 现场清理

generate.sh 生成先关证书信息（注意，随着迭代进行，最后不会使用cryptogen工具来生成）

start.sh 拉起相应的容器。

# 操作流程

## 环境准备

### 1. 运行clear.sh清理现场。

```clearenv
./clear.sh
```

### 2. 运行generate.sh生成必要证书文件。

```greenplum
./generate.sh
```

### 3. 执行start.sh，拉起所需容器。

```greenplum
./start.sh
```


需要注意到的是，在start.sh脚本中会拉起ca容器，目前ca容器使用的tls证书还是来自于cryptogen工具生成，在后期迭代之后，会使用自建的ca服务来生成。


## 操作任务
### 1.1. enroll cec的admin用户，目前初始的cec admin用户相关信息是由cryptogen工具生成的。

```runad
docker run --rm -it \
--name enroll.cec.admin.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/cec-ca/admin \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/cec-ca/fabric-ca-server-config/ca.cec.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/users/admin:/etc/hyperledger/cec-ca/admin \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/ca:/etc/hyperledger/cec-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client enroll \
--home /etc/hyperledger/cec-ca/admin \
-u https://admin:adminpw@ca.cec.dams.com:7054
```

### 1.2. enroll ia3的admin用户，目前初始的ia3 admin用户相关信息是由cryptogen工具生成的。

```runad
docker run --rm -it \
--name enroll.ia3.admin.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ia3-ca/admin \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ia3-ca/fabric-ca-server-config/ca.ia3.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ia3.dams.com/users/admin:/etc/hyperledger/ia3-ca/admin \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ia3.dams.com/ca:/etc/hyperledger/ia3-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client enroll \
--home /etc/hyperledger/ia3-ca/admin \
-u https://admin:adminpw@ca.ia3.dams.com:7054
```

### 1.3. enroll ic3的admin用户，目前初始的ic3 admin用户相关信息是由cryptogen工具生成的。

```runad
docker run --rm -it \
--name enroll.ic3.admin.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ic3-ca/admin \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ic3-ca/fabric-ca-server-config/ca.ic3.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ic3.dams.com/users/admin:/etc/hyperledger/ic3-ca/admin \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ic3.dams.com/ca:/etc/hyperledger/ic3-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client enroll \
--home /etc/hyperledger/ic3-ca/admin \
-u https://admin:adminpw@ca.ic3.dams.com:7054
```

### 1.4. enroll gov的admin用户，目前初始的gov admin用户相关信息是由cryptogen工具生成的。

```runad
docker run --rm -it \
--name enroll.gov.admin.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/gov-ca/admin \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/gov-ca/fabric-ca-server-config/ca.gov.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/gov.dams.com/users/admin:/etc/hyperledger/gov-ca/admin \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/gov.dams.com/ca:/etc/hyperledger/gov-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client enroll \
--home /etc/hyperledger/gov-ca/admin \
-u https://admin:adminpw@ca.gov.dams.com:7054
```

上面的命令会拉起一个容器，比如名为enroll.cec.admin.ca.client，该容器会执行enroll命令并且获取到admin的相关证书信息，执行完之后该容器自动销毁。
获取到得证书文件等信息，在
```dir
/opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/users/admin 
```
目录中。

### 2.1 创建cec的第二个admin用户，使用密码 admin2pw，后续操作会使用这个新创建的admin用户来进行操作。

参数相关文档：
https://hyperledger-fabric-ca.readthedocs.io/en/release-1.1/users-guide.html#reenrolling-an-identity

```runad
docker run --rm -it \
--name register.cec.admin.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/cec-ca/admin \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/cec-ca/fabric-ca-server-config/ca.cec.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/users/admin:/etc/hyperledger/cec-ca/admin \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/ca:/etc/hyperledger/cec-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client register \
--id.name admin2 --id.type admin  --id.attrs 'hf.Revoker=true,admin=true' --id.secret admin2pw \
-u https://ca.cec.dams.com:7054
```


### 2.2 创建ia3第二个admin用户，使用密码 admin2pw，后续操作会使用这个新创建的admin用户来进行操作。

```runad
docker run --rm -it \
--name register.ia3.admin.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ia3-ca/admin \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ia3-ca/fabric-ca-server-config/ca.ia3.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ia3.dams.com/users/admin:/etc/hyperledger/ia3-ca/admin \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ia3.dams.com/ca:/etc/hyperledger/ia3-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client register \
--id.name admin2 --id.type admin  --id.attrs 'hf.Revoker=true,admin=true' --id.secret admin2pw \
-u https://ca.ia3.dams.com:7054
```

### 2.3 创建ic3的第二个admin用户，使用密码 admin2pw，后续操作会使用这个新创建的admin用户来进行操作。

```runad
docker run --rm -it \
--name register.ic3.admin.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ic3-ca/admin \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ic3-ca/fabric-ca-server-config/ca.ic3.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ic3.dams.com/users/admin:/etc/hyperledger/ic3-ca/admin \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ic3.dams.com/ca:/etc/hyperledger/ic3-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client register \
--id.name admin2 --id.type admin  --id.attrs 'hf.Revoker=true,admin=true' --id.secret admin2pw \
-u https://ca.ic3.dams.com:7054
```

### 2.4 创建gov的第二个admin用户，使用密码 admin2pw，后续操作会使用这个新创建的admin用户来进行操作。

```runad
docker run --rm -it \
--name register.gov.admin.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/gov-ca/admin \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/gov-ca/fabric-ca-server-config/ca.gov.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/gov.dams.com/users/admin:/etc/hyperledger/gov-ca/admin \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/gov.dams.com/ca:/etc/hyperledger/gov-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client register \
--id.name admin2 --id.type admin  --id.attrs 'hf.Revoker=true,admin=true' --id.secret admin2pw \
-u https://ca.gov.dams.com:7054
```

### 3.1 将该cec组织的admin用户(用户名admin2)的msp拉取到本地
```cgo
docker run --rm -it \
--name enroll.cec.admin2.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/cec-ca/admin2 \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/cec-ca/fabric-ca-server-config/ca.cec.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/users/admin2:/etc/hyperledger/cec-ca/admin2 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/ca:/etc/hyperledger/cec-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client enroll \
--home /etc/hyperledger/cec-ca/admin2 \
-u https://admin2:admin2pw@ca.cec.dams.com:7054
```

### 3.2 将该ia3组织的admin用户(用户名admin2)的msp拉取到本地
```cgo
docker run --rm -it \
--name enroll.ia3.admin2.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ia3-ca/admin2 \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ia3-ca/fabric-ca-server-config/ca.ia3.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ia3.dams.com/users/admin2:/etc/hyperledger/ia3-ca/admin2 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ia3.dams.com/ca:/etc/hyperledger/ia3-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client enroll \
--home /etc/hyperledger/ia3-ca/admin2 \
-u https://admin2:admin2pw@ca.ia3.dams.com:7054
```

### 3.3 将该ic3组织的admin用户(用户名admin2)的msp拉取到本地
```cgo
docker run --rm -it \
--name enroll.ic3.admin2.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ic3-ca/admin2 \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ic3-ca/fabric-ca-server-config/ca.ic3.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ic3.dams.com/users/admin2:/etc/hyperledger/ic3-ca/admin2 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ic3.dams.com/ca:/etc/hyperledger/ic3-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client enroll \
--home /etc/hyperledger/ic3-ca/admin2 \
-u https://admin2:admin2pw@ca.ic3.dams.com:7054
```

### 3.4 将该gov组织的admin用户(用户名admin2)的msp拉取到本地
```cgo
docker run --rm -it \
--name enroll.gov.admin2.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/gov-ca/admin2 \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/gov-ca/fabric-ca-server-config/ca.gov.dams.com-cert.pem \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/gov.dams.com/users/admin2:/etc/hyperledger/gov-ca/admin2 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/gov.dams.com/ca:/etc/hyperledger/gov-ca/fabric-ca-server-config \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client enroll \
--home /etc/hyperledger/gov-ca/admin2 \
-u https://admin2:admin2pw@ca.gov.dams.com:7054
```

### 4. --此处有技术债务，需要拷贝一个config.yaml配置文件到新创建的admin用户的msp目录下，会在后续解释该配置文件。
```greenplum
cp /opt/local/codes/docker_with_ca/config_cec.yaml /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/users/admin2/msp/config.yaml
cp /opt/local/codes/docker_with_ca/config_ia3.yaml /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ia3.dams.com/users/admin2/msp/config.yaml
cp /opt/local/codes/docker_with_ca/config_ic3.yaml /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ic3.dams.com/users/admin2/msp/config.yaml
cp /opt/local/codes/docker_with_ca/config_gov.yaml /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/gov.dams.com/users/admin2/msp/config.yaml

```

### 5. 通道创建操作
```cgo
docker run --rm -it \
--name create.channel.client \
--network bc-net \
-e CORE_PEER_LOCALMSPID=cecMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/admin2/msp \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config:/opt/crypto \
-v /opt/local/codes/docker_with_ca/hyperledger_data:/opt/channel-artifacts \
hyperledger/fabric-tools:1.4.3 \
peer channel create --outputBlock /opt/channel-artifacts/mychannel.block -o orderer.dams.com:7050 \
-c mychannel \
-f /opt/channel-artifacts/channel.tx \
--tls true \
--cafile /opt/crypto/ordererOrganizations/dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem
```

### 6.1 cec加入通道操作
```greenplum
docker run --rm -it \
--name cec.join.channel.admin2.client \
--network bc-net \
-e CORE_PEER_LOCALMSPID=cecMSP \
-e CORE_PEER_TLS_ENABLED="true"  \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt \
-e CORE_PEER_TLS_CERT_FILE="/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/server.crt" \
-e CORE_PEER_TLS_KEY_FILE="/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/server.key" \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/admin2/msp \
-e CORE_PEER_ADDRESS=peer0.cec.dams.com:7051 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config:/opt/crypto \
-v /opt/local/codes/docker_with_ca/hyperledger_data:/opt/channel-artifacts \
hyperledger/fabric-tools:1.4.3 \
peer channel join -b /opt/channel-artifacts/mychannel.block \
--tls true \
--cafile /opt/crypto/ordererOrganizations/dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem
```

### 6.2 ia3加入通道操作
```greenplum
docker run --rm -it \
--name ia3.join.channel.admin2.client \
--network bc-net \
-e CORE_PEER_LOCALMSPID=ia3MSP \
-e CORE_PEER_TLS_ENABLED="true"  \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/ia3.dams.com/peers/peer0.ia3.dams.com/tls/ca.crt \
-e CORE_PEER_TLS_CERT_FILE="/opt/crypto/peerOrganizations/ia3.dams.com/peers/peer0.ia3.dams.com/tls/server.crt" \
-e CORE_PEER_TLS_KEY_FILE="/opt/crypto/peerOrganizations/ia3.dams.com/peers/peer0.ia3.dams.com/tls/server.key" \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/ia3.dams.com/users/admin2/msp \
-e CORE_PEER_ADDRESS=peer0.ia3.dams.com:7151 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config:/opt/crypto \
-v /opt/local/codes/docker_with_ca/hyperledger_data:/opt/channel-artifacts \
hyperledger/fabric-tools:1.4.3 \
peer channel join -b /opt/channel-artifacts/mychannel.block \
--tls true \
--cafile /opt/crypto/ordererOrganizations/dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem
```

### 6.3 ic3加入通道操作
```greenplum
docker run --rm -it \
--name ic3.join.channel.admin2.client \
--network bc-net \
-e CORE_PEER_LOCALMSPID=ic3MSP \
-e CORE_PEER_TLS_ENABLED="true"  \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/ic3.dams.com/peers/peer0.ic3.dams.com/tls/ca.crt \
-e CORE_PEER_TLS_CERT_FILE="/opt/crypto/peerOrganizations/ic3.dams.com/peers/peer0.ic3.dams.com/tls/server.crt" \
-e CORE_PEER_TLS_KEY_FILE="/opt/crypto/peerOrganizations/ic3.dams.com/peers/peer0.ic3.dams.com/tls/server.key" \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/ic3.dams.com/users/admin2/msp \
-e CORE_PEER_ADDRESS=peer0.ic3.dams.com:7251 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config:/opt/crypto \
-v /opt/local/codes/docker_with_ca/hyperledger_data:/opt/channel-artifacts \
hyperledger/fabric-tools:1.4.3 \
peer channel join -b /opt/channel-artifacts/mychannel.block \
--tls true \
--cafile /opt/crypto/ordererOrganizations/dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem
```

### 6.4 gov加入通道操作
```greenplum
docker run --rm -it \
--name gov.join.channel.admin2.client \
--network bc-net \
-e CORE_PEER_LOCALMSPID=govMSP \
-e CORE_PEER_TLS_ENABLED="true"  \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/gov.dams.com/peers/peer0.gov.dams.com/tls/ca.crt \
-e CORE_PEER_TLS_CERT_FILE="/opt/crypto/peerOrganizations/gov.dams.com/peers/peer0.gov.dams.com/tls/server.crt" \
-e CORE_PEER_TLS_KEY_FILE="/opt/crypto/peerOrganizations/gov.dams.com/peers/peer0.gov.dams.com/tls/server.key" \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/gov.dams.com/users/admin2/msp \
-e CORE_PEER_ADDRESS=peer0.gov.dams.com:7351 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config:/opt/crypto \
-v /opt/local/codes/docker_with_ca/hyperledger_data:/opt/channel-artifacts \
hyperledger/fabric-tools:1.4.3 \
peer channel join -b /opt/channel-artifacts/mychannel.block \
--tls true \
--cafile /opt/crypto/ordererOrganizations/dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem
```

### 7 列出cec节点加入的通道，其他节点修改相应的参数即可。
```greenplum
docker run --rm -it \
--name cec.list.channel.admin2.client \
--network bc-net \
-e CORE_PEER_LOCALMSPID=cecMSP \
-e CORE_PEER_TLS_ENABLED="true"  \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/admin2/msp \
-e CORE_PEER_ADDRESS=peer0.cec.dams.com:7051 \
-v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config:/opt/crypto \
-v /opt/local/codes/docker_with_ca/hyperledger_data:/opt/channel-artifacts \
hyperledger/fabric-tools:1.4.3 \
peer channel list 
```
