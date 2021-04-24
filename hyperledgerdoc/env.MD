# 基本名词解析

hyperledger ca 官方文档地址：

https://hyperledger-fabric-ca.readthedocs.io/en/latest/

- X509

X.509是一种非常**通用的证书格式**。所有的证书都符合ITU-T X.509国际标准，因此(理论上)为一种应用创建的证书可以用于任何其他符合X.509标准的应用。


- Certificate Signing Request (CSR) 证书申请文件

CSR文件用来申请证书（提供给证书供应商）

CSR(证书请求文件) 包含申请证书所需要的相关信息，其中最重要的是域名，填写的域名必须是你要https方式访问的那个域名。如abc.com 或 web.abc.com


- 服务器CERTFILE

服务器公钥


- 服务器KEYFILE

服务器私钥


更多的关于ssl/tls的加密握手过程，参加以下文章：

https://www.cnblogs.com/barrywxx/p/8570715.html

https://www.cnblogs.com/monkey0307/p/9675123.html

https://blog.csdn.net/simatongming/article/details/79241158

PKI/CA相关

https://www.jianshu.com/p/c65fa3af1c01

# Git环境配置

Git的下载，安装参见官网。

此处重要需要解决的是Git的梯子问题，因为后面编译Hyperledge-ca的时候，Go是需要在github上获取一些依赖代码的，如果不设置梯子，可能会很慢，或者超时，此处的梯子需要自己的资源。

设置

```set
git config --global http.proxy 'http://127.0.0.1:1080'

git config --global https.proxy 'http://127.0.0.1:1080'

git config --global http.proxy 'socks5://127.0.0.1:1080'

git config --global https.proxy 'socks5://127.0.0.1:1080'
```

取消

```unset
git config --global --unset http.proxy

git config --global --unset https.proxy
```

# Nodejs


到：https://nodejs.org/download/release/ 下载一个稳定版本的nodejs，下面选择的是14.16.0版本

```downloadnodejs
wget https://npm.taobao.org/mirrors/node/v14.16.0/node-v14.16.0-linux-x64.tar.xz
```

解压

```unzip
tar -xvf node-v14.16.0-linux-x64.tar.xz
```
一般来说你会把解压后的目录做一些自己的安排，比如改名，移动到你指定的某个目录下，此处是放在了 /opt/local/node1416 这个目录下面。然后设置环境变量，以保证能够运行node程序。

```setpath
# ========== Nodejs settings =====================
export PATH=/opt/local/node1416/bin:$PATH
```

加入环境变量之后，通过下面的命令验证node的安装是否成功
```nodejs
[root@core-center software]# node -v
v14.16.0
```
能正确显示版本号，说明node安装成功

另外需要参考下面的帖子对 npm 的全局安装目录进行改动：

https://stackoverflow.com/questions/29468404/gyp-warn-eacces-user-root-does-not-have-permission-to-access-the-dev-dir

设置淘宝源：
```shell
npm config set registry https://registry.npm.taobao.org
```

# yarn

浏览器访问： https://github.com/yarnpkg/yarn/releases/

找到要下载的版本，本次下载的版本是：1.22.10

```shell
wget https://github.com/yarnpkg/yarn/releases/download/v1.22.10/yarn-v1.22.10.tar.gz
```

解压：
```shell
tar -xzvf yarn-v1.22.10.tar.gz
```

环境变量设置：
```shell
# ========== yarn ===============================
export PATH=$PATH:/opt/local/yarn-v1.22.10/bin
```

设置国内源：
```shell
yarn config set registry https://registry.npm.taobao.org
```

# Golang环境配置

需要到 https://studygolang.com/dl/

选择合适的版本进行下载，此处是LINUX故选择LINUX版本。

```aa
wget https://studygolang.com/dl/golang/go1.15.10.linux-amd64.tar.gz
```

解压

```unzip
tar xzf go1.15.10.linux-amd64.tar.gz
```

设置以下几个环境变量
```
# ========== Golang settings =====================
export GOROOT="/opt/local/bin/go"
export GOBIN="/opt/local/bin/go/bin"
export PATH=$GOROOT/bin:$PATH
export GO111MODULE=on
export GOPROXY=https://goproxy.cn,direct
```
其中，

GOROOT是指golang编译器的位置

GOPATH是指项目根目录的位置, 使用go get拉下来的代码和编译出的二进制文件会放在这个目录里。

GOBIN是指项目目录中bin目录所在的位置

# Hyberledger server

## 原生方式启动 fabric-ca-server

首先需要编译程序

```go
go get -u github.com/hyperledger/fabric-ca/cmd/...
```
执行之后，如果一切正常，GOPATH里面将会有拉下来的代码和编译之后的二进制文件。

验证编译是否成功，可以执行：fabric-ca-server version，应该有类似下面的输出：

