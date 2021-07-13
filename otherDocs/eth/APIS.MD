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


| 命令 |参数       | 说明      |
|--------- | ---------  | --------- | 
| <a href="#web3_clientVersion"> web3_clientVersion </a> | 无 | 返回当前客户端版本|
| <a href="#web3_sha3"> web3_sha3 </a> | 无 | 对给定字符串进行基于sha3算法的散列计算|
| <a href="#net_version"> net_version </a> | 无 | 返回当前客户端版本|
| <a href="#net_peerCount"> net_peerCount </a> | 无 | 返回当前客户端版本|
| <a href="#net_listening"> net_listening </a> | 无 | 返回当前客户端版本|
| <a href="#eth_protocolVersion"> eth_protocolVersion </a> | 无 | 返回当前客户端版本|
| <a href="#eth_syncing"> eth_syncing </a> | 无 | 返回当前客户端版本|




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

返回当前网络的类型，其中


### <a name="net_peerCount">net_peerCount</a>
***

调用例子：
```shell
curl -i -H "Content-Type: application/json"  \
-X POST http://localhost:8545 \
--data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":67}'
```

调用结果：
```json
{"jsonrpc":"2.0","id":67,"result":"Geth/v1.10.4-stable-aa637fd3/linux-amd64/go1.16.4"}
```




### <a name="net_listening">net_listening</a>
***

调用例子：
```shell
curl -i -H "Content-Type: application/json"  \
-X POST http://localhost:8545 \
--data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":67}'
```

调用结果：
```json
{"jsonrpc":"2.0","id":67,"result":"Geth/v1.10.4-stable-aa637fd3/linux-amd64/go1.16.4"}
```





### <a name="eth_protocolVersion">eth_protocolVersion</a>
***

调用例子：
```shell
curl -i -H "Content-Type: application/json"  \
-X POST http://localhost:8545 \
--data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":67}'
```

调用结果：
```json
{"jsonrpc":"2.0","id":67,"result":"Geth/v1.10.4-stable-aa637fd3/linux-amd64/go1.16.4"}
```





### <a name="eth_syncing">eth_syncing</a>
***

调用例子：
```shell
curl -i -H "Content-Type: application/json"  \
-X POST http://localhost:8545 \
--data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":67}'
```

调用结果：
```json
{"jsonrpc":"2.0","id":67,"result":"Geth/v1.10.4-stable-aa637fd3/linux-amd64/go1.16.4"}
```




# 4. 参考文档

https://ethereum.stackexchange.com/questions/28703/full-list-of-geth-terminal-commands/28704