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
目前计划三个节点, peer1, peer2, peer3

首先生成创世区块, 配置创世区块的配置文件：
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

名词解释:
https://gist.github.com/0mkara/b953cc2585b18ee098cd
生成创世区块的命令如下：
```shell

```

# 3. 服务启动
# 4. 操作