```output
$ fabric-ca-server version
fabric-ca-server:
 Version: 1.4.2
 Go version: go1.12.7
 OS/Arch: linux/amd64
```

可以看到fabric-ca-server的版本和其他环境参数，说明fabric-ca-server安装成功

### 初始化服务器

```initserver
fabric-ca-server init -b admin:adminpw -H /root/ca-server/
```

以上命令会在 /root/ca-server初始化 fabric-ca-server 服务所需的文件

执行之后可以看到下面的输出：

```output
2019/07/24 15:51:23 [INFO] Created default configuration file at /root/ca-server/fabric-ca-server-config.yaml
2019/07/24 15:51:23 [INFO] Server Version: 1.4.2
2019/07/24 15:51:23 [INFO] Server Levels: &{Identity:2 Affiliation:1 Certificate:1 Credential:1 RAInfo:1 Nonce:1}
2019/07/24 15:51:23 [WARNING] &{69 The specified CA certificate file /root/ca-server/ca-cert.pem does not exist}
2019/07/24 15:51:23 [INFO] generating key: &{A:ecdsa S:256}
2019/07/24 15:51:23 [INFO] encoded CSR
2019/07/24 15:51:23 [INFO] signed certificate with serial number 183344645062561379720845729659759174911862589852
2019/07/24 15:51:23 [INFO] The CA key and certificate were generated for CA
2019/07/24 15:51:23 [INFO] The key was stored by BCCSP provider 'SW'
2019/07/24 15:51:23 [INFO] The certificate is at: /root/ca-server/ca-cert.pem
2019/07/24 15:51:23 [INFO] Initialized sqlite3 database at /root/ca-server/fabric-ca-server.db
2019/07/24 15:51:23 [INFO] The issuer key was successfully stored. The public key is at: /root/ca-server/IssuerPublicKey, secret key is at: /root/ca-server/msp/keystore/IssuerSecretKey
2019/07/24 15:51:23 [INFO] Idemix issuer revocation public and secret keys were generated for CA ''
2019/07/24 15:51:23 [INFO] The revocation key was successfully stored. The public key is at: /root/ca-server/IssuerRevocationPublicKey, private key is at: /root/ca-server/msp/keystore/IssuerRevocationPrivateKey
2019/07/24 15:51:23 [INFO] Home directory for default CA: /root/ca-server
2019/07/24 15:51:23 [INFO] Initialization was successful
```

从输出中可以看到各种证书文件的位置

以上操作生成了 fabric-ca-server-config.yaml 文件，文件中包含了 CSR 的配置信息，可以根据需要进行修改：

```csr
csr:
   cn: mytest-ca-server
   keyrequest:
     algo: ecdsa
     size: 256
   names:
      - C: US
        ST: "North Carolina"
        L:
        O: Hyperledger
        OU: Fabric
   hosts:
     - ethereum-192-168-16-60
     - localhost
   ca:
      expiry: 131400h
      pathlength: 1
```

此处修改了CSR信息，然后重新用下面的命令

```ssl

fabric-ca-server init -b admin:adminpw -H /root/ca-server/ \
--ca.certfile mytest_cert.pem 
```

init命令会生成一系列文件，文件相关说明如下：

| 路径与文件名       |  说明|
| ---------  | ------- |
|   fabric-ca-server-config.yaml   |  CA服务端配置文件  |
|   ca-cert.pem   |  CA服务器公钥  |
|   IssuerPublicKey  |  CA服务器Issuer公钥，会下发到客户端  |
|   IssuerRevocationPublicKey   |  CA服务器IssuerRevocation公钥，会下发到客户端  |
|   fabric-ca-server.db   |  CA服务器DB文件？TD：  |
|   msp/keystore/xxxxxxxxxxxxxxxxxxxxxx_sk   |  CA服务器私钥  |
|   msp/keystore/IssuerSecretKey   |   CA服务器Issuer私钥  |
|   msp/keystore/IssuerRevocationPrivateKey   |  CA服务器IssuerRevocation私钥  |



## 参数说明

| 缩写       |  参数     | 参类型  | 说明      | 例子|
| ---------  | --------- | ----   | -------   | --- |
|      | -&zwnj;-address      | string    | fabric-ca-server 监听地址 (默认) "0.0.0.0")  | <a name="锚点名称">例子</a>|
| -b     | -&zwnj;-boot       | string    | The user:pass for bootstrap admin which is required to build default config file  | <a href="#start_ca_server">例子</a> |
|  | -&zwnj;-ca.certfile | string    | PEM编码格式的ca公钥文件 (默认为) "ca-cert.pem")  | <a name="锚点名称">例子</a> |
|  | -&zwnj;-ca.chainfile | string    | PEM-encoded CA chain file (default "ca-chain.pem")  | <a name="锚点名称">例子</a> |
|  | -&zwnj;-ca.keyfile | string    | PEM编码格式的ca私钥文件，注意，keyfile是无法指定生成的文件名和路径的，本参数的意义是在启动的时候，指定keyfile的位置，keyfile的指定生成位置是在 msp/keystore 目录下  | <a name="锚点名称">例子</a> |
| -H | -&zwnj;-home | string    | 服务端home目录，默认当前目录 | <a name="init_ca_server">例子</a> | 



