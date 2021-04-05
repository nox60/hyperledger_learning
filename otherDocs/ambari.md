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


### nodejs准备

### python & pip

下载并解压
```shell
wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tar.xz
tar -Jxvf Python-3.7.0.tar.xz
```

进入该目录：
```shell
cd 

./configure prefix=/usr/local/python3

make && make install

```