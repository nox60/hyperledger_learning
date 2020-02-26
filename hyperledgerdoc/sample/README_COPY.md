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
    -u http://admin:adminpw@ca.com:7054
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
-u http://admin2:admin2pw@ca.com:7054
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
    --id.affiliation ordererOrg.ordererMSP \
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

拉取msp
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

注册一个peer0
```go
rm -rf /root/temp/peer0-home
docker run --rm -it \
    --name register.peer0 \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client register \
    --id.name peer0 --id.type peer  --id.secret peerpw 
```

拉取tls
```go
docker run --rm -it \
  --name enroll.cec.peer0 \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/opt/peer0-home \
      -v /root/temp/peer0-home/tls:/opt/peer0-home \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      --enrollment.profile tls --csr.hosts peer0.com \
      -u http://peer0:peerpw@ca.com:7054
```

修改tls中的私钥文件名
```shell script
mv /root/temp/peer0-home/tls/msp/keystore/* /root/temp/peer0-home/tls/msp/keystore/server.key
mv /root/temp/peer0-home/tls/msp/signcerts/* /root/temp/peer0-home/tls/msp/signcerts/server.crt
mv /root/temp/peer0-home/tls/msp/tlscacerts/* /root/temp/peer0-home/tls/msp/tlscacerts/ca.crt
```

拉取msp
```go
docker run --rm -it \
  --name enroll.cec.peer0 \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/opt/peer0-home-msp \
      -v /root/temp/peer0-home/msp:/opt/peer0-home-msp \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -M /opt/peer0-home-msp/msp \
      -u http://peer0:peerpw@ca.com:7054
```

