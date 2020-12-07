### 概念说明

CouchDB与传统的关系型数据库不同，CouchDB是一个文档数据库。文档数据库并不是说只能存储文本，事实上是一种基于schemaless的设计方式。关系型数据库数据表里定义的每一个字段都定义为一种类型：无论是int, varchar, datetime。 但couchDB的字段只有三个：文档ID、文档版本号和内容。内容字段可以看到是一个text类型的文本，里面可以定义任意类型的数据，而不用关注其中的数据类型，但数据必须以json的形式表示并存放。例如一个表述用户的文档可以表示为：[_id:1001, _rev:1-32443289, {'name':'hello','value':''world','time':'2020-01-02 20:01:01'}]。couchDB是利用erlang语言实现的，其提供了大量RESTful API以对外暴露服务，通过这些RESTful API，能够对数据库完成相关的操作，而无需像很多关系型数据库一样需要客户端软件，然后使用SQL指令才能操作数据库系统。正因为采用CouchDB有了统一且简洁的Restful服务接口，可以很方便地开发各种语言的客户端，以方便不同程序员的使用。比如前端工程师可以利用这些API，直接开发一个博客系统或者其他在线系统，而不需要通过后端程序专门构建一套后端API。

##### 优点
CouchDB最大的优点上面已经提到过，其可以实现快速的开发，很大程度的降低了一个系统的开发复杂度，只需要JavaScript代码就能对数据库进行操作，这在目前的关系数据库系统中，是无法实现的。

1、couchDB的属性可以灵活增删，要增加一个新属性只需要往数据字段多写入一个属性即可。mysql在数据量大了之后，再增删字段会比较耗费时间，在线操作更是让人难以忍受的（视数据量大小有可能要锁表几十分钟到一天）；

2、文档间属性的不一致，如有些记录可能有A属性而有一些没有，用mysql则只能把没有该属性的用户的值置为0或空，影响存储与查询；

3、查询效率，经常会需要对某个字段进行查询，得到某个满足条件的子集，用mysql要对每个字段的查询都达到高效只能采用对该字段建索引的办法，使得索引文件变大，如果新增字段又要新建索引，建立索引也是一个锁表又冗长的过程。couchDB应用map-reduce的方法使得计算量可以分散（注意：跟google的那个不太一样，这里的map-reduce实际上还是在一台机器完成，且没有发现多个进程，没有看到线程个数的配置，这是我感到最难解的，难道还是单线程流水处理的？），虽然也是像没有建索引的mysql一样需要扫全表，但可以对常用的一些查询建立永久索引，索引是随数据的增长增量更新的，减少查询时间。

-- 查询速度的对比还需要进一步分析

当然，强大的mysql也有类似的解决方案，且看friendfeed的schema-less mysql方案。

##### 缺点
对比之后总结

##### 技术特点
CouchDB使用B-tree的数据结构进行数据保存。




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


### JavaScript

https://docs.couchdb.org/en/stable/query-server/javascript.html

https://docs.couchdb.org/en/stable/ddocs/ddocs.html#creation

https://docs.couchdb.org/en/stable/ddocs/ddocs.html

https://my.oschina.net/u/811958/blog/368661

### Design Document

A design document is a CouchDB document with an id that begins with _design/. For
instance, the example blog application, Sofa, is stored in a design document with the
ID _design/sofa (see Figure 5-1). Design documents are just like any other CouchDB
document—they replicate along with the other documents in their database and track
edit conflicts with the rev parameter.

Design Document 是CouchDB的一种标注报文格式，其URL以 _design/开头，并且携带一个ID

Design Document是一种标准的JSON格式。