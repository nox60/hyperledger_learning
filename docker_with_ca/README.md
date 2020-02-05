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

# The following command uses the admin identity’s credentials to register a new identity with an enrollment id of “admin2”, an affiliation of “org1.department1”, an attribute named “hf.Revoker” with a value of “true”, and an attribute named “admin” with a value of “true”. The ”:ecert” suffix means that by default the “admin” attribute and its value will be inserted into the identity’s enrollment certificate, which can then be used to make access control decisions.
# 这里权限是 'hf.Revoker=true,admin=true' ，和上面的官方文档描述是有差异的，官方文档用的是 admin=true:ecert default the “admin” attribute and its value will be inserted into the identity’s enrollment certificate, which can then be used to make access control decisions
# 官方文档的意思是，如果用 --id.attrs 'hf.Revoker=true,admin=true:ecert', 表明会默认把 admin身份写入其证书？如果不跟ecert的话，会怎么样？

#fabric-ca-client register -d --id.name admin2 --id.affiliation org1.department1 --id.attrs '"hf.Registrar.Roles=peer,client",hf.Revoker=true'
# 上面的账户，表明能够注册两种类型的 MSP/CA，peer和client，需要实验一下

用docker 启动一个ca server
```用docker启动一个
docker rm -f test-ca
docker run \
  -it -d \
  --name test-ca \
      --network bc-net \
      -e FABRIC_CA_HOME="/opt/ca-home" \
      -e FABRIC_CA_SERVER_CA_NAME="test-ca" \
      -e FABRIC_CA_SERVER_PORT=7054 \
      -v /root/temp/test-ca-home:/opt/ca-home \
      --entrypoint="fabric-ca-server" hyperledger/fabric-ca:1.4.3  start  -b admin:adminpw -d
```

会生成这样的目录和文件结构：

```go
├── ca-cert.pem
├── fabric-ca-server-config.yaml
├── fabric-ca-server.db
├── IssuerPublicKey
├── IssuerRevocationPublicKey
└── msp
    └── keystore
        ├── ed76bf690cfa52ef372d241986981896c18232a806238c818e9a9cca6fe1431f_sk
        ├── IssuerRevocationPrivateKey
        └── IssuerSecretKey
```

把admin的msp拉出来
```go
docker run --rm -it \
--name enroll.test.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
-v /root/temp/test-ca-admin-home:/opt/test-admin-home \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client enroll \
-u http://admin:adminpw@test-ca:7054
```

会生成这样的目录结构
```dir
├── fabric-ca-client-config.yaml
└── msp
    ├── cacerts
    │   └── test-ca-7054.pem        //等于上面的 ca-cert.pem
    ├── IssuerPublicKey             //等于上面的 ssuerPublicKey
    ├── IssuerRevocationPublicKey
    ├── keystore
    │   └── 46b9002d4ebf9a2b565e2834b8f3573891646dd710de3f1cc3c7f800372bf2e0_sk
    ├── signcerts
    │   └── cert.pem
    └── user
```

//上面是没有启用HTTPS的，看看启用https之后有什么差异?

//尝试注册一个peer，看看是否有权限
```go
docker run --rm -it \
--name register.peer \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
-v /root/temp/test-ca-admin-home:/opt/test-admin-home \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client register \
--id.name peer --id.type peer  --id.secret peerpw
```

显示注册成功了，看起来，初始化的那个admin拥有非常高的权限

//注册一个没有peer注册权限的admin2，有client权限，看看是否有权限

1. 先注册
```go
docker run --rm -it \
--name register.peer \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
-v /root/temp/test-ca-admin-home:/opt/test-admin-home \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client register \
--id.name admin2 --id.type admin  --id.attrs '"hf.Registrar.Roles=client"' --id.secret admin2pw 
```

2. 把这个admin2的msp拉到本地
```go
docker run --rm -it \
--name enroll.test.ca.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/opt/test-admin2-home \
-v /root/temp/test-ca-admin2-home:/opt/test-admin2-home \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client enroll \
-u http://admin2:admin2pw@test-ca:7054
```

3. 利用刚刚那个admin2的msp进行注册
```go
docker run --rm -it \
--name register.peer2 \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/opt/test-admin2-home \
-v /root/temp/test-ca-admin2-home:/opt/test-admin2-home \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client register \
--id.name peer2 --id.type peer  --id.secret peer2pw 
```

4. 发现会报错，说权限不够
```go
Error: Response from server: Error Code: 45 - Failed to verify if user can act on type 'peer': : scode: 403, local code: 42, local msg: 'admin2' is not a registrar, remote code: 71, remote msg: Authorization failure
```

5. 注册一个client
```go
docker run --rm -it \
--name register.client \
--network bc-net \
-e FABRIC_CA_CLIENT_HOME=/opt/test-admin2-home \
-v /root/temp/test-ca-admin2-home:/opt/test-admin2-home \
hyperledger/fabric-ca:1.4.3 \
fabric-ca-client register \
--id.name client --id.type client  --id.secret clientpw 
```

发现顺利注册成功

接下来要测试的，

1. 是通过这个CA注册一个peer，然后和这个peer通信的时候，关掉这个ca，看看root ca是否能验证成功。这里好像是不需要，因为generate出来的各种ca证书，也是没有root ca服务供验证的
完成上面的注册peer, 然后把peer的msp拉下来。启动peer




2. 如果1成立，那么验证一个公钥是否是合法的公钥，就是看该公钥对应的rootca是否合法，这里如果我们手动替换一个rootca，看看能否通过。





此处要说明一下，为什么 FABRIC_CA_CLIENT_HOME 是 admin而不是admin2，因为此处执行操作的是admin账户，admin2成功注册之后不会生成账户msp信息，只会在ca的数据库中存在，需要在后面的操作中通过enroll操作才会将admin2的账户信息拉取到本地。


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





