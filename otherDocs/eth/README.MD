# 1. 软件安装

## 1.1 软件下载与配置
前往 https://geth.ethereum.org/downloads/ 下载对应的软件
此处因为本机是CentOS环境，则选择了对应的二进制版本：
```shell
wget https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.4-aa637fd3.tar.gz
tar -xzvf geth-linux-amd64-1.10.4-aa637fd3.tar.gz
```

然后将相应的二进制文件加入到path中去，以便能够执行，修改 /etc/profile 文件，增加相应的内容：

```shell
PATH=/root/softwares/geth-linux-amd64-1.10.4-aa637fd3:$PATH
export PATH
```

对新增加的环境变量配置信息生效，并执行geth version命令查看是否正确：
```shell
[root@fabric70 softwares]# source /etc/profile
[root@fabric70 softwares]# geth version
Geth
Version: 1.10.4-stable
Git Commit: aa637fd38a379db6da98df0d520fb1c5139a18ce
Git Commit Date: 20210617
Architecture: amd64
Go Version: go1.16.4
Operating System: linux
GOPATH=
GOROOT=go
```

从上面看，geth命令已经可以执行。

# 2. 环境规划与服务启动(二进制方式)

# 2.1 节点规划
目前计划四个节点, bootstrap node, 三个成员节点： node1, node2, node3

# 2.2 启动
## 配置文件：
```json
{
  "config": {
    "chainId": 10,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip150Hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "ethash": {}
  },
  "nonce": "0x0",
  "timestamp": "0x5e4a53b2",
  "extraData": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "gasLimit": "0x47b760",
  "difficulty": "0x400000",
  "mixHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "coinbase": "0x0000000000000000000000000000000000000000",
  "alloc": {
    "0000000000000000000000000000000000000088": {
      "balance": "0x200000000000000000000000000000000000000000000000000000000000000"
    }
  },
  "number": "0x0",
  "gasUsed": "0x0",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000"
}
```

## bootstrap node

给bootstrap node生成数据目录
```shell
geth init --datadir data genesis.json
```

会看到类似下面的输出，表示生成成功
```shell
[root@fabric70 eth]# geth init --datadir data genesis.json
INFO [07-09|15:24:41.101] Maximum peer count                       ETH=50 LES=0 total=50
INFO [07-09|15:24:41.101] Smartcard socket not found, disabling    err="stat /run/pcscd/pcscd.comm: no such file or directory"
INFO [07-09|15:24:41.102] Set global gas cap                       cap=50,000,000
INFO [07-09|15:24:41.102] Allocated cache and file handles         database=/root/eth/data/geth/chaindata cache=16.00MiB handles=16
INFO [07-09|15:24:41.105] Writing custom genesis block
INFO [07-09|15:24:41.107] Persisted trie from memory database      nodes=1 size=171.00B time="58.47µs" gcnodes=0 gcsize=0.00B gctime=0s livenodes=1 livesize=0.00B
INFO [07-09|15:24:41.107] Successfully wrote genesis state         database=chaindata                     hash=ebe338..3c33b2
INFO [07-09|15:24:41.107] Allocated cache and file handles         database=/root/eth/data/geth/lightchaindata cache=16.00MiB handles=16
INFO [07-09|15:24:41.108] Writing custom genesis block
INFO [07-09|15:24:41.109] Persisted trie from memory database      nodes=1 size=171.00B time="29.327µs" gcnodes=0 gcsize=0.00B gctime=0s livenodes=1 livesize=0.00B
INFO [07-09|15:24:41.109] Successfully wrote genesis state         database=lightchaindata                     hash=ebe338..3c33b2
```

启动 bootstrap node
```shell
geth --datadir data --networkid 15444 --nat extip:127.0.0.1 --netrestrict 127.0.0.1/8
```

其中--netrestrict参数限制只允许本机的节点添加，避免公网上的其他节点被添加进来


另外打开一个shell窗口，然后通过命令获取 bootstrap node 的连接信息，用于后续成员节点和bootstrap node建立连接

```shell
geth attach data/geth.ipc --exec admin.nodeInfo.enr
```

