# 下载

似乎不能用wget或者curl下载，需要手动下载然后上传
```shell
https://github.com/protocolbuffers/protobuf/releases/download/v2.6.1/protobuf-2.6.1.tar.gz
```

将文件解压
```shell
tar -xzvf protobuf-2.6.1.tar.gz
```

需要g++依赖，如果没有的话安装

```shell
yum install gcc-c++
```

依次执行：
```shell
./confingure --prefix=/opt/local/bin/protobuf
make & make install
```

添加环境变量
```shell
/opt/local/bin/protobuf/bin
```

测试是否安装成功：
```shell
protoc --version
libprotoc 2.6.1
```

安装go的protoc支持
```shell
go get github.com/golang/protobuf/protoc-gen-go
```

https://zhuanlan.zhihu.com/p/83010418