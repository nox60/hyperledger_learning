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




# 3. 调用例子

<a name="web3_clientVersion">web3_clientVersion</a>
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