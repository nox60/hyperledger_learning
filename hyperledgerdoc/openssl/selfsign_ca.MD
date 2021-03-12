## 使用自建ca签发证书

### 自建CA文件和配置结构


### 自建CA初始化

openssl是由一定的默认配置的，其默认配置保存在：
```shell
/etc/pki/tls/openssl.cnf
```

```shell
[ CA_default ]
dir             = /etc/pki/CA             # 定义路径变量
certs           = $dir/certs              # 已颁发证书的保存目录
database        = $dir/index.txt          # 数据库索引文件
new_certs_dir   = $dir/newcerts           # 新签署的证书保存目录
certificate     = $dir/cacert.pem         # CA证书路径名
serial          = $dir/serial             # 当前证书序列号
private_key     = $dir/private/cakey.pem  # CA的私钥路径名
```

CA要为签署其他请求来的数字证书，首先需要自己具有私钥和对应数字证书。因此首先要生成CA的私钥，该私钥非常重要
```shell
openssl genrsa -out pri_key.pem
```

该证书生成之后，参考上面openssl配置文件中的配置， 需要将所生成的私钥文件pri_key.pem拷贝到 /etc/pki/CA/private/ 下面并命名为 cakey.pem 文件，否则后面CA为其他请求签署证书时候会找不到自己私钥

然后要为CA生成CA的数字证书请求文件

```shell
openssl req -new -key /etc/pki/CA/private/cakey.pem -out rootCA.csr
```
此处就得到了CA数字证书请求文件rootCA.csr

接下来即将为CA签发自己的数字证书，该数字证书后续将用来为其他证书请求签发数字证书。在签发之前，要为CA创建数据库索引文件，否则签发要出错

```shell
touch /etc/pki/CA/index.txt 
echo "01" > /etc/pki/CA/serial
```

现在可以对CA自身的数字证书进行签发了，执行下面的命令：
```shell
openssl ca -selfsign -in rootCA.csr
```
会被询问是否确定要签发，选择回车，则签发。

执行下面的命令，可以发现CA的相关目录中签发了一个新的数字证书 01.pem，该数字证书是CA的数字证书

```shell
[root@k1 ca]#  tree -C /etc/pki/CA
/etc/pki/CA
├── certs
├── crl
├── index.txt
├── index.txt.attr
├── index.txt.old
├── newcerts
│   └── 01.pem
├── private
│   └── cakey.pem
├── serial
└── serial.old

```

现在需要将01.pem证书拷贝到openssl配置文件中的配置的路径中去，并命名为cacert.pem文件，否则无法为其他网站签发证书，执行下面的命令：
```shell
cp /etc/pki/CA/newcerts/01.pem /etc/pki/CA/cacert.pem
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

注意，在生成网站的csr申请文件过程中，国家、省、市的信息，要和CA创建自己证书的时候的一致，否则会报错。

在网站电脑上，利用下面的命令生辰CSR

```shell
openssl req -new -days 365 -key key.pem -out request.csr
```

将上面生成的request.csr文件发送给CA


### 自建CA为该网站签发证书
CA使用自己的私钥和证书（均已经配置在openssl配置文件指定的路径中了）来为网站签发证书

```shell
openssl ca -in request.csr
```

签发成功之后，可以看到CA生成了一个名为02.pem（根据当前的生成序号生成的）的证书文件

```shell
[root@k1 ca]# tree -C /etc/pki/CA
/etc/pki/CA
├── cacert.pem
├── certs
├── crl
├── index.txt
├── index.txt.attr
├── index.txt.attr.old
├── index.txt.old
├── newcerts
│   ├── 01.pem
│   └── 02.pem
├── private
│   └── cakey.pem
├── serial
└── serial.old
```

### 部署到nginx测试
网站服务器获得CA签发的02.pem证书之后，可以进行SSL相关的配置。以Nginx为例，配置SSL需要两个文件，一个是网站的私钥文件（key.pem），一个是CA给网站签发的证书文件（02.pem）。

nginx的配置片段如下：

```shell
    server {
        listen 443 ssl;
        server_name code20.cn;
        root /usr/share/nginx/html;
        ssl_certificate         /usr/local/nginx/conf/1_code20.cn_bundle.crt;
        ssl_certificate_key     /usr/local/nginx/conf/2_code20.cn.key;
        ssl_session_timeout 5m;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
        ssl_prefer_server_ciphers on;

        error_page 400 404 500 502 503 504 /50x.html;
            location = /error {
                root /usr/share/nginx/html/40x.html;
            }

    }
