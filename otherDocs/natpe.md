# 内网穿透

本文是为了解决内网穿透问题：

A是内网主机，无所谓IP是多少，因为其IP本来就是变化的。

B是公网主机，具有固定IP地址和端口。

此处两台机器都是CENTOS LINUX的， Ubuntu和其他发行版的类似，只是安装软件的方式有一定差异。

## 公网服务器配置

修改公网主机B的SSH配置文件 /etc/ssh/sshd_config

```shell
GatewayPorts yes
```
这样可以把监听的端口绑定到任意的IP 0.0.0.0上，否则只有本机 127.0.0.1可以访问。

然后重启公网主机B的sshd服务，让上面的修改生效

```restart
systemctl restart sshd
```
## 内网主机安装autoSSH服务
因为如果使用ssh方式的话，一旦断线需要手工重连，是无法长期使用的。这里使用autossh工具。

```shell
yum install autossh
```

## 让内网主机A能够免密登录到公网主机
必须要让内网主机A能够免密登录到B上，避免autossh在超时或者其他原因的时候能够重新登录，并且在登录的时候不用输入密码。

#### 1. 在内网主机A上生成公私密钥对

```shell
ssh-keygen
```

连续按回车之后，会生成相关的密钥文件。

#### 2. 将主机A的公钥信息发送到公网主机

使用ssh-copy-id命令发送

```ssh
ssh-copy-id username@b
```

其中b是公网主机b的域名或者IP地址，username是b的登录用户名。调用该命令之后，输入相关密码完事。

## 利用autossh工具实现内网穿透

在内网主机A上，利用autossh建立ssh隧道

```autossh
autossh -M 4444 -NR 80:localhost:4000 username@b -p 2200
```

参数解释:

- aaaa
- bbbb
- cccc