会有下面的输出：
```shell
[root@fabric70 eth]# geth attach data/geth.ipc --exec admin.nodeInfo.enr
"enr:-J24QBCYNCj7n5y3t2SmlIacNeBlEkpCPvYSq-cmD3NSKax3AKmrmJuY0NW4xARbS09V39tccAYIH4XJbctCpwPOudIBg2V0aMfGhEQV6vaAgmlkgnY0gmlwhH8AAAGJc2VjcDI1NmsxoQL67TQygqKRp1u1a5g2d-0otm-095iwRxX5PUdDpfc2OYRzbmFwwIN0Y3CCdl-DdWRwgnZf"
```

保存输出结果，后续需要使用

## peer1

生成peer1的数据目录：

```shell
geth init --datadir data-1 genesis.json
```

```shell
geth --datadir data-1 \
--nat extip:127.0.0.1 \
--port 30304 \
--networkid 15444 \
--netrestrict 127.0.0.1/8 \
--bootnodes "enr:-J24QBCYNCj7n5y3t2SmlIacNeBlEkpCPvYSq-cmD3NSKax3AKmrmJuY0NW4xARbS09V39tccAYIH4XJbctCpwPOudIBg2V0aMfGhEQV6vaAgmlkgnY0gmlwhH8AAAGJc2VjcDI1NmsxoQL67TQygqKRp1u1a5g2d-0otm-095iwRxX5PUdDpfc2OYRzbmFwwIN0Y3CCdl-DdWRwgnZf"
```

其中port值需要和bootstrap的port不能一样，避免冲突


## peer2

生成peer2的数据目录：

```shell
geth init --datadir data-2 genesis.json
```

```shell
geth --datadir data-2 \
--nat extip:127.0.0.1 \
--port 30305 \
--networkid 15444 \
--netrestrict 127.0.0.1/8 \
--bootnodes "enr:-J24QBCYNCj7n5y3t2SmlIacNeBlEkpCPvYSq-cmD3NSKax3AKmrmJuY0NW4xARbS09V39tccAYIH4XJbctCpwPOudIBg2V0aMfGhEQV6vaAgmlkgnY0gmlwhH8AAAGJc2VjcDI1NmsxoQL67TQygqKRp1u1a5g2d-0otm-095iwRxX5PUdDpfc2OYRzbmFwwIN0Y3CCdl-DdWRwgnZf"
```

## peer3

生成peer3的数据目录：

```shell
geth init --datadir data-3 genesis.json
```

```shell
geth --datadir data-3 \
--nat extip:127.0.0.1 \
--port 30306 \
--networkid 15444 \
--netrestrict 127.0.0.1/8 \
--http \
--http.addr 127.0.0.1 \
--http.port 8545 \
--bootnodes "enr:-J24QBCYNCj7n5y3t2SmlIacNeBlEkpCPvYSq-cmD3NSKax3AKmrmJuY0NW4xARbS09V39tccAYIH4XJbctCpwPOudIBg2V0aMfGhEQV6vaAgmlkgnY0gmlwhH8AAAGJc2VjcDI1NmsxoQL67TQygqKRp1u1a5g2d-0otm-095iwRxX5PUdDpfc2OYRzbmFwwIN0Y3CCdl-DdWRwgnZf"
```


## 验证
```shell
geth attach data/geth.ipc --exec admin.peers
```