```

其中，ssl_certificate



### 为什么自己建设的证书浏览器不认
### 导入浏览器















































## 使用自建ca签发证书

### 自建CA文件和配置结构


### 自建CA初始化

openssl是由一定的默认配置的，其默认配置保存在：
```shell
/etc/pki/tls/openssl.cnf
```

```shell
[ CA_default ]
dir             = /etc/pki/CA             # 定义路径变量
certs           = $dir/certs              # 已颁发证书的保存目录
database        = $dir/index.txt          # 数据库索引文件
new_certs_dir   = $dir/newcerts           # 新签署的证书保存目录
certificate     = $dir/cacert.pem         # CA证书路径名
serial          = $dir/serial             # 当前证书序列号
private_key     = $dir/private/cakey.pem  # CA的私钥路径名
```

CA要为签署其他请求来的数字证书，首先需要自己具有私钥和对应数字证书。因此首先要生成CA的私钥，该私钥非常重要
```shell
openssl genrsa -out pri_key.pem
```

该证书生成之后，参考上面openssl配置文件中的配置， 需要将所生成的私钥文件pri_key.pem拷贝到 /etc/pki/CA/private/ 下面并命名为 cakey.pem 文件，否则后面CA为其他请求签署证书时候会找不到自己私钥

然后要为CA生成CA的数字证书请求文件

```shell
openssl req -new -key /etc/pki/CA/private/cakey.pem -out rootCA.csr
```
此处就得到了CA数字证书请求文件rootCA.csr

接下来即将为CA签发自己的数字证书，该数字证书后续将用来为其他证书请求签发数字证书。在签发之前，要为CA创建数据库索引文件，否则签发要出错

```shell
touch /etc/pki/CA/index.txt 
echo "01" > /etc/pki/CA/serial
```

现在可以对CA自身的数字证书进行签发了，执行下面的命令：
```shell
openssl ca -selfsign -in rootCA.csr
```
会被询问是否确定要签发，选择回车，则签发。

执行下面的命令，可以发现CA的相关目录中签发了一个新的数字证书 01.pem，该数字证书是CA的数字证书

```shell
[root@k1 ca]#  tree -C /etc/pki/CA
/etc/pki/CA
├── certs
├── crl
├── index.txt
├── index.txt.attr
├── index.txt.old
├── newcerts
│   └── 01.pem
├── private
│   └── cakey.pem
├── serial
└── serial.old

```

现在需要将01.pem证书拷贝到openssl配置文件中的配置的路径中去，并命名为cacert.pem文件，否则无法为其他网站签发证书，执行下面的命令：
```shell
cp /etc/pki/CA/newcerts/01.pem /etc/pki/CA/cacert.pem
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

注意，在生成网站的csr申请文件过程中，国家、省、市的信息，要和CA创建自己证书的时候的一致，否则会报错。

在网站电脑上，利用下面的命令生辰CSR

```shell
openssl req -new -days 365 -key key.pem -out request.csr
```

将上面生成的request.csr文件发送给CA


### 自建CA为该网站签发证书
CA使用自己的私钥和证书（均已经配置在openssl配置文件指定的路径中了）来为网站签发证书

```shell
openssl ca -in request.csr
```

签发成功之后，可以看到CA生成了一个名为02.pem（根据当前的生成序号生成的）的证书文件

```shell
[root@k1 ca]# tree -C /etc/pki/CA
/etc/pki/CA
├── cacert.pem
├── certs
├── crl
├── index.txt
├── index.txt.attr
├── index.txt.attr.old
├── index.txt.old
├── newcerts
│   ├── 01.pem
│   └── 02.pem
├── private
│   └── cakey.pem
├── serial
└── serial.old
```

### 部署到nginx测试
网站服务器获得CA签发的02.pem证书之后，可以进行SSL相关的配置。以Nginx为例，配置SSL需要两个文件，一个是网站的私钥文件（key.pem），一个是CA给网站签发的证书文件（02.pem）。

nginx的配置片段如下：

```shell
    server {
        listen 443 ssl;
        server_name code20.cn;
        root /usr/share/nginx/html;
        ssl_certificate         /usr/local/nginx/conf/1_code20.cn_bundle.crt;
        ssl_certificate_key     /usr/local/nginx/conf/2_code20.cn.key;
        ssl_session_timeout 5m;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
        ssl_prefer_server_ciphers on;

        error_page 400 404 500 502 503 504 /50x.html;
            location = /error {
                root /usr/share/nginx/html/40x.html;
            }

    }
```

其中，ssl_certificate



### 为什么自己建设的证书浏览器不认
### 导入浏览器