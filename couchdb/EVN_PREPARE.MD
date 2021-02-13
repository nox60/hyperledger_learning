## 基本环境配置使用

###
```shell
wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.gz
tar -xzvf autoconf-2.71.tar.gz
./configure --prefix=/usr/local
```

### 准备一个包含curl和jq的镜像

```shell
cat > Dockerfile<< EOF
FROM ubuntu
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install curl jq
EOF
```

```shell
docker build -t my-curl-jq:1.0 .
```

测试
```shell
docker run --rm -it \
    --name curl-temp \
    my-curl-jq:1.0 \
    curl -X GET  \
    http://www.weather.com.cn/data/sk/101010100.html | jq
```