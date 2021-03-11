## 使用自建ca签发证书

### 自建CA文件和配置结构


### 自建CA初始化

生成CA的私钥，该私钥非常重要，自签发的证书将由该私钥签发
```shell
openssl genrsa -out pri_key.pem
```

### 网站创建公私钥对

生成私钥
```shell
openssl genrsa -out key.pem 2048
```

根据私钥提取公钥
```shell script
openssl rsa -in key.pem -pubout -out key.pub
```

### 网站创建申请证书文件csr

```shell
openssl req -new -days 365 -key key.pem -out request.csr
```

将上面生成的request.csr文件发送给CA

### 自建CA为其他网站签发证书
CA为其他请求或证书签名时，需要使用到的文件有：自己的CA证书和自己的私钥文件。因此签名过程中需要提供这两个文件。



### 部署到nginx测试
### 为什么自己建设的证书浏览器不认
### 导入浏览器