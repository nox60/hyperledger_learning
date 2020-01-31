

























--------



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