会得到下面的输出结果
```shell
[root@fabric70 eth]# geth attach data/geth.ipc --exec admin.peers
[{
    caps: ["eth/65", "eth/66", "snap/1"],
    enode: "enode://d102ed4f1cec74f003f48ad7bd378fe5e672a265aa13c52d4b13b53a098104a622dedd8281a733fa2582f7a0e3da9c0279dd81d1bbb53d7756eb15c6598e13ca@127.0.0.1:58450",
    id: "0cb31f976a96363a148defa961b70c1a2624f91fb3595c24ffcda45c264d31b6",
    name: "Geth/v1.10.4-stable-aa637fd3/linux-amd64/go1.16.4",
    network: {
      inbound: true,
      localAddress: "127.0.0.1:30303",
      remoteAddress: "127.0.0.1:58450",
      static: false,
      trusted: false
    },
    protocols: {
      eth: {
        difficulty: 4194304,
        head: "0xebe33838a934184e6d3738da1685cc191e399a64b934ee5f349a36f6c13c33b2",
        version: 66
      },
      snap: {
        version: 1
      }
    }
}, {
    caps: ["eth/65", "eth/66", "snap/1"],
    enode: "enode://2af844cebc79149a9dad81a472da6b3826207f8ae43ec45fe64417cb93865c9317ab6c7bb342672951dee6d0b89d3978a14accff9564519927a74bcab34a2814@127.0.0.1:58442",
    id: "3e87be3acaf1510dec7f0400ba962ab4cc3ad41af96a5a2971a99a14026ecf7c",
    name: "Geth/v1.10.4-stable-aa637fd3/linux-amd64/go1.16.4",
    network: {
      inbound: true,
      localAddress: "127.0.0.1:30303",
      remoteAddress: "127.0.0.1:58442",
      static: false,
      trusted: false
    },
    protocols: {
      eth: {
        difficulty: 4194304,
        head: "0xebe33838a934184e6d3738da1685cc191e399a64b934ee5f349a36f6c13c33b2",
        version: 66
      },
      snap: {
        version: 1
      }
    }
}, {
    caps: ["eth/65", "eth/66", "snap/1"],
    enode: "enode://47af6f44228cb7b209e457b44c18d14ffcd87cd06f074abe026dc704dbb48ba4c0e6e3b66c63526d7653b6a690ae1a6a9a2dbedf2ca92edf451fa4f86c55fc28@127.0.0.1:58448",
    id: "5b7c5cdcf5e2a48f9b84e4afbda09f54263ae0de567a17352a6f1a55b8c7a97a",
    name: "Geth/v1.10.4-stable-aa637fd3/linux-amd64/go1.16.4",
    network: {
      inbound: true,
      localAddress: "127.0.0.1:30303",
      remoteAddress: "127.0.0.1:58448",
      static: false,
      trusted: false
    },
    protocols: {
      eth: {
        difficulty: 4194304,
        head: "0xebe33838a934184e6d3738da1685cc191e399a64b934ee5f349a36f6c13c33b2",
        version: 66
      },
      snap: {
        version: 1
      }
    }
}]

```

通过上面的输出信息，可以看到加入三个成员节点信息

## 创建账户
新开一个shell窗口，通过下面的命令，可以登录到peer1的控制台，通过更改数据目录路径，也可以登录到其他peer

```shell
geth attach data-1/geth.ipc
```

登录成功会进入到控制台，如下所示：

```shell
[root@fabric70 eth]# geth attach data-1/geth.ipc
Welcome to the Geth JavaScript console!

instance: Geth/v1.10.4-stable-aa637fd3/linux-amd64/go1.16.4
at block: 0 (Mon Feb 17 2020 16:49:54 GMT+0800 (CST))
 datadir: /root/eth/data-1
 modules: admin:1.0 debug:1.0 eth:1.0 ethash:1.0 miner:1.0 net:1.0 personal:1.0 rpc:1.0 txpool:1.0 web3:1.0

To exit, press ctrl-d
>
```

输入命令 personal.newAccount() 并执行，会要求输入密码，然后的到一串代表账户地址的字符串，代表用户创建成功：

```shell
> personal.newAccount()
Passphrase:
Repeat passphrase:
"0x6402fd89e87127908b54b7a18e6ac4d251dc0fcd"
```

通过下面的命令获取账户余额？ eth.getBalance("ENTER_ACCOUNT_ADDRESS_HERE") 

```shell
> eth.getBalance("0x6402fd89e87127908b54b7a18e6ac4d251dc0fcd")
0
```

列处当前节点所有的账户信息

```shell
> personal.listAccounts
["0xd716725925b0f8b3c68ccd2fbef924d6d9f47ebb"]
```

列出区块总数：

```shell
eth.blockNumber
```

## 挖矿相关测试
执行命令 miner.start() , 则当前账户？会开始挖矿

```shell
> miner.start()
null
```

在执行挖矿之后，在任何一个节点的控制台终端执行eth.blockNumber可以看到系统中目前的区块总数在增加，也可以从输出中可以看到成功挖矿的信息

```shell
> eth.blockNumber
22
```

同时，在任何一个节点的控制台终端执行查询账户钱包的命令，也能够查询到相应的记录

```shell
> eth.getBalance("0xd716725925b0f8b3c68ccd2fbef924d6d9f47ebb")
12000000000000000000
```

至此，私有以太坊网络的搭建测试工作结束



# 3. 环境规划与服务启动(容器方式)
此处假设容器环境已经安装配置好

# 3.1 节点规划
目前计划四个节点, bootstrap node, 三个成员节点： node1, node2, node3

