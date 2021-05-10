参考：https://cwiki.apache.org/confluence/display/AMBARI/Installation+Guide+for+Ambari+2.7.5

## 机器准备

略。

机器1 Ambari 192.168.10.121
机器2 Hadoop1 192.168.10.122
机器3 Hadoop2 192.168.10.123
机器4 Hadoop3 192.168.10.124

主机改名：
```shell
hostnamectl set-hostname servername.com
```

### 更新
yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel kernel-devel libffi-devel

yum -y install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker



### JDK8准备

下载jdk，解压，将解压后的目录拷贝到合适的目录。

```shell
export JAVA_HOME=/opt/local/bin/jdk1.8.0_281
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$PATH:$JAVA_HOME/bin
```

测试安装是否成功：
```shell
[root@bigdata-template jdk1.8.0_281]# java -version
java version "1.8.0_281"
Java(TM) SE Runtime Environment (build 1.8.0_281-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.281-b09, mixed mode)
```

### MAVEN准备

wget https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.8.1/binaries/apache-maven-3.8.1-bin.tar.gz

tar xzvf apache-maven-3.8.1-src.tar.gz

增加环境变量
```shell
MAVEN_HOME=/opt/local/bin/apache-maven-3.8.1
export MAVEN_HOME
export PATH=${PATH}:${MAVEN_HOME}/bin
```

测试安装是否成功：
```shell
[root@bigdata-template software]# mvn -version
Apache Maven 3.8.1 (05c21c65bdfed0f71a2f2ada8b84da59348c4c5d)
Maven home: /opt/local/bin/apache-maven-3.8.1
Java version: 1.8.0_281, vendor: Oracle Corporation, runtime: /opt/local/bin/jdk1.8.0_281/jre
Default locale: en_US, platform encoding: UTF-8
OS name: "linux", version: "3.10.0-1160.21.1.el7.x86_64", arch: "amd64", family: "unix"
```


### git准备
先卸载系统自带的低版本git
```shell
yum remove git
```
下载git并解压

```downloadgit
wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.9.5.tar.gz
tar -xzvf git-2.9.5.tar.gz
```

```shell
make prefix=/opt/local/bin/git all
make prefix=/opt/local/bin/git install
```


### nodejs

到：https://nodejs.org/download/release/ 下载一个稳定版本的nodejs，下面选择的是14.16.0版本

```downloadnodejs
wget https://npm.taobao.org/mirrors/node/v14.16.0/node-v14.16.0-linux-x64.tar.xz
```

解压

```unzip
tar -xvf node-v14.16.0-linux-x64.tar.xz
```
把解压后的目录做一些自己的安排，比如改名，移动到你指定的某个目录下。然后设置环境变量，以保证能够运行node程序。

```setpath
# ========== Nodejs settings =====================
export PATH=/opt/local/bin/node-v14.16.0-linux-x64/bin:$PATH
```

加入环境变量之后，通过下面的命令验证node的安装是否成功
```nodejs
[root@core-center software]# node -v
v14.16.0
```
能正确显示版本号，说明node安装成功

另外需要参考下面的帖子对 npm 的全局安装目录进行改动：

https://stackoverflow.com/questions/29468404/gyp-warn-eacces-user-root-does-not-have-permission-to-access-the-dev-dir

设置淘宝源：
```shell
npm config set registry https://registry.npm.taobao.org
```

验证:
```shell
npm config get registry
```

安装Bower
```shell
npm -g install bower
```

安装gulp
```shell
npm -g install gulp
```

# yarn

浏览器访问： https://github.com/yarnpkg/yarn/releases/

找到要下载的版本，本次下载的版本是：1.22.10

```shell
wget https://github.com/yarnpkg/yarn/releases/download/v1.22.10/yarn-v1.22.10.tar.gz
```

解压：
```shell
tar -xzvf yarn-v1.22.10.tar.gz
```

环境变量设置：
```shell
# ========== yarn ===============================
export PATH=$PATH:/opt/local/bin/yarn-v1.22.10/bin
```

设置国内源：
```shell
yarn config set registry https://registry.npm.taobao.org
```


### python & pip
首先删除系统自带的：

```shell
yum remove python
```
下载并解压
```shell
wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tar.xz
https://www.python.org/ftp/python/2.7.17/Python-2.7.17.tgz
tar -xvf Python-3.7.0.tar.xz
```

进入该目录：
```shell
cd 

./configure prefix=/opt/local/bin/python3

make && make install


```
修改

```shell
[root@bigdata-template bin]# rm -rf /usr/bin/python
[root@bigdata-template bin]# ln -s /usr/local/bin/python3/bin/python2.7 /usr/bin/python
[root@bigdata-template bin]# ln -s /usr/local/bin/python3/bin/pip3 /usr/bin/pip
```

### 解决yum 对python2的依赖问题

vi /usr/bin/yum
将第一行"#!/usr/bin/python" 改为 "#!/usr/bin/python2.7"即可。


vi /usr/libexec/urlgrabber-ext-down
将第一行"#!/usr/bin/python" 改为 "#!/usr/bin/python2.7"即可。


### 安装rpm-build工具

yum install rpm-build


### 执行的命令

mvn -B -e -X clean install rpm:rpm -DnewVersion=2.7.5.0.0 apache-rat:check -Drat.numUnapprovedLicenses=600 -DbuildNumber=5895e4ed6b30a2da8a90fee2403b6cab91d19972 -DskipTests -Dpython.ver="python >= 2.6"

### 文件无法下载的问题
利用迅雷直接下载，可以下下来

https://s3.amazonaws.com/dev.hortonworks.com/HDP/centos7/3.x/BUILDS/3.1.4.0-315/tars/hbase/hbase-2.0.2.3.1.4.0-315-bin.tar.gz

http://shangdixinxi.com/detail-1333021.html




https://bbs.huaweicloud.com/blogs/226400
https://docs.cloudera.com/HDPDocuments/Ambari/Ambari-2.7.4.0/index.html






