## 使用openssl自建CA的方式自签内网http服务器证书

本文的目标是使用openssl的ca方式（非x509方式），自签证书并实现http服务器的安全通信，最终实现下图的效果

## 证书签发及使用过程说明
互联网上有太多资料说明证书的使用和签发过程，其核心过程简单说明如下：

1. CA中心建立自己的软件环境，包括证书签发软件、初始化自己的私钥、初始化自己的数字证书。
2. 网站使用自己的ssl软件(此处为openssl)进行私钥生成、然后用私钥生成证书请求文件csr，将证书请求文件提交到CA处。
3. CA中心收到网站提交的csr文件，则利用CA自己的私钥和数字证书对网站的csr文件进行签发，生成网站的数字证书，并下发给网站。
4. 网站将自己的私钥以及CA签发的数字证书部署到http服务器中，并启动https服务监听。
5. 普通用户在访问网站之前，需要获得CA的数字证书，因为需要通过CA的数字证书判断网站的数字证书是否是CA签发的。一般来说，CA的数字证书为了避免造假和提交可信度，会由操作系统厂商直接安装在出场的操作系统中。如果用户自行安装CA数字证书，则需要用户自行判断CA数字证书的真实性和可靠性，本文正是由用户自行安装CA数字证书的场景。
6. 用户访问网站，因为网站使用了CA中心签发的数字证书，正常建立安全通信过程，过程略。

其中，https通信过程建立以及其他详细内容，参考文档：

```http request
https://www.cnblogs.com/xdyixia/p/11610102.html
```
### 系统环境准备
在本文中准备了两台测试环境:
CA服务器：用于签发ca证书的服务器。此处选用CentOS7.4操作系统，其他操作系统也可以。操作系统已经安装好openssl软件，如果没有安装好也可以利用yum工具安装。
Website服务器：用于使用ca证书并运行网站的web服务器。此处选用CentOS7.4操作系统，安装nginx程序以加载ca证书并实现https服务。nginx程序的安装可以利用yum或者docker方式。

### 配置ca服务器
查看openssl软件版本可以确定软件已经正确安装。
```shell
[root@ca ~]# openssl version
OpenSSL 1.0.2k-fips  26 Jan 2017
```

本文选用的是openssl的ca方式，依赖openssl的配置文件openssl.cnf，该配置文件的路径在:
```shell
/etc/pki/tls/openssl.cnf
```

可以通过vi工具查看该配置文件，其中该配置文件中的部分核心配置信息如下：

```shell
[ CA_default ]
dir             = /etc/pki/CA             # 定义路径变量
database        = $dir/index.txt          # 数据库索引文件
new_certs_dir   = $dir/newcerts           # 新签署的证书保存目录，按照下面的证书序列号进行命名
certificate     = $dir/cacert.pem         # CA自己的证书路径，该证书用于签发其他证书，并用于普通用户在访问网站时候，验证网站的数字证书是否是该CA所签发。
serial          = $dir/serial             # 当前证书序列号，后续证书会递增
private_key     = $dir/private/cakey.pem  # CA自己的私钥路径名，该私钥会被用于签发其他证书。
```

目前上述目录均是空目录
```shell
[root@ca CA]# tree -C /etc/pki/CA
/etc/pki/CA
├── certs
├── crl
├── newcerts
└── private
```

#### ca服务器openssl.cnf文件配置
首先要对ca服务器的openssl.cnf文件进行配置，否则后面自签发证书无法通过。。。。。。



#### ca服务器生成私钥
```shell
openssl genrsa -out pri_key.pem
```

该证书生成之后，参考上面openssl配置文件中的配置， 需要将所生成的私钥文件pri_key.pem拷贝到 /etc/pki/CA/private/ 下面并命名为 cakey.pem 文件，否则后面CA为其他请求签署证书时候会找不到自己私钥.

```shell
cp pri_key.pem /etc/pki/CA/private/cakey.pem 
```

#### 为CA生成数字证书
CA数字证书用于发送给用户，以验证网站的数字证书是否是依赖CA的数字证书所签发。

在生成CA数字证书之前，首先要生成CA数字证书的请求文件
```shell
openssl req -new -key /etc/pki/CA/private/cakey.pem -out rootCA.csr
```

其中生成过程如下：
```shell
[root@ca ca]# openssl req -new -key /etc/pki/CA/private/cakey.pem -out rootCA.csr
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:SC
Locality Name (eg, city) [Default City]:CD
Organization Name (eg, company) [Default Company Ltd]:TESTORG
Organizational Unit Name (eg, section) []:TESTORG_CA
Common Name (eg, your name or your server's hostname) []:testorg000.com
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

主要填写了下述几个字段:

```shell
Country Name (2 letter code) [XX]:CN                                            // 国家
State or Province Name (full name) []:SC                                        // 省
Locality Name (eg, city) [Default City]:CD                                      // 市
Organization Name (eg, company) [Default Company Ltd]:TESTORG                   // 公司
Organizational Unit Name (eg, section) []:TESTORG_CA                            // 部门
Common Name (eg, your name or your server's hostname) []:testorg000.com         // CA的域名
```

以上几个字段，在后续网站申请证书的过程中，需要根据CA服务器的openssl.cnf定义的规则进行匹配，如果要求一致但是网站证书请求中不一致的，CA会拒绝签发证书



### 配置文件介绍


### 