# 本文目标

本文的目标是让用户能够从裸虚拟机尽快的上手智能合约安装部署到例子代码编写

# 基础环境准备

要完成本文的所有任务，需要准备好一台虚拟机，建议使用CentOS 7.2以上版本，但并不代表其他版本Linux不适用。在完成虚拟机安装之后，要完成下面的工作：

## 全局梯子设置

因为hyperledger很多依赖在github上，虽然没有被墙，但是直接安装速度会非常慢，梯子的安装配置不是本文要讨论的目标，此处假设读者会自己安装和配置好梯子，此处只是给建议的设置，有更好的其他方式请自行研究，下面的设置是假设设置在本机的1080端口：

```export
export ALL_PROXY=socks5://127.0.0.1:1080
```

在下载速度较快的资源比如国内有的资源的时候，可以选择关闭梯子，操作如下：
```export
export ALL_PROXY=
```

## Docker

docker安装有多种方式，有使用apt-get或者yum工具进行安装，此处给出的是略微复杂但是可以高度定制化的二进制安装方式：

到  https://download.docker.com/linux/static/stable/x86_64/ 下载需要版本的docker

此处需要提及的是，如果没有上述的梯子来加速下载，下载速度可能会很慢。

```docker
curl -O https://download.docker.com/linux/static/stable/x86_64/docker-18.09.8.tgz
```


解压

```unzip
tar -xzvf docker-18.09.8.tgz
```

docker-compose 安装

到：https://github.com/docker/compose/releases/ 下载需要的版本的docker compose

```dockercompse
curl -L -O https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)

```

将下载下来的docker-compose文件更名为：docker-compose，然后赋予777 级别的权限

```mv
mv docker-compose-Linux-x86_64 docker-compose
chmod 777 docker-compose
```

将docker-compose文件和上面的docker二进制文件放在一起，并将整个目录放在一个妥善的位置，比如 /opt/local/docker 这样的目录结构

```mvdocker
mv docker /opt/local/bin/
mv docker-compose /opt/local/bin/docker/ 
```

编辑下面的文件，文件名为docker.service, 注意这两行，要和上面的路径对应：

Environment="PATH=/opt/local/bin/docker:/bin:/sbin:/usr/bin:/usr/sbin"
ExecStart=/opt/local/bin/docker/dockerd --log-level=error

vi docker.service

```file
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.io

[Service]
Environment="PATH=/opt/local/bin/docker:/bin:/sbin:/usr/bin:/usr/sbin"
ExecStart=/opt/local/bin/docker/dockerd --log-level=error
ExecReload=/bin/kill -s HUP $MAINPID
Restart=on-failure
RestartSec=5
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
```

**将该文件放到目录：/etc/systemd/system/ 下面**

```mv
mv docker.service /etc/systemd/system/
```

在 /etc/ 目录下增加 docker 目录，然后增加文件 /etc/docker/daemon.json

内容如下，并保存：

```aa
{
    "registry-mirrors": ["http://813c39a0.m.daocloud.io"],
    "max-concurrent-downloads": 20
}
```

增加环境变量

export PATH=/opt/local/bin/docker:$PATH

然后生效

```aa
source /etc/profile
```

关闭selinux(重要)


执行下面命令关闭selinux

```d
setenforce 0
```

然后修改 /etc/sysconfig/selinux 文件中的 SELINUX=disabled，防止selinux在系统重启之后被打开

执行下面命令启动docker：

```ss
systemctl stop firewalld
systemctl disable firewalld
systemctl daemon-reload
systemctl start docker
```

检查docker 版本是否正确

```dockerversion
docker version
```

如果有下面输出表示docker服务正常
```ss
Client: Docker Engine - Community
 Version:           18.09.8
 API version:       1.39
 Go version:        go1.10.8
 Git commit:        0dd43dd87f
 Built:             Wed Jul 17 17:38:58 2019
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          18.09.8
  API version:      1.39 (minimum version 1.12)
  Go version:       go1.10.8
  Git commit:       0dd43dd87f
  Built:            Wed Jul 17 17:48:49 2019
  OS/Arch:          linux/amd64
  Experimental:     false
```

检查docker-compose 版本看看是否正确
```dockercompose
docker-compose version
```

如果有下面输出表示docker-compose正常
```aaa
docker-compose version 1.21.2, build a133471
docker-py version: 3.3.0
CPython version: 3.6.5
OpenSSL version: OpenSSL 1.0.1t  3 May 2016
```

拉一个镜像看看docker加速器是否启用：

```dockerpull
docker pull mysql
```

如果看到镜像拉取速度较快，说明上面的docker加速器配置正确。至此，docker和docker compose安装完成

## Git 

