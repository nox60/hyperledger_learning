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




## 给peer1生成数据目录
```shell
geth  \
--datadir /root/eth/data1 \
init /root/eth/genesis.json
```

会看到类似下面的输出，表示生成成功
```shell
INFO [07-07|11:19:37.581] Maximum peer count                       ETH=50 LES=0 total=50
INFO [07-07|11:19:37.581] Smartcard socket not found, disabling    err="stat /run/pcscd/pcscd.comm: no such file or directory"
INFO [07-07|11:19:37.582] Set global gas cap                       cap=50,000,000
INFO [07-07|11:19:37.582] Allocated cache and file handles         database=/root/eth/data1/geth/chaindata cache=16.00MiB handles=16
INFO [07-07|11:19:37.584] Writing custom genesis block
INFO [07-07|11:19:37.585] Persisted trie from memory database      nodes=1 size=171.00B time="71.126µs" gcnodes=0 gcsize=0.00B gctime=0s livenodes=1 livesize=0.00B
INFO [07-07|11:19:37.585] Successfully wrote genesis state         database=chaindata                      hash=ebe338..3c33b2
INFO [07-07|11:19:37.585] Allocated cache and file handles         database=/root/eth/data1/geth/lightchaindata cache=16.00MiB handles=16
INFO [07-07|11:19:37.587] Writing custom genesis block
INFO [07-07|11:19:37.587] Persisted trie from memory database      nodes=1 size=171.00B time="25.419µs" gcnodes=0 gcsize=0.00B gctime=0s livenodes=1 livesize=0.00B
INFO [07-07|11:19:37.587] Successfully wrote genesis state         database=lightchaindata                      hash=ebe338..3c33b2
```

## 给peer2生成数据目录
```shell
geth  \
--datadir /root/eth/data2 \
init /root/eth/genesis.json
```

## 给peer3生成数据目录
```shell
geth  \
--datadir /root/eth/data3 \
init /root/eth/genesis.json
```

## 启动peer1
```shell
geth \
--datadir /root/eth/data1 \
--networkid 123 --port 30303 --nodiscover
```

### 连接peer1
```shell
geth attach /root/eth/data1/geth.ipc
```

## 启动peer2
```shell
geth \
--datadir /root/eth/data2 \
--networkid 123 --port 30304 --nodiscover
```

### 连接peer2
```shell
geth attach /root/eth/data2/geth.ipc
```

## 启动peer3
```shell
geth \
--datadir /root/eth/data3 \
--networkid 123 --port 30305 --nodiscover
```

### 连接peer3
```shell
geth attach /root/eth/data3/geth.ipc
```

创建一个账户，在peer1的控制台里创建，创建的时候输入命令 personal.newAccount() 并执行，会要求输入密码，然后的到一串代表账户地址的字符串：

```shell
> personal.newAccount()
Passphrase:
Repeat passphrase:
"0xd716725925b0f8b3c68ccd2fbef924d6d9f47ebb"
```

通过下面的命令获取账户余额？ eth.getBalance("ENTER_ACCOUNT_ADDRESS_HERE") 

```shell
eth.getBalance("0xd716725925b0f8b3c68ccd2fbef924d6d9f47ebb") 
```

列处当前节点所有的账户信息

```shell
> personal.listAccounts
["0xd716725925b0f8b3c68ccd2fbef924d6d9f47ebb"]
```

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

```shell
geth init --datadir data genesis.json
```

启动 bootstrap node 节点
```shell
geth --datadir data --networkid 15 --port 30303 --http.addr 127.0.0.1 
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
--http.addr 127.0.0.1 \
--port portValue \
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

# 4. 操作