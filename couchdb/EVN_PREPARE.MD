## 基本环境配置使用

### Docker 安装
#### 通过apt-get安装方式

#### 二进制安装方式

### 操作工具(curl)准备
部分操作系统是没有直接安装curl工具的，使用下面的命令进行安装：
```shell script
apt-get -y install curl
```

同时因为couchdb提供的api返回的数据结构是json，为了在终端能够更为友好的将json数据格式进行展示并显示，这里推荐jq工具。
```shell script
apt-get -y install jq
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
docker run --rm my-curl-jq:1.0 sh -c \
"curl -X GET  http://www.weather.com.cn/data/sk/101010100.html | jq"
```

返回格式化之后的结果数据，说明继承了curl和jq工具的容器镜像配置成功
```json
{
  "weatherinfo": {
    "city": "北京",
    "cityid": "101010100",
    "temp": "27.9",
    "WD": "南风",
    "WS": "小于3级",
    "SD": "28%",
    "AP": "1002hPa",
    "njd": "暂无实况",
    "WSE": "<3",
    "time": "17:55",
    "sm": "2.1",
    "isRadar": "1",
    "Radar": "JC_RADAR_AZ9010_JB"
  }
}

```


### 直接更新couchdb的镜像为带有curl和jq
```shell
cat > Dockerfile<< EOF
FROM couchdb:3.0
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install curl jq
EOF
```
 

