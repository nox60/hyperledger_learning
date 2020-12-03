# 内网穿透

A是内网主机，无所谓IP是多少，因为其IP本来就是变化的。

B是公网主机，具有固定IP地址和端口。

此处两台机器都是LINUX的。

# 第一步：公网服务器配置

修改公网主机B的SSH配置文件 /etc/ssh/sshd_config

```shell
GatewayPorts yes
```
这样可以把监听的端口绑定到任意的IP 0.0.0.0上，否则只有本机 127.0.0.1可以访问。

然后重启公网主机B的sshd服务，让上面的修改生效

```restart
systemctl restart sshd
```
