# 1. 调用说明

## 1.1 调用要求
如果要进行jsonrpc调用，需要geth服务启动的时候启用服务端口，需要下面的参数支持：

|参数       | 说明      |
|---------  | --------- | 
|--http |启用jsonrpc|
|--http.addr 127.0.0.1 |绑定的IP地址|
|--http.port 8545 |绑定的端口|

## 1.2 软件要求


# 2. 参数列表与说明


| 命令       | 说明      |
|--------- | ---------  | --------- | 
| <a href="#web3_clientVersion"> web3_clientVersion </a>  | 返回当前客户端版本|
| <a href="#web3_sha3"> web3_sha3 </a>  | 对给定字符串进行基于sha3算法的散列计算|
| <a href="#net_version"> net_version </a>  | 返回当前网络类型|
| <a href="#net_peerCount"> net_peerCount </a>  | 返回当前网络中的节点数量|
| <a href="#net_listening"> net_listening </a>  | 返回当前客户端是否连接到网络|
| <a href="#eth_syncing"> eth_syncing </a>  | 返回当前的区块同步状态（需要进一步举例）|
| <a href="#eth_coinbase"> eth_coinbase </a>  | 返回当前客户端的coinbase地址|
| <a href="#eth_mining"> eth_mining </a>  | 返回当前客户端是否正在挖矿|
| <a href="#eth_hashrate"> eth_hashrate </a>  | 返回当前节点每秒钟的hash次数（算力）|
| <a href="#eth_gasPrice"> eth_gasPrice </a>  | 返回当前单位gas的价格，以16进制的方式返回，单位是wei |
| <a href="#eth_accounts"> eth_accounts </a>  | 当前用户的地址 |
| <a href="#eth_blockNumber"> eth_blockNumber </a>  | 返回当前网络中区块高度，以16进制方式返回 |
| <a href="..."> ... </a>  | 编写中 |
| <a href="..."> ... </a>  | 编写中 |

| <a href="#eth_sendTransaction"> eth_sendTransaction </a>  | 转账 |






# 3. 调用例子

### <a name="web3_clientVersion">web3_clientVersion</a>
***

**参数说明：**

无

**请求示例：**

```shell
curl -i -H "Content-Type: application/json"  \
-X POST http://localhost:8545 \
--data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":67}'
```

**结果示例：**

```json
{"jsonrpc":"2.0","id":67,"result":"Geth/v1.10.4-stable-aa637fd3/linux-amd64/go1.16.4"}
```

**结果说明：**

返回结果是当前客户端版本信息。


### <a name="web3_sha3">web3_sha3</a>
***

**参数说明：**

输入参数需要将原参数进行hex编码，然后在编码结果之前加上0x。

**请求示例：**

```shell
curl -i -H "Content-Type: application/json"  \
-X POST http://localhost:8545 \
--data '{"jsonrpc":"2.0","method":"web3_sha3","params":["0x617364667361667361646673616466736661736466736166736164667361646673616466736164666173646673616466736164667361646661736664617364666173646673616466736166736164666173646673616664"],"id":64}'

```

**结果示例：**

```json
{"jsonrpc":"2.0","id":64,"result":"0x799a7a51721fc630d72f08033d5846a8cfeb3b66a7daf1a1e2a7b4fbbae1f480"}
```

**结果说明：**

输出结果是经过sha3散列计算之后的结果，但是也是hex编码的，结果前面加上了0x。


### <a name="net_version">net_version</a>
***

**参数说明：**

无

**请求示例：**

```shell
curl -i -H "Content-Type: application/json"  \
-X POST http://localhost:8545 \
--data '{"jsonrpc":"2.0","method":"net_version","params":[],"id":67}'
```

**结果示例：**

```json
{"jsonrpc":"2.0","id":67,"result":"15444"}
```

**结果说明：**

返回当前网络的类型，说明如下:
- "1": 以太坊主网
- "2": Morden测试网络 (废弃)
- "3": Ropsten测试网络
- "4": Rinkeby测试网络
- "42": Kovan测试网络
- "其他值": 自定义的私有测试网络


### <a name="net_peerCount">net_peerCount</a>
***

**参数说明：**

无

**请求示例：**

```shell
curl -i -H "Content-Type: application/json"  \
-X POST http://localhost:8545 \
--data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":74}'
```

**结果示例：**

```json
{"jsonrpc":"2.0","id":74,"result":"0x3"}
```

**结果说明：**

当前网络中的节点数量


### <a name="net_listening">net_listening</a>
***


**参数说明：**

无

**请求示例：**

```shell
curl -i -H "Content-Type: application/json"  \
-X POST http://localhost:8545 \
--data '{"jsonrpc":"2.0","method":"net_listening","params":[],"id":74}'
```

**结果示例：**

```json
{"jsonrpc":"2.0","id":74,"result":true}
```

**结果说明：**
返回当前客户端是否连接到网络



### <a name="eth_syncing">eth_syncing</a>
***


**参数说明：**

无

**请求示例：**

```shell
curl -i -H "Content-Type: application/json"  \
-X POST http://localhost:8545 \
--data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":74}'
```

**结果示例：**

```json
{"jsonrpc":"2.0","id":74,"result":false}
```

**结果说明：**
返回正在同步的块，如果没有则返回false


### <a name="eth_coinbase">eth_coinbase</a>
***


**参数说明：**

无

**请求示例：**

