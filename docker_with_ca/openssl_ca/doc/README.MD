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
penssl req -x509 -new -days 365 -key key.pem -out cert.crt
```

会生成三个文件
```shell script
[root@k1 openssl_temp]# ls
cert.crt  key.pem  key.pub
```