# 3.2 启动
## 配置文件：
```json
{
  "config": {
    "chainId": 10,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip150Hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "ethash": {}
  },
  "nonce": "0x0",
  "timestamp": "0x5e4a53b2",
  "extraData": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "gasLimit": "0x47b760",
  "difficulty": "0x400000",
  "mixHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "coinbase": "0x0000000000000000000000000000000000000000",
  "alloc": {
    "0000000000000000000000000000000000000088": {
      "balance": "0x200000000000000000000000000000000000000000000000000000000000000"
    }
  },
  "number": "0x0",
  "gasUsed": "0x0",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000"
}
```

## bootstrap node

给bootstrap node生成数据目录
```shell
docker run --rm -it --name ethereum-temp \
           -v /root/eth:/root/eth \
           -v /root/eth/genesis.json:/root/eth/genesis.json \
           ethereum/client-go:stable \
           init --datadir /root/eth/data /root/eth/genesis.json
```

会看到类似下面的输出，表示生成成功
```shell
[root@fabric70 eth]# geth init --datadir data genesis.json
INFO [07-14|06:23:36.293] Maximum peer count                       ETH=50 LES=0 total=50
INFO [07-14|06:23:36.293] Smartcard socket not found, disabling    err="stat /run/pcscd/pcscd.comm: no such file or directory"
INFO [07-14|06:23:36.294] Set global gas cap                       cap=50,000,000
INFO [07-14|06:23:36.294] Allocated cache and file handles         database=/root/eth/data/geth/chaindata cache=16.00MiB handles=16
INFO [07-14|06:23:36.297] Writing custom genesis block
INFO [07-14|06:23:36.298] Persisted trie from memory database      nodes=1 size=171.00B time="54.315µs" gcnodes=0 gcsize=0.00B gctime=0s livenodes=1 livesize=0.00B
INFO [07-14|06:23:36.298] Successfully wrote genesis state         database=chaindata                     hash=ebe338..3c33b2
INFO [07-14|06:23:36.298] Allocated cache and file handles         database=/root/eth/data/geth/lightchaindata cache=16.00MiB handles=16
INFO [07-14|06:23:36.300] Writing custom genesis block
INFO [07-14|06:23:36.300] Persisted trie from memory database      nodes=1 size=171.00B time="39.983µs" gcnodes=0 gcsize=0.00B gctime=0s livenodes=1 livesize=0.00B
INFO [07-14|06:23:36.300] Successfully wrote genesis state         database=lightchaindata                     hash=ebe338..3c33b2
```

启动 bootstrap node
```shell
docker run -it -d --name bootstrap-node \
           -v /root/eth/data:/root/eth/data \
           -p 30303:30303 \
           ethereum/client-go:stable \
           --datadir /root/eth/data \
           --networkid 15444 \
           -verbosity 6 \
           --nat extip:192.168.16.70 \
           --nodiscover
```

其中--netrestrict参数限制只允许本机的节点添加，避免公网上的其他节点被添加进来

docker网络因为其自身的网络特性，使用--bootnodes的节点注册方式暂时会有一些问题，主要问题记录如下：

1. 如果去掉--nodiscover选项，bootstrap node回去自动添加peer，造成大量的外部peer被注册进来；如果关闭该选项，则造成udp端口被关闭，member peer无法注册。
2. 如果通过--netrestrict来避免大量外部的peer被注册进来是可以的，但是因为--netrestrict参数只能对一个IP段进行限制，而docker的IP地址比较麻烦，同时会会有192.168.X.X和172.17.X.X的存在。这里暂时没有解决的思路。

综上所述，bootnodes对其他节点的注册暂时使用addpeer的API进行添加。后续继续研究。









执行下面的命令获取 bootstrap node 的连接信息，用于后续成员节点和bootstrap node建立连接
```shell
docker run --rm -it --name ethereum-info-get \
           -v /root/eth/data:/root/eth/data \
           ethereum/client-go:stable \
           attach /root/eth/data/geth.ipc --exec admin.nodeInfo.enr
```