```shell
curl -i -H "Content-Type: application/json"  \
-X POST http://localhost:8545 \
--data '{"jsonrpc":"2.0","method":"eth_coinbase","params":[],"id":74}'
```

**结果示例：**

```json
{"jsonrpc":"2.0","id":74,"result":"0x53293cd5c9f1fdd83adffae0ef00c8900f8b38d0"}
```

**结果说明：**
返回当前客户端的coinbase地址


### <a name="eth_mining">eth_mining</a>
***


**参数说明：**

无

**请求示例：**

```shell
curl -i -H "Content-Type: application/json"  \
-X POST http://localhost:8545 \
--data '{"jsonrpc":"2.0","method":"eth_mining","params":[],"id":74}'
```

**结果示例：**

```json
{"jsonrpc":"2.0","id":74,"result":true}
```

**结果说明：**
返回当前客户端是否在进行挖矿，true代表正在挖矿; false则没有。



### <a name="eth_hashrate">eth_hashrate</a>
***


**参数说明：**

无

**请求示例：**

```shell
curl -i -H "Content-Type: application/json"  \
-X POST http://localhost:8545 \
--data '{"jsonrpc":"2.0","method":"eth_hashrate","params":[],"id":74}'
```

**结果示例：**

```json
{"jsonrpc":"2.0","id":74,"result":"0x2a8cf"}
```

**结果说明：**
返回当前节点每秒钟的hash次数（算力），结果是16进制的



### <a name="eth_gasPrice">eth_gasPrice</a>
***


**参数说明：**

无

**请求示例：**

```shell
curl -i -H "Content-Type: application/json"  \
-X POST http://localhost:8545 \
--data '{"jsonrpc":"2.0","method":"eth_hashrate","params":[],"id":74}'
```

**结果示例：**

```json
{"jsonrpc":"2.0","id":74,"result":"0x3b9aca00"}
```

**结果说明：**
返回当前单位gas的价格，以16进制的方式展示，单位是wei

比如上例中的0x3b9aca00换算成十进制则是1000000000 wei



### <a name="eth_accounts">eth_accounts</a>
***


**参数说明：**

无

**请求示例：**

```shell
curl -i -H "Content-Type: application/json"  \
-X POST http://localhost:8545 \
--data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":74}'
```

**结果示例：**

```json
{"jsonrpc":"2.0","id":74,"result":["0x53293cd5c9f1fdd83adffae0ef00c8900f8b38d0"]}
```

**结果说明：**
当前用户的地址




### <a name="eth_accounts">eth_accounts</a>
***


**参数说明：**

无

**请求示例：**

```shell
curl -i -H "Content-Type: application/json"  \
-X POST http://localhost:8545 \
--data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":74}'
```

**结果示例：**

```json
{"jsonrpc":"2.0","id":74,"result":["0x53293cd5c9f1fdd83adffae0ef00c8900f8b38d0"]}
```

**结果说明：**
当前用户的地址



### <a name="eth_blockNumber">eth_blockNumber</a>
***


**参数说明：**

无

**请求示例：**

```shell
curl -i -H "Content-Type: application/json"  \
-X POST http://localhost:8545 \
--data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":74}'
```

**结果示例：**

```json
{"jsonrpc":"2.0","id":74,"result":"0x64"}
```

**结果说明：**
返回当前网络中区块高度，结果以16进制方式表示





### <a name="eth_sendTransaction">eth_sendTransaction</a>
***


**参数说明：**

- from: DATA, 20 Bytes - The address the transaction is send from.
- to: DATA, 20 Bytes - (optional when creating new contract) The address the transaction is directed to.
- gas: QUANTITY - (optional, default: 90000) Integer of the gas provided for the transaction execution. It will return unused gas.
- gasPrice: QUANTITY - (optional, default: To-Be-Determined) Integer of the gasPrice used for each paid gas
- value: QUANTITY - (optional) Integer of the value sent with this transaction
- data: DATA - The compiled code of a contract OR the hash of the invoked method signature and encoded parameters. For details see Ethereum Contract ABI
- nonce: QUANTITY - (optional) Integer of a nonce. This allows to overwrite your own pending transactions that use the same nonce.

**请求示例：**

```shell
curl -i -H "Content-Type: application/json"  \
-X POST http://localhost:8545 \
--data '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":  [{ "from": "0x53293cd5c9f1fdd83adffae0ef00c8900f8b38d0", "to":"0x10c9f4fd140898e3f59e6dd7f3698660c63ff649",  "value": "0x1" }] ,"id":1}'
```

**结果示例：**

```json
{"jsonrpc":"2.0","id":1,"result":"0x9a11577265fb006d259a309f1d03d7a2ce75935bb0fe7a248e6542d42c10fde6"}
```

**结果说明：**
返回当前网络中区块高度，结果以16进制方式表示







# 4. 参考文档

https://ethereum.stackexchange.com/questions/28703/full-list-of-geth-terminal-commands/28704

https://infura.io/docs/ethereum#section/Project-Security/User-Agents

https://eth.wiki/json-rpc/API

https://medium.com/coinmonks/private-ethereum-by-example-b77063bb634f

https://geth.ethereum.org/docs/rpc/ns-admin

https://www.jianshu.com/p/8b345f22730c

https://www.freecodecamp.org/news/how-to-transfer-funds-on-the-ethereum-network-using-the-geth-cli-b7eac16aa3a9/

!!
https://kctheservant.medium.com/transactions-in-ethereum-e85a73068f74


!!
http://cw.hubwiz.com/card/c/web3.js-1.0/1/2/21/