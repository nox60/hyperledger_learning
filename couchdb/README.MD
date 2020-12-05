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

### 设计原则

couchdb这样的文档数据库，用于在请求-响应一对一关系时候比较适合，比如博客请求中的ID和文章的对应关系

### 利用couchdb设计一个博客系统