会有下面的输出：
```shell
[root@fabric70 eth]# docker run --rm -it --name ethereum-info-get \
>            -v /root/eth/data:/root/eth/data \
>            ethereum/client-go:stable \
>            attach /root/eth/data/geth.ipc --exec admin.nodeInfo.enr
"enr:-J24QMnyMFl2PNEGQcVE7nC16gKW7lLk6GVGXZofmI9ABq3uBkx9TQLtGo3gZ5pafXDnP-wVNIJ4uaz3NSaM0SeaiIsBg2V0aMfGhEQV6vaAgmlkgnY0gmlwhMCoEEaJc2VjcDI1NmsxoQOgCd15sTTJZ994G8zvboX4oM3mKmHnkgSNJ0Aaz02EE4RzbmFwwIN0Y3CCdl-DdWRwgnZf"
```

保存输出结果，后续需要使用










通过下面的命令可以进入节点控制台，进入的时候需要注意data目录名称
```shell
docker run --rm -it --name ethereum-info-get \
           -v /root/eth/data:/root/eth/data \
           ethereum/client-go:stable \
           attach /root/eth/data/geth.ipc 
```



## peer1

生成peer1的数据目录：

```shell
docker run --rm -it --name ethereum-temp \
           -v /root/eth:/root/eth \
           -v /root/eth/genesis.json:/root/eth/genesis.json \
           ethereum/client-go:stable \
           init --datadir /root/eth/data-1 /root/eth/genesis.json
```

```shell
docker run -it -d --name peer1 \
           -v /root/eth/data-1:/root/eth/data-1 \
           -p 30304:30304 \
           ethereum/client-go:stable \
           --datadir /root/eth/data-1 \
           --port 30304 \
           --networkid 15444 \
           -verbosity 6 \
           --nat extip:192.168.16.70 \
           --nodiscover 

```

通过下面的命令获取peer1的相关信息
```shell
docker run --rm -it --name ethereum-info-get \
           -v /root/eth/data-1:/root/eth/data-1 \
           ethereum/client-go:stable \
           attach /root/eth/data-1/geth.ipc --exec admin.nodeInfo.enode 
```

执行结果片段如下：

```json
"enode://aede77de8db5dc1d90a9e30fde64b85c00bfca8852f6245a94350861b4de5a0a8d475e4999e5a11806f99d81e45e1c7737ebd74fb91d8263d5f2aae9f46a019e@192.168.16.70:30304?discport=0"
```

然后执行下面的命令，其中addPeer命令括号中的内容来自上面命令执行的结果。

```shell
docker run --rm -it --name ethereum-add-peer \
           -v /root/eth/data:/root/eth/data \
           ethereum/client-go:stable \
           attach /root/eth/data/geth.ipc
           
```

然后执行下面的命令，其中addPeer命令括号中的内容来自之前针对peer1节点执行admin.nodeInfo.enode命令执行的结果

```shell
admin.addPeer("enode://aede77de8db5dc1d90a9e30fde64b85c00bfca8852f6245a94350861b4de5a0a8d475e4999e5a11806f99d81e45e1c7737ebd74fb91d8263d5f2aae9f46a019e@192.168.16.70:30304?discport=0")
```

然后执行命令admin.peers则可以看到peer1已经加入到网络中了，所执行的命令和结果片段如下:
```shell
> admin.peers
[{
    caps: ["eth/65", "eth/66", "snap/1"],
    enode: "enode://aede77de8db5dc1d90a9e30fde64b85c00bfca8852f6245a94350861b4de5a0a8d475e4999e5a11806f99d81e45e1c7737ebd74fb91d8263d5f2aae9f46a019e@192.168.16.70:30304?discport=0",
    ...
}]
```

## peer2

生成peer2的数据目录：

```shell
docker run --rm -it --name ethereum-temp \
           -v /root/eth:/root/eth \
           -v /root/eth/genesis.json:/root/eth/genesis.json \
           ethereum/client-go:stable \
           init --datadir /root/eth/data-2 /root/eth/genesis.json
```

```shell
docker run -it -d --name peer2 \
           -v /root/eth/data-2:/root/eth/data-2 \
           -p 30305:30305 \
           ethereum/client-go:stable \
           --datadir /root/eth/data-2 \
           --port 30305 \
           --networkid 15444 \
           -verbosity 6 \
           --nat extip:192.168.16.70 \
           --bootnodes "enr:-Ja4QC6wBlF48ZtOXXjQ0N5JPo-0hkMgsqlH_9UDrDERtCSdLUSzL6vq9cAMaa6tI-Bo9cxDQHsvq9TJVs646xdrFCMBg2V0aMfGhEQV6vaAgmlkgnY0gmlwhMCoEEaJc2VjcDI1NmsxoQMtxGsuQFqkDRFLW_f0hfMU5Pu_aucDRYLDJyfL7muPSIRzbmFwwIN0Y3CCdl8"
```