<a name="init_ca_server">用以下的命令初始化fabirc-ca-server，初始化命令不会启动ca-server，只会生成相应的文件</a>

```init
fabric-ca-server init -b admin:adminpw -H /root/ca-server/
```

<a name="start_ca_server">用以下的命令启动fabirc-ca-server，如果该服务器没有启动过，则等同于先初始化，再启动 </a>

```start
fabric-ca-server start -b admin:adminpw -H /root/ca-server/ \
```

初始化命令会在 /root/ca-server目录下生成以下文件：

```files
-rw-r--r--. 1 root root 19797 Jul 18 14:14 fabric-ca-server-config.yaml
drwxr-xr-x. 3 root root  4096 Jul 18 14:14 msp
-rw-r--r--. 1 root root   786 Jul 18 14:14 ca-cert.pem
-rw-r--r--. 1 root root   843 Jul 18 14:14 IssuerPublicKey
-rw-r--r--. 1 root root   215 Jul 18 14:14 IssuerRevocationPublicKey
-rw-r--r--. 1 root root 61440 Jul 18 14:14 fabric-ca-server.db
```

## Docker方式启动 fabric-ca-server

to do

# Hyberledger client

以下面的命令以为admin账户登录

```client
export FABRIC_CA_CLIENT_HOME=/root/ca-client
fabric-ca-client enroll -u http://admin:adminpw@localhost:7054
```
如果这是第一次在该机器上登录，会发现上面所指定的 FABRIC_CA_CLIENT_HOME 目录 /root/ca-client 里会生成一些文件：

| 路径与文件名       |  说明|
| ---------  | ------- |
|   fabric-ca-client-config.yaml   |  客户端配置文件  |
|   msp/IssuerPublicKey   |  Issuer方公钥？TD：需要验证  |
|   msp/IssuerRevocationPublicKey   |  CA吊销使用的公钥？  |
|   msp/keystore/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx_sk   | 客户私钥文件  |
|   msp/signcerts/cert.pem   |  客户公钥文件  |



## 参数说明

| 缩写       |  参数     | 参类型  | 说明      | 例子|
| ---------  | --------- | ----   | -------   | --- |
|      | -&zwnj;-address      | string    | fabric-ca-server 监听地址 (默认) "0.0.0.0")  | <a name="锚点名称">例子</a>|
| -b     | -&zwnj;-boot       | string    | The user:pass for bootstrap admin which is required to build default config file  | <a href="#start_ca_server">例子</a> |
|  | -&zwnj;-ca.certfile | string    | PEM-encoded CA certificate file (default "ca-cert.pem")  | <a name="锚点名称">例子</a> |
| -H | -&zwnj;-home | string    | 服务端home目录，默认当前目录 | <a name="锚点名称">例子</a> | 


- 注册新用户

注册用户之前，需要使用具有权限的账户（admin）登录。

下面的命令是用admin账户来注册一个新的账户 "admin2"，所属的机构是"org1.department1", ":ecert"后缀表明这个admin属性将会插入这个账户的enrollment certificat. 然后用与权限控制。 suffix means that by default the “admin” attribute and its value will be inserted into the identity’s enrollment certificate, which can then be used to make access control decisions.

maxenrollments 参数需要进行验证


```register
export FABRIC_CA_CLIENT_HOME=/root/ca-client
fabric-ca-client register \
--id.name admin2 \
--id.affiliation org1.department1 \
--id.attrs 'hf.Revoker=true,admin=true:ecert'
```

执行上面的命令之后，会看到有密码的输出，密码是自动生成的，类是这样的输出：

```passwdprint
Password: ziGRSLUqBXPT
```

- 注册peer

```registerpeer
export FABRIC_CA_CLIENT_HOME=/root/ca-client
fabric-ca-client register \
--id.name peer1 \
--id.type peer \
--id.affiliation org1.department1 \
--id.secret peer1pw
```

会输出以下信息：

```aa
2019/07/20 15:55:41 [INFO] Configuration file location: /root/ca-client/fabric-ca-client-config.yaml
Password: peer1pw
```

- 登录 peer

登录peer的时候应该是要指定其自己的目录

```enrollpeer
export FABRIC_CA_CLIENT_HOME=/root/peer1
fabric-ca-client enroll -u http://peer1:peer1pw@localhost:7054 -M $FABRIC_CA_CLIENT_HOME/msp
```
该操作执行后，则类似上面的admin类型的用户登录一样，会生peer节点相关的各种密钥文件，存放位置在/root/peer1里面


