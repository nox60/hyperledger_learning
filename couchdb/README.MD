### 概念说明

CouchDB与传统的关系型数据库不同，CouchDB是一个文档数据库。文档数据库并不是说只能存储文本，事实上是一种基于schemaless的设计方式。关系型数据库数据表里定义的每一个字段都定义为一种类型：无论是int, varchar, datetime。 但couchDB的字段只有三个：文档ID、文档版本号和内容。内容字段可以看到是一个text类型的文本，里面可以定义任意类型的数据，而不用关注其中的数据类型，但数据必须以json的形式表示并存放。例如一个表述用户的文档可以表示为：[_id:1001, _rev:1-32443289, {'name':'hello','value':''world','time':'2020-01-02 20:01:01'}]。couchDB是利用erlang语言实现的，其提供了大量RESTful API以对外暴露服务，通过这些RESTful API，能够对数据库完成相关的操作，而无需像很多关系型数据库一样需要客户端软件，然后使用SQL指令才能操作数据库系统。正因为采用CouchDB有了统一且简洁的Restful服务接口，可以很方便地开发各种语言的客户端，以方便不同程序员的使用。比如前端工程师可以利用这些API，直接开发一个博客系统或者其他在线系统，而不需要通过后端程序专门构建一套后端API。



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
