# 基于自建ca的docker

https://hyperledger-fabric-ca.readthedocs.io/en/latest/operations_guide.html

本文不单独阐述依赖的环境搭建。假设读者已经安装好docker, golang等相关程序。

本文的最终目的是使用自建的CA来维护hyperledger网络中所有的证书信息，而不是使用cryptogen工具。

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
rm -rf /opt/local/codes/docker_with_ca_4
ln -s /root/codes/hyperledger_learning/docker_with_ca_4 /opt/local/codes/docker_with_ca_4

```

### 4. 执行start.sh，拉起所需容器。

```greenplum
./start.sh
```


需要注意到的是，在start.sh脚本中会拉起ca容器，目前ca容器使用的tls证书还是来自于cryptogen工具生成，在后期迭代之后，会使用自建的ca服务来生成。


## 操作任务
### 1.1. 创建通道。


# 创建第二个Admin账户

```runad
docker run --rm -it \
--name register.cec.admin2.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ca.cec/ca.admin.home \
-e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.cec/ca.home/ca-cert.pem \
-v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.cec:/etc/hyperledger/ca.cec \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client register \
--id.name admin2 --id.type admin  --id.attrs 'hf.Revoker=true,admin=true' --id.secret admin2pw \
-u https://ca.cec:7054
```



# 获取第二个Admin账户msp

```runad
docker run --rm -it \
  --name enroll.ca.cec.admin2 \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ca.cec/ca.admin2.home \
      -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.cec/ca.home/ca-cert.pem \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.cec:/etc/hyperledger/ca.cec \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -u https://admin2:admin2pw@ca.cec:7054
```

# 创建通道
```runad
cp /opt/local/codes/docker_with_ca_4/config_admin_peer0_cec.yaml /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.cec/ca.admin2.home/msp/config.yaml

docker run --rm -it \
    --name create.channel.client \
    --network bc-net \
    -e CORE_PEER_LOCALMSPID=cecMSP \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/ca.cec/ca.tls/tls-ca-tls-7052.pem \
    -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/admin/msp \
    -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.tls:/etc/hyperledger/ca.tls \
    -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.cec/ca.admin2.home/msp:/etc/hyperledger/admin/msp \
    -v /opt/local/codes/docker_with_ca_4/hyperledger_data:/etc/hyperledger/ordererdata \
    -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.orderer/ca.home:/etc/hyperledger/ca.orderer/ca.home \
    -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/orderer/tls/msp/tlscacerts:/etc/hyperledger/ca.orderer/ca.tls \
    -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/cec/peer0.home/tls/msp/tlscacerts:/etc/hyperledger/ca.cec/ca.tls \
    hyperledger/fabric-tools:1.4.3 \
    peer channel create --outputBlock /etc/hyperledger/ordererdata/mychannel.block -o orderer.com:7050 \
    -c mychannel \
    -f /etc/hyperledger/ordererdata/channel.tx \
    --tls true \
    --cafile /etc/hyperledger/ca.orderer/ca.tls/tls-ca-tls-7052.pem
```

# 查询已经加入的通道
```greenplum
docker run --rm -it \
    --name cec.list.channel.admin2.client \
    --network bc-net \
    -e CORE_PEER_LOCALMSPID=cecMSP \
    -e CORE_PEER_TLS_ENABLED="true"  \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/ca.cec/ca.tls/msp/tlscacerts/tls-ca-tls-7052.pem \
    -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/admin/msp \
    -e CORE_PEER_ADDRESS=peer0.cec.com:7051 \
    -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.cec/ca.admin2.home/msp:/etc/hyperledger/admin/msp \
    -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/cec/peer0.home/tls/msp:/etc/hyperledger/ca.cec/ca.tls/msp \
    hyperledger/fabric-tools:1.4.3 \
    peer channel list
```

```greenplum
docker run --rm -it \
    --name create.channel.client \
    --network bc-net \
    -e CORE_PEER_LOCALMSPID=cecMSP \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/ca.cec/ca.tls/tls-ca-tls-7052.pem \
    -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/admin/msp \
    -e CORE_PEER_ADDRESS=peer0.cec.com:7051 \
    -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.tls:/etc/hyperledger/ca.tls \
    -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.cec/ca.admin2.home/msp:/etc/hyperledger/admin/msp \
    -v /opt/local/codes/docker_with_ca_4/hyperledger_data:/etc/hyperledger/ordererdata \
    -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.orderer/ca.home:/etc/hyperledger/ca.orderer/ca.home \
    -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/orderer/tls/msp/tlscacerts:/etc/hyperledger/ca.orderer/ca.tls \
    -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/cec/peer0.home/tls/msp/tlscacerts:/etc/hyperledger/ca.cec/ca.tls \
    hyperledger/fabric-tools:1.4.3 \
    peer channel list 
```
