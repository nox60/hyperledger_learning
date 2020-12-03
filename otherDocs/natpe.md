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
因为如果使用ssh方式的话，一旦断线需要手工重连，是无法长期使用的。这里使用autossh工具，所以在A主机上执行下面的命令。

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
ssh-copy-id -p 2200 username@b
```

其中b是公网主机B的域名或者IP地址，username是b的登录用户名, -p 2200 是公网主机B的SSH端口，默认是22，但是很多时候为了安全可能会更改。调用该命令之后，输入相关密码结束。

在执行上述命令之后，可以在A主机测试公钥是否成功发送到B主机，测试的方法就是免密码尝试登录，如果能够登录成功，则说明操作成功。

```llgin
ssh -p 2200 username@b
```

如果在A主机执行上述命令，能够成功登录B主机，说明公钥已经成功安装到B主机，可以免密登录。

## 利用autossh工具实现内网穿透

在内网主机A上，利用autossh建立ssh隧道

```autossh
autossh -M 4444 -fCNR 11111:localhost:22 username@b -p 2200
```

相关参数和代码解释:

- -M 4444 参数是内网主机A用来接收B主机通治的，如果隧道不正常，B主机会通过该端口通知A主机要求A主机重新连接。
- -f 后台执行ssh指令
- -C 允许压缩数据
- -N 不执行远程命令
- -R 将远程主机（公网主机B）的某个端口转发到本地指定机器的指定端口，这也是本文的全部目的
- 11111:localhost:22 将公网主机B的11111端口上的请求，转发到内网主机A的22端口上
- username@b b是公网B主机的域名或者端口，username是相关登录用户名
- p 2200 是公网B主机的SSH端口，此处假设是2200，根据真实情况改变。

## 检查

#### 1. 登录检查
在任何一台能够访问公网主机B的计算机上，通过ssh命令，可以访问到内网的主机A

```aaa
ssh -p 11111 userOfA@b
```

其中，11111是上面命令中，B主机用来开放并映射转发到A主机上的端口，userOfA是A主机的一个用户名，b是B主机的公网域名或者IP地址。

如果正常的话，在提示输入密码之后，会发现ssh登录的主机是A主机而不是B主机，这就实现了内网穿透：原本在公网上是无法访问到处于内网中的A主机的。

#### 2. 分别检查本地主机A和公网主机B的端口监听情况
##### 登录到A主机上，
```aa
[root@server70 ~]# netstat -ntp
Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 192.168.16.70:22        192.168.7.30:64776      ESTABLISHED 24918/sshd: root@pt
tcp        0     36 192.168.16.70:22        192.168.7.30:58241      ESTABLISHED 25853/sshd: root@pt
tcp        0      0 192.168.16.70:22        192.168.7.30:64780      ESTABLISHED 24920/sshd: root@no
tcp        0      0 192.168.16.70:22        192.168.7.30:58243      ESTABLISHED 25855/sshd: root@no
tcp        0      0 192.168.16.70:52880     94.191.74.113:2200      ESTABLISHED 25697/ssh
```

其中可以看到PID为25697的连接，是本机和远程服务器建立的连接

为了检测 autossh的稳定行，通过下面的命令关闭该连接：

```aaa
kill -9 25697
```
再次查看连接情况，会发现监听在2200端口上的通信进程会再次建立，只是PID发生了更改，然后在其他主机上通过B主机访问内网主机A，依然能够成功，说连接重新建立了起来。


##### 登录到B主机上，
```aaa
[root@serverb ~]# netstat -ntlp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:11111           0.0.0.0:*               LISTEN      14189/sshd: nox
tcp        0      0 0.0.0.0:4444            0.0.0.0:*               LISTEN      14189/sshd: nox
```

可以看到PID为14189所建立的，在11111端口上监听的进程

为了检测 autossh的稳定性，通过下面的命令关闭该连接：

```aaa
kill -9 14189
```

再次查看连接情况，会发现监听在11111端口上的通信进程会再次建立，只是PID发生了更改，然后在其他主机上通过B主机访问内网主机A，依然能够成功，说连接重新建立了起来。

## 为A主机设置autossh的自动连接
为了保证A主机在重新启动之后能够自动连接到B主机，以此保证在外面能够稳定访问到A主机，需要设置开机自动执行命令。