## peer3

生成peer3的数据目录：

```shell
docker run --rm -it --name ethereum-temp \
           -v /root/eth:/root/eth \
           -v /root/eth/genesis.json:/root/eth/genesis.json \
           ethereum/client-go:stable \
           init --datadir /root/eth/data-3 /root/eth/genesis.json
```

```shell
docker run -it -d --name peer3 \
           -v /root/eth/data-3:/root/eth/data-3 \
           -p 30306:30303 \
           ethereum/client-go:stable \
           --datadir /root/eth/data-3 \
           --networkid 15444 \
           --nat extip:192.168.16.70 \
           --netrestrict 192.168.16.1/8 \
           --bootnodes "enr:-J24QO3c3k60bZAA-t4ZYqYRo3QvN0pvg_ml8QRXFCiWOVxDVALmP87FyVX1xHP2zDU7LWTDdxJNKTShDZgu3n68Y2sBg2V0aMfGhEQV6vaAgmlkgnY0gmlwhH8AAAGJc2VjcDI1NmsxoQLbiZVc2OFRfPUfijyaD9iLk8-0FzEnJC_oOySazReWMYRzbmFwwIN0Y3CCdl-DdWRwgnZf"
```






## 验证
```shell
docker run --rm -it --name ethereum-temp \
           -v /root/eth/data:/root/eth/data \
           ethereum/client-go:stable \
           attach /root/eth/data/geth.ipc --exec admin.peers
```

会得到下面的输出结果
```shell
[root@fabric70 eth]# geth attach data/geth.ipc --exec admin.peers
[{
    caps: ["eth/65", "eth/66", "snap/1"],
    enode: "enode://d102ed4f1cec74f003f48ad7bd378fe5e672a265aa13c52d4b13b53a098104a622dedd8281a733fa2582f7a0e3da9c0279dd81d1bbb53d7756eb15c6598e13ca@127.0.0.1:58450",
    id: "0cb31f976a96363a148defa961b70c1a2624f91fb3595c24ffcda45c264d31b6",
    name: "Geth/v1.10.4-stable-aa637fd3/linux-amd64/go1.16.4",
    network: {
      inbound: true,
      localAddress: "127.0.0.1:30303",
      remoteAddress: "127.0.0.1:58450",
      static: false,
      trusted: false
    },
    protocols: {
      eth: {
        difficulty: 4194304,
        head: "0xebe33838a934184e6d3738da1685cc191e399a64b934ee5f349a36f6c13c33b2",
        version: 66
      },
      snap: {
        version: 1
      }
    }
}, {
    caps: ["eth/65", "eth/66", "snap/1"],
    enode: "enode://2af844cebc79149a9dad81a472da6b3826207f8ae43ec45fe64417cb93865c9317ab6c7bb342672951dee6d0b89d3978a14accff9564519927a74bcab34a2814@127.0.0.1:58442",
    id: "3e87be3acaf1510dec7f0400ba962ab4cc3ad41af96a5a2971a99a14026ecf7c",
    name: "Geth/v1.10.4-stable-aa637fd3/linux-amd64/go1.16.4",
    network: {
      inbound: true,
      localAddress: "127.0.0.1:30303",
      remoteAddress: "127.0.0.1:58442",
      static: false,
      trusted: false
    },
    protocols: {
      eth: {
        difficulty: 4194304,
        head: "0xebe33838a934184e6d3738da1685cc191e399a64b934ee5f349a36f6c13c33b2",
        version: 66
      },
      snap: {
        version: 1
      }
    }
}, {
    caps: ["eth/65", "eth/66", "snap/1"],
    enode: "enode://47af6f44228cb7b209e457b44c18d14ffcd87cd06f074abe026dc704dbb48ba4c0e6e3b66c63526d7653b6a690ae1a6a9a2dbedf2ca92edf451fa4f86c55fc28@127.0.0.1:58448",
    id: "5b7c5cdcf5e2a48f9b84e4afbda09f54263ae0de567a17352a6f1a55b8c7a97a",
    name: "Geth/v1.10.4-stable-aa637fd3/linux-amd64/go1.16.4",
    network: {
      inbound: true,
      localAddress: "127.0.0.1:30303",
      remoteAddress: "127.0.0.1:58448",
      static: false,
      trusted: false
    },
    protocols: {
      eth: {
        difficulty: 4194304,
        head: "0xebe33838a934184e6d3738da1685cc191e399a64b934ee5f349a36f6c13c33b2",
        version: 66
      },
      snap: {
        version: 1
      }
    }
}]

```