- 用户登录

试试用错误的密码登录

```trytouserwrongpassword
export FABRIC_CA_CLIENT_HOME=/root/ca-client/clients/peer1
fabric-ca-client enroll -u http://peer1:peer1wrongpassword@localhost:7054 -M $FABRIC_CA_CLIENT_HOME/msp
```

会看到有如下的输出：

```wrongpasswordoutput
2019/07/20 16:10:17 [INFO] Created a default configuration file at /root/ca-client/clients/peer1/fabric-ca-client-config.yaml
2019/07/20 16:10:17 [INFO] generating key: &{A:ecdsa S:256}
2019/07/20 16:10:17 [INFO] encoded CSR
Error: Response from server: Error Code: 20 - Authentication failure
```

使用正确密码登录：

```enrollpeer
export FABRIC_CA_CLIENT_HOME=/root/ca-client/clients/peer1
fabric-ca-client enroll -u http://peer1:peer1pw@localhost:7054 -M $FABRIC_CA_CLIENT_HOME/msp
```

会看到有以下输出：


TD：解释相关生成的KEY是什么

```output
2019/07/20 16:12:12 [INFO] generating key: &{A:ecdsa S:256}
2019/07/20 16:12:12 [INFO] encoded CSR
2019/07/20 16:12:12 [INFO] Stored client certificate at /root/ca-client/clients/peer1/msp/signcerts/cert.pem
2019/07/20 16:12:12 [INFO] Stored root CA certificate at /root/ca-client/clients/peer1/msp/cacerts/localhost-7054.pem
2019/07/20 16:12:12 [INFO] Stored Issuer public key at /root/ca-client/clients/peer1/msp/IssuerPublicKey
2019/07/20 16:12:12 [INFO] Stored Issuer revocation public key at /root/ca-client/clients/peer1/msp/IssuerRevocationPublicKey
```

client certificate：  client的公钥

CA certificate:       CA的公钥？

Issuer public key:

Issuer revocation public key:



TD：此处要尝试使用另外一个账户登录，但是路径一样会发生什么

TD：是否有了各种证书，就不需要密码就可以操作了？


- Identity Mixer credential

Identity Mixer (Idemix) 是一种加密协议。。。。

Identity Mixer (Idemix) is a cryptographic protocol suite for privacy-preserving authentication and transfer of certified attributes. Idemix allows clients to authenticate with verifiers without the involvement of the issuer (CA) and selectively disclose only those attributes that are required by the verifier and can do so without being linkable across their transactions.


Fabirc CA server 除了可以签发Idemix证书以外还可以签发X509证书。Idemix证书可以从 /api/v1/idemix/credential 接口获取，更多的信息可以查阅相关接口文档。

申请Idemix证书有两个步骤：

1. 首先发一个空的body信息到 /api/v1/idemix/credential 获取一个 nonce 以及 CA 的 Idexmix 公钥。
2. 用nonce和CA创建一个证书请求，发送到 /api/v1/idemix/credential 来获取 Idemix。同时会拿到(Credential Revocation Information)CRI信息，当前，只支持三种参数：

OU - organization unit of the identity. The value of this attribute is set to identity’s affiliation. For example, if identity’s affiliation is dept1.unit1, then OU attribute is set to dept1.unit1

IsAdmin - if the identity is an admin or not. The value of this attribute is set to the value of isAdmin registration attribute.

EnrollmentID - enrollment ID of the identity


TD：CRI的作用？CRI应该是用来终止这个Idemix的。不想用了。。

后面明确一下。


文档中交代了Idemix和X509的注销差异：

TD：后面要实验

In X509, the issuer revokes an end user’s certificate and its ID is included in the CRL. The verifier checks to see if the user’s certificate is in the CRL and if so, returns an authorization failure. The end user is not involved in this revocation process, other than receiving an authorization error from a verifier.

In Idemix, the end user is involved. The issuer revokes an end user’s credential similar to X509 and evidence of this revocation is recorded in the CRI. The CRI is given to the end user (aka “prover”). The end user then generates a proof that their credential has not been revoked according to the CRI. The end user gives this proof to the verifier who verifies the proof according to the CRI. For verification to succeed, the version of the CRI (known as the “epoch”) used by the end user and verifier must be same. The latest CRI can be requested by sending a request to /api/v1/idemix/cri API endpoint.

The version of the CRI is incremented when an enroll request is received by the fabric-ca-server and there are no revocation handles remaining in the revocation handle pool. In this case, the fabric-ca-server must generate a new pool of revocation handles which increments the epoch of the CRI. The number of revocation handles in the revocation handle pool is configurable via the idemix.rhpoolsize server configuration property.