mv /root/temp/peer0-home/msp/msp/cacerts/* /root/temp/peer0-home/msp/msp/cacerts/ca.pem

# 给peer0节点创建 config.yaml文件
```shell
cat>/root/temp/peer0-home/msp/msp/config.yaml<<EOF
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

# 生成configtx.yaml文件

-1. 各种msp生成完毕之后，生成创世区块
```go
docker run --rm -it \
  --name configtxgen.generate.files \
      --network bc-net \
      -e FABRIC_CFG_PATH=/etc/hyperledger/ \
      -v /root/temp/:/opt/data \
      -v /root/temp/configtx.yaml:/etc/hyperledger/configtx.yaml \
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
      --network bc-net \
      -e FABRIC_CFG_PATH=/etc/hyperledger/ \
      -v /root/temp/:/opt/data \
      -v /root/temp/configtx.yaml:/etc/hyperledger/configtx.yaml \
      -w /etc/hyperledger \
      hyperledger/fabric-tools:1.4.3 \
      configtxgen \
      -profile TwoOrgsChannel \
      -outputCreateChannelTx /opt/data/channel.tx \
      -channelID mychannel
```

```go

Global Flags:
      --caname string                  Name of CA
      --csr.cn string                  The common name field of the certificate signing request
      --csr.hosts stringSlice          A list of comma-separated host names in a certificate signing request
      --csr.keyrequest.algo string     Specify key algorithm
      --csr.keyrequest.size int        Specify key size
      --csr.names stringSlice          A list of comma-separated CSR names of the form <name>=<value> (e.g. C=CA,O=Org1)
      --csr.serialnumber string        The serial number in a certificate signing request
      --enrollment.attrs stringSlice   A list of comma-separated attribute requests of the form <name>[:opt] (e.g. foo,bar:opt)
      --enrollment.label string        Label to use in HSM operations
      --enrollment.profile string      Name of the signing profile to use in issuing the certificate
      --enrollment.type string         The type of enrollment request: 'x509' or 'idemix' (default "x509")
  -H, --home string                    Client's home directory (default "/opt/peer0-home")
      --id.affiliation string          The identity's affiliation
      --id.attrs stringSlice           A list of comma-separated attributes of the form <name>=<value> (e.g. foo=foo1,bar=bar1)
      --id.maxenrollments int          The maximum number of times the secret can be reused to enroll (default CA's Max Enrollment)
      --id.name string                 Unique name of the identity
      --id.secret string               The enrollment secret for the identity being registered
      --id.type string                 Type of identity being registered (e.g. 'peer, app, user') (default "client")
      --loglevel string                Set logging level (info, warning, debug, error, fatal, critical)
  -M, --mspdir string                  Membership Service Provider directory (default "msp")
  -m, --myhost string                  Hostname to include in the certificate signing request during enrollment (default "a2fc115b3b43")
  -a, --revoke.aki string              AKI (Authority Key Identifier) of the certificate to be revoked
  -e, --revoke.name string             Identity whose certificates should be revoked
  -r, --revoke.reason string           Reason for revocation
  -s, --revoke.serial string           Serial number of the certificate to be revoked
      --tls.certfiles stringSlice      A list of comma-separated PEM-encoded trusted certificate files (e.g. root1.pem,root2.pem)
      --tls.client.certfile string     PEM-encoded certificate file when mutual authenticate is enabled
      --tls.client.keyfile string      PEM-encoded key file when mutual authentication is enabled
  -u, --url string                     URL of fabric-ca-server (default "http://localhost:7054")

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

启动peer0的couchdb
```go
docker rm -f couchdb_cec
docker run -it -d  \
    --name couchdb_peer0 \
    --network bc-net \
    -e COUCHDB_USER=admin \
    -e COUCHDB_PASSWORD=dev@2019  \
    -v /root/temp/peer0-home/couchdb:/opt/couchdb/data \
    -p 5984:5984 \
    -p 9100:9100 \
    -d hyperledger/fabric-couchdb
```


启动peer0
```go

docker rm -f peer0.com
docker run -it -d \
  --name peer0.com \
      --network bc-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/signcerts/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/keystore/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/tlscacerts/ca.crt" \
      -e CORE_PEER_ID="peer0.com" \
      -e CORE_PEER_ADDRESS="peer0.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.com:7051" \
      -e CORE_PEER_LOCALMSPID="cecMSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_peer0:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_NOTEOUS_ENABLE="false" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="bc-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /root/temp/peer0-home/msp/msp:/etc/hyperledger/fabric/msp \
      -v /root/temp/peer0-home/tls/msp:/etc/hyperledger/fabric/tls \
      -v /root/temp/peer0-home/production:/var/hyperledger/production \
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
    --id.affiliation ordererOrg.ordererMSP \
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




# 创建通道
```go
docker run --rm -it \
    --name create.channel.client \
    --network bc-net \
    -e CORE_PEER_LOCALMSPID=peer0MSP \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/msp/cacerts/ca-com-7054.pem \
    -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp \
    -v /root/temp/orderer-admin-home/msp:/etc/hyperledger/fabric/msp \
    -v /root/temp/channel.tx:/etc/hyperledger/orderer_data/channel.tx \
    hyperledger/fabric-tools:1.4.3 \
    peer channel create --outputBlock /etc/hyperledger/ordererdata/mychannel.block -o orderer.com:7050 \
    -c mychannel \
    -f /etc/hyperledger/orderer_data/channel.tx \
    --tls true \
    --cafile /etc/hyperledger/fabric/tls/tlscacerts/ca.crt 
```






















2. 如果1成立，那么验证一个公钥是否是合法的公钥，就是看该公钥对应的rootca是否合法，这里如果我们手动替换一个rootca，看看能否通过。





此处要说明一下，为什么 FABRIC_CA_CLIENT_HOME 是 admin而不是admin2，因为此处执行操作的是admin账户，admin2成功注册之后不会生成账户msp信息，只会在ca的数据库中存在，需要在后面的操作中通过enroll操作才会将admin2的账户信息拉取到本地。



































































=========================================

















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
    -u http://admin:adminpw@ca.com:7054
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
-u http://admin2:admin2pw@ca.com:7054
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
    --id.affiliation ordererOrg.ordererMSP \
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

拉取msp
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

注册一个peer0
```go
rm -rf /root/temp/peer0-home
docker run --rm -it \
    --name register.peer0 \
    --network bc-net \
    -e FABRIC_CA_CLIENT_HOME=/opt/test-admin-home \
    -v /root/temp/test-ca-admin-home:/opt/test-admin-home \
    hyperledger/fabric-ca:1.4.3 \
    fabric-ca-client register \
    --id.name peer0 --id.type peer  --id.secret peerpw 
```

拉取tls
```go
docker run --rm -it \
  --name enroll.cec.peer0 \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/opt/peer0-home \
      -v /root/temp/peer0-home/tls:/opt/peer0-home \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      --enrollment.profile tls --csr.hosts peer0.com \
      -u http://peer0:peerpw@ca.com:7054
```

修改tls中的私钥文件名
```shell script
mv /root/temp/peer0-home/tls/msp/keystore/* /root/temp/peer0-home/tls/msp/keystore/server.key
mv /root/temp/peer0-home/tls/msp/signcerts/* /root/temp/peer0-home/tls/msp/signcerts/server.crt
mv /root/temp/peer0-home/tls/msp/tlscacerts/* /root/temp/peer0-home/tls/msp/tlscacerts/ca.crt
```

拉取msp
```go
docker run --rm -it \
  --name enroll.cec.peer0 \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/opt/peer0-home-msp \
      -v /root/temp/peer0-home/msp:/opt/peer0-home-msp \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -M /opt/peer0-home-msp/msp \
      -u http://peer0:peerpw@ca.com:7054
```

mv /root/temp/peer0-home/msp/msp/cacerts/* /root/temp/peer0-home/msp/msp/cacerts/ca.pem

# 给peer0节点创建 config.yaml文件
```shell
cat>/root/temp/peer0-home/msp/msp/config.yaml<<EOF
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

# 生成configtx.yaml文件

-1. 各种msp生成完毕之后，生成创世区块
```go
docker run --rm -it \
  --name configtxgen.generate.files \
      --network bc-net \
      -e FABRIC_CFG_PATH=/etc/hyperledger/ \
      -v /root/temp/:/opt/data \
      -v /root/temp/configtx.yaml:/etc/hyperledger/configtx.yaml \
      -w /etc/hyperledger \
      hyperledger/fabric-tools:1.4.3 \
      configtxgen \
      -outputBlock /opt/data/orderer.genesis.block \
      -channelID byfn-sys-channel \
      -profile TwoOrgsOrdererGenesis
```
