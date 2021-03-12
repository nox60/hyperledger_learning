首先生成私钥

```shell script
openssl genrsa -out key.pem 2048
```
然后根据私钥提取公钥

```shell script
openssl rsa -in key.pem -pubout -out key.pub
```

开始生成X509格式的自签名证书,会要求输入区别名DN的各项信息（国家，城市，组织，姓名，email等.

```shell script
openssl req -x509 -new -days 365 -key key.pem -out cert.crt
```

会生成三个文件
```shell script
[root@k1 openssl_temp]# ls
cert.crt  key.pem  key.pub
```

使用openssl 读取证书信息
```shell script
openssl x509 -in cert.crt -noout -text
```

利用私钥生成证书请求csr
```shell script
openssl req -new -key server.key -out server.csr
```

利用x509工具签发证书, 使用根CA证书**ca.crt**和私钥**ca.key**对"请求签发证书**server.csr**进行签发，生成x509格式证书

```shell script
openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out serverx509.crt
```

openssl x509 -req -sha256 -days 365 -in server.csr -signkey server.key -out server.crt


参考文章：

https://www.cnblogs.com/wangao1236/p/11609429.html

https://www.cnblogs.com/f-ck-need-u/p/7048359.html#blogopenssl

https://blog.51cto.com/9843231/2456947

https://blog.csdn.net/qq_42388880/article/details/103514824


