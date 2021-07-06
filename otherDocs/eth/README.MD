# 1. 软件安装

## 1.1 软件下载与配置
前往 https://geth.ethereum.org/downloads/ 下载对应的软件
此处因为本机是CentOS环境，则选择了对应的二进制版本：
```shell
wget https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.4-aa637fd3.tar.gz
tar -xzvf geth-linux-amd64-1.10.4-aa637fd3.tar.gz
```

然后将相应的二进制文件加入到path中去，以便能够执行，修改 /etc/profile 文件，增加相应的内容：

```shell
PATH=/root/softwares/geth-linux-amd64-1.10.4-aa637fd3:$PATH
export PATH
```

对新增加的环境变量配置信息生效，并执行geth version命令查看是否正确：
```shell
[root@fabric70 softwares]# source /etc/profile
[root@fabric70 softwares]# geth version
Geth
Version: 1.10.4-stable
Git Commit: aa637fd38a379db6da98df0d520fb1c5139a18ce
Git Commit Date: 20210617
Architecture: amd64
Go Version: go1.16.4
Operating System: linux
GOPATH=
GOROOT=go
```

从上面看，geth命令已经可以执行。

# 2. 环境配置
# 3. 服务启动
# 4. 操作