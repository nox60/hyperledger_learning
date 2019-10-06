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



至此，可以了解到msp目录中的结构如下图所示：