通过上面的输出信息，可以看到加入三个成员节点信息

## 创建账户
新开一个shell窗口，通过下面的命令，可以登录到peer1的控制台，通过更改数据目录路径，也可以登录到其他peer

```shell
geth attach data-1/geth.ipc
```

登录成功会进入到控制台，如下所示：

```shell
[root@fabric70 eth]# geth attach data-1/geth.ipc
Welcome to the Geth JavaScript console!

instance: Geth/v1.10.4-stable-aa637fd3/linux-amd64/go1.16.4
at block: 0 (Mon Feb 17 2020 16:49:54 GMT+0800 (CST))
 datadir: /root/eth/data-1
 modules: admin:1.0 debug:1.0 eth:1.0 ethash:1.0 miner:1.0 net:1.0 personal:1.0 rpc:1.0 txpool:1.0 web3:1.0

To exit, press ctrl-d
>
```

输入命令 personal.newAccount() 并执行，会要求输入密码，然后的到一串代表账户地址的字符串，代表用户创建成功：

```shell
> personal.newAccount()
Passphrase:
Repeat passphrase:
"0x6402fd89e87127908b54b7a18e6ac4d251dc0fcd"
```

通过下面的命令获取账户余额？ eth.getBalance("ENTER_ACCOUNT_ADDRESS_HERE")

```shell
> eth.getBalance("0x6402fd89e87127908b54b7a18e6ac4d251dc0fcd")
0
```

列处当前节点所有的账户信息

```shell
> personal.listAccounts
["0xd716725925b0f8b3c68ccd2fbef924d6d9f47ebb"]
```

列出区块总数：

```shell
eth.blockNumber
```

## 挖矿相关测试
执行命令 miner.start() , 则当前账户？会开始挖矿

```shell
> miner.start()
null
```

在执行挖矿之后，在任何一个节点的控制台终端执行eth.blockNumber可以看到系统中目前的区块总数在增加，也可以从输出中可以看到成功挖矿的信息

```shell
> eth.blockNumber
22
```

同时，在任何一个节点的控制台终端执行查询账户钱包的命令，也能够查询到相应的记录

```shell
> eth.getBalance("0xd716725925b0f8b3c68ccd2fbef924d6d9f47ebb")
12000000000000000000
```

至此，私有以太坊网络的搭建测试工作结束






admin.addPeer("enode://fe23fd1b7c95f074947271852e1abf095b118d434ac25bf36d59a326a07d248a1aa86fb19a50d52f960d0ece0615d6fc33f831f8965061d644782e15c4daad06@192.168.16.70:30304?discport=0")


enode://6c7252bc72a10fd824b280a3d81d988c95d9db046eadb92f085b65133b5ea0cef793e6e0c35fca6c66800f1406cf015281da64f2235dae5f9f1f2c7692b08803@192.168.16.70:30304


admin.nodeInfo.enode

"enode://b4233eda453e379a46b8e7e4cd2f6679efadb4f367f2aa388d7a40157810c1e64c2c00647c19ef3ba85e7fdf83796dd8c0ed64dfae20a91a1e3d3cd1746a0bc9@192.168.16.70:30304?discport=0"










参考文档：

https://geth.ethereum.org/docs/interface/private-network

https://gist.github.com/0mkara/b953cc2585b18ee098cd

https://pragmaticdlt.com/insights/setupclique.html

https://medium.com/@gracile/setting-up-an-ethereum-virtual-private-network-462355f1976e

https://philidor.dev/blog/setup-private-ethereum-network-with-docker/

https://www.coding-bootcamps.com/blog/review-of-ethereum-networking-options.html

https://www.cnblogs.com/wanghui-garcia/p/10256520.html

http://www.netkiller.cn/blockchain/ethereum/geth/index.html

https://medium.com/@pradeep_thomas/how-to-setup-your-own-private-ethereum-network-f80bc6aea088

工具：

https://enr-viewer.com/
