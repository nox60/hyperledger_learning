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
docker run --rm my-curl-jq:1.0 \
sh -c "curl -X GET  http://www.weather.com.cn/data/sk/101010100.html | jq"
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


