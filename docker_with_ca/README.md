# 基于自建ca的docker

本文目前旨在解决的问题是如何使用CA来对hyperledger中的各种身份进行验证。

在之前的文章中，我们介绍了用DOCKER启动和秘钥生成工具生成各种密钥的方式。

首先，需要了解关于证书的各种知识。

非对称秘钥对是用来实现SSL加密传输的核心知识。

通过openssl工具可以生成对应的公私秘钥对



# msp目录数据分析

该目录是该 peer 所对应的 org 的 ca 信息
/root/codes/hyperledger_learning/docker2/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/ca

如果自己启动一个ca，可以用该公私钥对来启动ca


然后关注目录：

/root/codes/hyperledger_learning/docker2/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/msp
/root/codes/hyperledger_learning/docker2/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/peers/peer1.cec.dams.com/msp

进行对比发现：
cacerts 目录内的信息一致，也可以确定cacerts里面的内容，是该org所对应的ca的公钥
可以用命令进行分析
```cassandraql
openssl x509 -in  ca.cec.dams.com-cert.pem -noout -text
```

keystore 目录应该是该peer的私钥
通过对比peer1的对应文件可以发现是有差异的
```cassandraql
diff /root/codes/hyperledger_learning/docker2/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/msp/keystore/* /root/codes/hyperledger_learning/docker2/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/peers/peer1.cec.dams.com/msp/keystore/*
```

signcerts 目录是该peer的公钥
通过对比peer1的对应文件可以发现是有差异的

```cgo
diff /root/codes/hyperledger_learning/docker2/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/msp/signcerts/*pem /root/codes/hyperledger_learning/docker2/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/peers/peer1.cec.dams.com/msp/signcerts/*pem
```


tlscacerts 则是用于tls通信的公钥？
通过对比可以发现，两个peer的这个公钥文件是一致的：

```cassandraql
diff /root/codes/hyperledger_learning/docker2/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/msp/tlscacerts/*pem /root/codes/hyperledger_learning/docker2/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/peers/peer1.cec.dams.com/msp/tlscacerts/*pem
```

生成工具所生成的两个文件是一致的，因为同一个org使用同一个ca：

```cgo
/opt/local/codes/docker2/hyperledger_data/crypto-config/ordererOrganizations/dams.com/orderers/orderer.dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem 
/opt/local/codes/docker2/hyperledger_data/crypto-config/ordererOrganizations/dams.com/orderers/orderer.dams.com/tls/ca.crt
```

而生成工具所生成的下面两个文件是不一致的，说明这两个私钥，第一个是用于XXX

第二个则是用于建立tls连接时，peer的tls私钥

```cgo
/opt/local/codes/docker2/hyperledger_data/crypto-config/ordererOrganizations/dams.com/orderers/orderer.dams.com/msp/keystore/4174565b5e7d72f524ac8d2297a982cf24e658f125e1b84617cf9dbe58595181_sk 
/opt/local/codes/docker2/hyperledger_data/crypto-config/ordererOrganizations/dams.com/orderers/orderer.dams.com/tls/server.key
```

从上面可以推测出，节点有自己身份的公私钥，也有用于tls的公私钥，如果把tls的公私钥配置成节点身份的公私钥，其实也是行得通的，下面的试验证明：


至此，可以了解到msp目录中的结构如下图所示：


实验内容：

1. 生成创世区块。

-- 登录到ca的容器里面生成

-- 利用ca-client容器生成

用准备好的公私钥启动CA，然后通过该CA注册账号，然后enroll账号，查看所获取到的cacert（CA公钥）是否和CA注册时候的一致。


1.enroll admin用户

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

上面的命令会拉起一个容器，名为login.admin.ca.client，该容器会执行enroll命令并且获取到admin的相关证书信息，执行完之后该容器自动销毁。
获取到得证书文件等信息，在
```dir
/opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/users/admin 
```
目录中。

注意到之前提到过的 IssuerPublicKey

此时对比一下，

```shell
diff \
/opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/users/admin/msp/cacerts/ca-cec-dams-com-7054.pem \
/opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/ca/ca.cec.dams.com-cert.pem
```

证明是同一个文件

2. 创建第二个admin用户，使用密码 admin2pw

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
--id.name admin2  --id.attrs 'hf.Revoker=true,admin=true' --id.secret admin2pw \
-u https://ca.cec.dams.com:7054
```

此处要说明一下，为什么 FABRIC_CA_CLIENT_HOME 是 admin而不是admin2，因为此处执行操作的是admin账户，admin2成功注册之后不会生成账户msp信息，只会在ca的数据库中存在，需要在后面的操作中通过enroll操作才会将admin2的账户信息拉取到本地。



3. 将该admin用户(用户名admin2)的msp拉取到本地

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



4. 用admin2账户来进行通道创建操作

```cgo
docker exec -it cli \
peer channel create -o orderer.dams.com:7050 \
-c mychannel \
-f /opt/channel-artifacts/channel.tx \
--tls true \
--cafile /opt/crypto/ordererOrganizations/dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem
```