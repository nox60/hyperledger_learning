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

### 3. 创建软连接，该任务的目的是映射出一个/opt/local下面的目录，该目录在后续操作中会被硬编码指定，目前如果不使用docker-compose的配置方式的话，是不支持相对路径的，所以创建该软连接。

```greenplum
rm -rf /opt/local/codes/docker_with_ca
ln -s /root/codes/hyperledger_learning/docker_with_ca /opt/local/codes/docker_with_ca

```

### 4. 执行start.sh，拉起所需容器。

```greenplum
./start.sh
```


需要注意到的是，在start.sh脚本中会拉起ca容器，目前ca容器使用的tls证书还是来自于cryptogen工具生成，在后期迭代之后，会使用自建的ca服务来生成。


## 操作任务
### 1. enroll admin用户，目前初始的admin用户相关信息是由cryptogen工具生成的。

```runad
docker run --rm -it \
--name enroll.admin.ca.client \
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

上面的命令会拉起一个容器，名为enroll.admin.ca.client，该容器会执行enroll命令并且获取到admin的相关证书信息，执行完之后该容器自动销毁。
获取到得证书文件等信息，在
```dir
/opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/users/admin 
```
目录中。

### 2. 创建第二个admin用户，使用密码 admin2pw，后续操作会使用这个新创建的admin用户来进行操作。

参数相关文档：
https://hyperledger-fabric-ca.readthedocs.io/en/release-1.1/users-guide.html#reenrolling-an-identity

```runad
docker run --rm -it \
--name register.admin.ca.client \
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

此处要说明一下，为什么 FABRIC_CA_CLIENT_HOME 是 admin而不是admin2，因为此处执行操作的是admin账户，admin2成功注册之后不会生成账户msp信息，只会在ca的数据库中存在，需要在后面的操作中通过enroll操作才会将admin2的账户信息拉取到本地。



### 3. 将该admin用户(用户名admin2)的msp拉取到本地
```cgo
docker run --rm -it \
--name enroll.admin2.ca.client \
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


### 4. --此处有技术债务，需要拷贝一个config.yaml配置文件到新创建的admin用户的msp目录下，会在后续解释该配置文件。
cp /opt/local/codes/docker_with_ca/config.yaml /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/users/admin2/msp/

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

### 6. 加入通道操作
```greenplum
docker run --rm -it \
--name join.channel.admin2.client \
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