系统自带的git版本太低，先卸载掉：
```removegit
yum remove git
```

然后到 https://mirrors.edge.kernel.org/pub/software/scm/git/ 找到合适的版本，此处选择了2.9.5版

```downloadgit
wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.9.5.tar.gz
```

下载之后解压，进入解压之后的路径。

编译git之前，要升级系统，以及安装一系列依赖工具，执行如下命令：

```update
yum -y update
yum -y install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker
```

上面的命令成功执行完之后，将git编译安装到 /opt/local/git 目录下

```gitbuild
make prefix=/opt/local/git all
make prefix=/opt/local/git install
```

可以看到git已经安装到/opt/local/git目录下，现在需要增加下面的环境变量(注意路径正确)：

```githong
# ========== git settings =====================
GIT_HOME=/opt/local/git/bin
PATH=$GIT_HOME:$PATH
export PATH
```

执行git version，看到正确的版本信息，说明安装成功
```newgit
# git version
git version 2.9.5
```

## Golang


需要到 https://golang.org/dl/

选择合适的版本进行下载，此处是LINUX故选择LINUX版本。

```aa
curl -O  https://dl.google.com/go/go1.10.linux-amd64.tar.gz
```

解压

```unzip
tar xzf go1.10.linux-amd64.tar.gz
```

将解压的目录移到合适的位置，比如 /opt/local/go

设置以下几个环境变量
```
# ========== Golang settings =====================
export GOROOT="/opt/local/go"
export GOPATH="/root/goprojects"
export GOBIN=$GOPATH/bin
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
```
其中需要注意的是：

GOROOT是指golang编译器的位置

GOPATH是指项目根目录的位置, 使用go get拉下来的代码和编译出的二进制文件会放在这个目录里。

GOBIN是指项目目录中bin目录所在的位置

# 区块链环境准备

## 安装各种二进制程序和容器

执行下面的命令，会下载hyperledger-fabric相关代码进行编译，构建二进制可执行程序和构建容器镜像

```images
curl -sSL  http://bit.ly/2ysbOFE | bash -s
```

安装完成之后，通过下面的命令验证是否安装正常：

```gene
cryptogen version
```

如果出现下面的结果，说明安装正常：

```version
cryptogen:
 Version: 1.4.3
 Commit SHA: b8c4a6a
 Go version: go1.11.5
 OS/Arch: linux/amd64
```

## 下载代码


```gitclone
git clone https://github.com/nox60/hyperledger_learning.git
```

将工程目录中的docker2 目录拷贝到 /opt/local/codes/ 下面，注意这里之所以需要固定到该目录，是因为代码中有不少绝对路径指定了该目录，在熟悉之后可以自行改动。

此处使用软连接方式：

```mv
ln -s /root/codes/hyperledger_learning/docker2 /opt/local/codes/docker2
```

## 生成相关证书文件

执行同级目录下的：

### 首先需要执行同级目录下的：
```aa
generate.sh
```
脚本文件。

### 然后执行：
```bb
start.sh
```
拉起所有容器。

### 通过cli容器执行下列命令
```aa
# 创建通道
docker exec -it cli \
peer channel create -o orderer.dams.com:7050 \
-c mychannel \
-f /opt/channel-artifacts/channel.tx \
--tls true \
--cafile /opt/crypto/ordererOrganizations/dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem
```

```k
# cec组织加入通道
docker exec -it \
-e CORE_PEER_LOCALMSPID=cecMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/Admin@cec.dams.com/msp \
-e CORE_PEER_ADDRESS=peer0.cec.dams.com:7051 \
cli \
peer channel join -b mychannel.block
```

```dd
# ia3组织加入通道
docker exec -it \
-e CORE_PEER_LOCALMSPID=ia3MSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/ia3.dams.com/peers/peer0.ia3.dams.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/ia3.dams.com/users/Admin@ia3.dams.com/msp \
-e CORE_PEER_ADDRESS=peer0.ia3.dams.com:7151 \
cli \
peer channel join -b mychannel.block
```

```ss
# ic3组织加入通道
docker exec -it \
-e CORE_PEER_LOCALMSPID=ic3MSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/ic3.dams.com/peers/peer0.ic3.dams.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/ic3.dams.com/users/Admin@ic3.dams.com/msp \
-e CORE_PEER_ADDRESS=peer0.ic3.dams.com:7251 \
cli \
peer channel join -b mychannel.block
```

```d
# gov组织加入通道
docker exec -it \
-e CORE_PEER_LOCALMSPID=govMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/gov.dams.com/peers/peer0.gov.dams.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/gov.dams.com/users/Admin@gov.dams.com/msp \
-e CORE_PEER_ADDRESS=peer0.gov.dams.com:7351 \
cli \
peer channel join -b mychannel.block
```

