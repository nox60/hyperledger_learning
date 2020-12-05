### 快速安装

```dockerfile
docker run --name my-couchdb \
    -v /opt/local/containers/couchdb/data:/opt/couchdb/data \
    -p 5984:5984 \
    -e COUCHDB_USER=admin \
    -e COUCHDB_PASSWORD=password \
    -d couchdb:3.0
```

##### 参数说明

- -v 是数据目录相关挂载
- -p 是api端口

### 简单操作

查看所有数据库

访问:
```utils
http://localhost:5984/_utils
```
