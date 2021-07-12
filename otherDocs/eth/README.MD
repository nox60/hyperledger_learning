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

# 2. 环境规划与服务启动

# 2.1 节点规划
目前计划四个节点, bootstrap node, 三个成员节点： node1, node2, node3

## 首先创建配置文件：
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

## 现在可以开始挖矿
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


























### 将节点加入私有网络

在任何一个节点上运行 admin.nodeInfo.enode 可以得到节点的信息

```shell
> admin.nodeInfo.enode
"enode://46e832964476876c6c26f34855c500bd98a1e14bb9d9c038cf9b4219893db4c7f561a7103910b5deaab396782d54205e5ea10f82a9a64e8e136f2edb62b04809@127.0.0.1:30305?discport=0"
```

上述信息在其他节点上执行 ：

```shell
admin.addPeer("enode://46e832964476876c6c26f34855c500bd98a1e14bb9d9c038cf9b4219893db4c7f561a7103910b5deaab396782d54205e5ea10f82a9a64e8e136f2edb62b04809@127.0.0.1:30305?discport=0")

```

https://blog.csdn.net/gao131360144/article/details/79611357

https://geth.ethereum.org/docs/interface/private-network


名词解释:
https://gist.github.com/0mkara/b953cc2585b18ee098cd

# 3. 服务启动
目前计划四个节点, bootstrap node, 三个成员节点： node1, node2, node3

创世区块配置文件
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

## 3.1 启动 bootstrap node 节点

初始化bootstrap node节点（生成创世区块信息）
```shell
geth init --datadir data genesis.json
```

启动 bootstrap node 节点
```shell
geth --datadir data --networkid 15897 --port 30303  --nodiscover
```

执行命令，获得bootstrap节点的连接信息编码，后续会用于其他节点启动的时候加入该私有eth网络
```shell
geth attach data/geth.ipc --exec admin.nodeInfo.enr
```

会得到类似下面的结果：

```shell
[root@localhost eth]# geth attach data/geth.ipc --exec admin.nodeInfo.enr
"enr:-KW4QMUQDs_KlUmzbQbUl52IAD7iqgb1a0MyHzIai3S69B3OFwVMcnzV2HMISIMyFzZEnfuRuiETTmFNrEjh9Vktv6gCg2V0aMfGhEQV6vaAgmlkgnY0gmlwhN7T1-KJc2VjcDI1NmsxoQJ1B7CyJvXsWOvL-ioK7hBg9PB_AxUlaccdI47iVyz7z4RzbmFwwIN0Y3CCdl-DdWRwgn-BhHVkcDaCdl8"
```

## 3.2 启动成员节点

### 3.2.1 启动 peer1 节点

首先，启动成员节点的命令如下：

```shell
geth --datadir data-x \
--port portValue \
--nodiscover \
--networkid networkIdValue
--bootnodes bootstrap-node-record
```

然后可以通过下面的命令判断成员节点是否加入了区块链网络

```shell
geth attach data/geth.ipc --exec admin.peers
```

其中,

data-x 为成员节点的专属目录，每一个成员节点需要有一个自己专属的目录，如果多个成员节点用相同的目录会发生数据错误。
networkIdValue 必须和bootstrap node 节点启动时候的 networkid值一致。
portValue 值是为该节点分配的通信端口
bootstrap-node-record bootstrap 节点的连接信息编码，在3.1节中有获取

命令例子为：
```shell
geth --datadir data-1 \
--port 30304 \
--networkid 15 \
--bootnodes "enr:-KW4QMUQDs_KlUmzbQbUl52IAD7iqgb1a0MyHzIai3S69B3OFwVMcnzV2HMISIMyFzZEnfuRuiETTmFNrEjh9Vktv6gCg2V0aMfGhEQV6vaAgmlkgnY0gmlwhN7T1-KJc2VjcDI1NmsxoQJ1B7CyJvXsWOvL-ioK7hBg9PB_AxUlaccdI47iVyz7z4RzbmFwwIN0Y3CCdl-DdWRwgn-BhHVkcDaCdl8"
```

通过下面的命令例子可以查询到加入区块链网络中的节点信息：

```shell
[root@localhost eth]# geth attach data/geth.ipc --exec admin.peers
[{
    caps: ["eth/64", "eth/65", "eth/66", "snap/1"],
    enode: "enode://46f61838e0c0a0b5866c5e1cf7db830ebe464e92d6e543a0af19094655a151a64fda7ec33a158a20b5de5abc9d69db181eeb1ab1949d7dc6e28c9b953080a201@194.233.73.201:30303",
    id: "a49726efddbb25e3d1e7c17a35583d24afdd92dd5a510c3ff12af6bb36bc7e51",
    name: "Geth/v1.0.3-stable-8ba9f5de/linux-amd64/go1.16.5",
    network: {
      inbound: false,
      localAddress: "192.168.88.131:60712",
      remoteAddress: "194.233.73.201:30303",
      static: false,
      trusted: false
    },
    protocols: {
      eth: "handshake",
      snap: "handshake"
    }
}]
```

### 3.2.2 启动 peer2 节点

启动节点：

```shell
geth --datadir data-2 \
--port 30305 \
--networkid 15 \
--bootnodes "enr:-KW4QMUQDs_KlUmzbQbUl52IAD7iqgb1a0MyHzIai3S69B3OFwVMcnzV2HMISIMyFzZEnfuRuiETTmFNrEjh9Vktv6gCg2V0aMfGhEQV6vaAgmlkgnY0gmlwhN7T1-KJc2VjcDI1NmsxoQJ1B7CyJvXsWOvL-ioK7hBg9PB_AxUlaccdI47iVyz7z4RzbmFwwIN0Y3CCdl-DdWRwgn-BhHVkcDaCdl8"
```


https://github.com/ethereum/go-ethereum/issues/18350

https://blog.csdn.net/zhangnero/article/details/96133289

https://pragmaticdlt.com/insights/setupclique.html

https://medium.com/@gracile/setting-up-an-ethereum-virtual-private-network-462355f1976e

# 4. 操作