```d
# 锚节点
docker exec -it \
-e CORE_PEER_LOCALMSPID=cecMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/Admin@cec.dams.com/msp \
-e CORE_PEER_ADDRESS=peer0.cec.dams.com:7051 \
cli \
peer channel update \
-o orderer.dams.com:7050 \
-c mychannel \
-f /opt/channel-artifacts/cecMSPanchors.tx \
--tls true \
--cafile /opt/crypto/ordererOrganizations/dams.com/orderers/orderer.dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem
```

```2
docker exec -it \
-e CORE_PEER_LOCALMSPID=ia3MSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/ia3.dams.com/peers/peer0.ia3.dams.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/ia3.dams.com/users/Admin@ia3.dams.com/msp \
-e CORE_PEER_ADDRESS=peer0.ia3.dams.com:7151 \
cli \
peer channel list
```

```dd
docker exec -it \
-e CORE_PEER_LOCALMSPID=ic3MSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/ic3.dams.com/peers/peer0.ic3.dams.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/ic3.dams.com/users/Admin@ic3.dams.com/msp \
-e CORE_PEER_ADDRESS=peer0.ic3.dams.com:7251 \
cli \
peer channel list
```

```dd2
# 安装合约
docker exec -it \
-e CORE_PEER_LOCALMSPID=cecMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/Admin@cec.dams.com/msp \
-e CORE_PEER_ADDRESS=peer0.cec.dams.com:7051 \
cli \
peer chaincode install \
-n mychaincode \
-v 1.0 \
-l golang \
-p mychaincode
```

```ddd
# 初始化合约
docker exec -it \
cli \
peer chaincode instantiate -o orderer.dams.com:7050 \
--tls true --cafile /opt/crypto/ordererOrganizations/dams.com/orderers/orderer.dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem \
-C mychannel \
-n mychaincode \
-l golang \
-v 1.0 \
-c '{"Args":["init","a","100","b","200"]}' -P 'OR ('\''cecMSP.peer'\'')'
```

```dd
# 查看
# view installed chain codes of cec peer0
docker exec -it \
-e CORE_PEER_LOCALMSPID=cecMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/Admin@cec.dams.com/msp \
-e CORE_PEER_ADDRESS=peer0.cec.dams.com:7051 \
cli \
peer chaincode list \
-C mychannel \
--installed
```

```dd44
# view instantiated chain codes of cec peer0
docker exec -it \
-e CORE_PEER_LOCALMSPID=cecMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/Admin@cec.dams.com/msp \
-e CORE_PEER_ADDRESS=peer0.cec.dams.com:7051 \
cli \
peer chaincode list \
-C mychannel \
--instantiated
```

```kk
# view installed chain codes of cec peer0
docker exec -it \
-e CORE_PEER_LOCALMSPID=cecMSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt \
-e CORE_PEER_TLS_CERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/server.crt \
-e CORE_PEER_TLS_KEY_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/server.key \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/Admin@cec.dams.com/msp \
-e CORE_PEER_ADDRESS=peer0.cec.dams.com:7051 \
cli \
peer chaincode list \
-C mychannel \
--installed
```

```ss
# view installed chain codes
docker exec -it \
-e CORE_PEER_LOCALMSPID=ia3MSP \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/ia3.dams.com/peers/peer0.ia3.dams.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/ia3.dams.com/users/Admin@ia3.dams.com/msp \
-e CORE_PEER_ADDRESS=peer0.ia3.dams.com:7151 \
cli \
peer chaincode list \
-C mychannel \
--installed
```

```ddkk
docker exec -it \
-e FABRIC_LOGGING_SPEC="INFO" \
-e CORE_PEER_LOCALMSPID=cecMSP  \
-e CORE_PEER_TLS_ROOTCERT_FILE=/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt \
-e CORE_PEER_MSPCONFIGPATH=/opt/crypto/peerOrganizations/cec.dams.com/users/Admin@cec.dams.com/msp \
-e CORE_PEER_ADDRESS=peer0.cec.dams.com:7051 \
cli \
peer chaincode invoke \
-o orderer.dams.com:7050 \
-C mychannel \
-n mychaincode \
-c '{"Args":["add","a","10"]}' \
--tls true \
--cafile /opt/crypto/ordererOrganizations/dams.com/orderers/orderer.dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem
```

```dd
docker exec -it cli \
peer chaincode invoke \
-o orderer.dams.com:7050 \
-C mychannel \
-n mychaincode \
-c '{"Args":["query","a"]}' \
--tls true \
--cafile /opt/crypto/ordererOrganizations/dams.com/orderers/orderer.dams.com/msp/tlscacerts/tlsca.dams.com-cert.pem
```
