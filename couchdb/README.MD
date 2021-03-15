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

这里采用的是用Docker的方式安装，如果需要二进制的安装方式移步官方文档。

```dockerfile
docker run --name my-couchdb \
    -v /opt/local/containers/couchdb/data:/opt/couchdb/data \
    -v /opt/local/containers/couchdb/log/couch.log:/opt/couchdb/couch.log \
    -p 5984:5984 \
    -e COUCHDB_USER=admin \
    -e COUCHDB_PASSWORD=password \
    -d couchdb:3.0

sleep 5

curl localhost:5984
curl -X PUT http://admin:password@localhost:5984/_users
curl -X PUT http://admin:password@localhost:5984/_replicator
curl -X PUT http://admin:password@localhost:5984/_global_changes  
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

http://guide.couchdb.org/editions/1/en/index.html

https://callahan.io/blog/2016/06/04/debugging-couchdb-design-documents

https://blog.csdn.net/u012731379/article/details/79872120

https://github.com/apache/couchdb/issues/1354

// map-reduce process
https://blog.pablobm.com/2019/07/18/map-reduce-with-couchdb-a-visual-primer.html

http://www.srcmini.com/apache-couchdb/

### Design Document

A design document is a CouchDB document with an id that begins with _design/. For
instance, the example blog application, Sofa, is stored in a design document with the
ID _design/sofa (see Figure 5-1). Design documents are just like any other CouchDB
document—they replicate along with the other documents in their database and track
edit conflicts with the rev parameter.

Design Document 是CouchDB的一种标注报文格式，其URL以 _design/开头，并且携带一个ID

Design Document是一种标准的JSON格式。

首先调用下面的命令创建一个仓库：

```shell script
curl -X PUT http://admin:password@127.0.0.1:5984/basic
```

然后执行下面的命令提交view
```json
curl -X PUT http://admin:password@127.0.0.1:5984/basic/_design/example -d @js_examples/first.json
```

执行几次下面的命令，给basic这个仓库增加测试数据
```shell script
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{}'
```

然后执行下面的命令，调用刚才的view里面的查询函数foo，获取查询出来的数据
```
curl http://admin:password@localhost:5984/basic/_design/example/_view/foo
```

得到执行结果如下：

```shell script
{"total_rows":3,"offset":0,"rows":[
{"id":"592029f8e459a449c3c8b54171000cd3","key":"592029f8e459a449c3c8b54171000cd3","value":"1-967a00dff5e02add41819138abb3284d"},
{"id":"592029f8e459a449c3c8b54171001434","key":"592029f8e459a449c3c8b54171001434","value":"1-967a00dff5e02add41819138abb3284d"},
{"id":"592029f8e459a449c3c8b5417100209b","key":"592029f8e459a449c3c8b5417100209b","value":"1-967a00dff5e02add41819138abb3284d"}
]}
```

### View

```Javascript
function(doc) {
    if(doc.date && doc.title) {
        emit(doc.date, doc.title);
    }
}
```

view可以理解为是mysql中的view，也可以理解为是其他后台语言中的业务层代码，其实质目的都是用于将数据按照用户的要求查出。

view在用户查询的时候执行，会将数据进行整理、排序、筛选。最终按照用户要求的格式展示。

All map functions have a single parameter doc. This is a single document in the database.
Our map function checks whether our document has a date and a title attribute—
luckily, all of our documents have them—and then calls the built-in emit() function
with these two attributes as arguments.

所有的map函数都接受一个单参数doc，其是数据库中的一个文档，实例总的map函数检查了两个参数，一个是doc.date，一个是doc.title，均检查以上两个值是否存在。

The emit() function always takes two arguments: the first is key, and the second is
value. The emit(key, value) function creates an entry in our view result. One more
thing: the emit() function can be called multiple times in the map function to create
multiple entries in the view results from a single document, but we are not doing that
yet.

emit函数总是接受两个参数，第一个是键(key)，第二个是值(value)，此处传入的是doc.date和doc.title。emit函数会被调用多次。没调用一次，创建一行数据结果。

CouchDB takes whatever you pass into the emit() function and puts it into a list (see
Table 6-1). Each row in that list includes the key and value. More importantly, the list
is sorted by key (by doc.date in our case). The most important feature of a view result
is that it is sorted by key. We will come back to that over and over again to do neat
things. Stay tuned.

CouchDB 将emit中传入的参数放入一个列表中，然后列表中的每一行都由键值对组成，并且该列表是由键排序的？比如例子中的doc.data

马上来做个测试，写入几行数据，其中每行有 doc.data日期类型，然后按日期排序试试

执行几次下面的命令，给basic这个仓库增加测试数据
```shell script
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2019-01-01 14:02:11", "related_value":"Some content"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2020-04-01 08:12:24", "related_value":"Some content2"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2018-08-23 12:49:05", "related_value":"Some content3"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2020-08-16 04:35:12", "related_value":"Some content4"}'
```

创建一个view，文件名为view2.json
```shell script
{
  "_id": "_design/example",
  "views": {
    "view2": {
      "map": "function(doc){ if(doc.date && doc.title) { emit(doc.date, doc.title); } }"
    }
  }
}
```

提交上述的view
```json
curl -X PUT http://admin:password@127.0.0.1:5984/basic/_design/example -d @js_examples/view2.json
```


然后执行下面的命令，调用刚才的view里面的查询函数foo，获取查询出来的数据
```
curl http://admin:password@localhost:5984/basic/_design/example/_view/view2
```

// 在做一个测试，看看是否会带出更多的数据
执行几次下面的命令，给basic这个仓库增加测试数据
```shell script
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2019-01-01 14:02:11", "related_value":"Some content", "related_person":"Jimmy wang"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2020-04-01 08:12:24", "related_value":"Some content2"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2018-08-23 12:49:05", "related_value":"Some content3"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2020-08-16 04:35:12", "related_value":"Some content4"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2017-01-22 07:29:04", "related_value":"Some content5"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2020-06-14 01:28:11", "related_value":"Some content6", "related_person":"Kelly Zuo"}'
```

经过测试证明，view会带出整个文档，只是在reduce过程中会选用指定的值进行reduct


用下面的命令可以进行key的范围查询，注意字母大小写敏感，一旦写错会失效
```shell script
http://admin:password@192.168.16.70:5984/basic/_design/example/_view/view2?startkey="2018-08-23 12:49:05"&endkey="2022-08-23 12:49:05"
```

增加测试数据如下：

```shell script
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_key":"a", "sample_value":1, "related_person":"Kelly Zuo"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_key":"a", "sample_value":"6", "related_person":"Tom Jacky"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_key":"b", "sample_value":"55", "related_person":"Naomi Sandy"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_key":"b", "sample_value":189, "related_person":"Naomi Sandy"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_key":"b", "sample_value":67, "related_person":"Naomi Sandy"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_key":"c", "sample_value":5, "related_person":"Kelly Zuo"}'
```



水果的map函数
```shell script
function(doc) {
    var shop, price;
    if (doc.item && doc.prices) {
        doc.prices.forEach(function(i) {
              emit(doc.item, i);
        });
    }
}
```


通话记录例子

```shell script
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1001", "billSeconds": 180  }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1001", "billSeconds": 120  }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1002", "billSeconds": 214  }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1002", "billSeconds": 80  }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1003", "billSeconds": 160  }'
```

基于上面的例子，构造map函数

```map
function(doc) {
    if (doc.phoneNumber && doc.billSeconds) {
        emit(doc.phoneNumber, doc.billSeconds);
    }
}
```

再构造reduce函数
```reduce
function(keys, values) {
    return sum(values);
}
```

得到结果：

|key|value|	
|---|---|
|1001|300|
|1002|294|
|1003|160|


通话记录例子2
```shell script
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1011", "billSeconds": 160, "cardNumber": "11842f91-59b0-4364-8744-f1bbfe5fbdb0"  }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1011", "billSeconds": 140, "cardNumber": "92b7d293-6b14-4cc7-b034-8f8e103b70d9"   }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1012", "billSeconds": 294, "cardNumber": "71944c95-776f-4cb6-b88f-2d7507257ba7"   }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1012", "billSeconds": 111, "cardNumber": "d8fa568a-8328-418c-aa17-b45e68f26953"   }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1013", "billSeconds": 78, "cardNumber": "9e8c231c-2d0d-4c77-9760-92a9e77aec88"   }'
```

将多个字段组合到value中的map
```map
function(doc) {    
  if(doc.phoneNumber && doc.cardNumber){
    emit(doc.phoneNumber, {billSeconds: doc.billSeconds, cardNumber: doc.cardNumber}); 
  }
}
```

得到结果：

|id|key|value|	
|---|---|---|
|592029f8e459a449c3c8b5417101cd09|1011|{ "billSeconds": 160, "cardNumber": "11842f91-59b0-4364-8744-f1bbfe5fbdb0" }	|
|592029f8e459a449c3c8b5417101d667|1011|{ "billSeconds": 140, "cardNumber": "92b7d293-6b14-4cc7-b034-8f8e103b70d9" }	|
|592029f8e459a449c3c8b5417101e5e9|1012|{ "billSeconds": 294, "cardNumber": "71944c95-776f-4cb6-b88f-2d7507257ba7" }	|
|592029f8e459a449c3c8b5417101ea5a|1012|{ "billSeconds": 111, "cardNumber": "d8fa568a-8328-418c-aa17-b45e68f26953" }	|
|592029f8e459a449c3c8b5417101f39e|1013|{ "billSeconds": 78, "cardNumber": "9e8c231c-2d0d-4c77-9760-92a9e77aec88" }	|

进行一个简单的reduce过程，reduce目标是：

```shell script
function (keys, values) {
    return values[0];
}
```

得到下面的结果：

|key|value|	
|---|---|
|1011|{ "billSeconds": 140, "cardNumber": "92b7d293-6b14-4cc7-b034-8f8e103b70d9" }|
|1012|{ "billSeconds": 111, "cardNumber": "d8fa568a-8328-418c-aa17-b45e68f26953" }|
|1013|{ "billSeconds": 78, "cardNumber": "9e8c231c-2d0d-4c77-9760-92a9e77aec88" }|



Reduce functions must handle two cases:

When rereduce is false:

keys is an array whose elements are arrays of the form [key, id], where key is a key that is emitted by the map function, and id identifies the document from which the key was generated.
values is an array of the values that are emitted for the respective elements in keys, for example: reduce([ [key1,id1], [key2,id2], [key3,id3] ], [value1,value2,value3], false).
When rereduce is true:

keys is null.
values is an array of the values that are returned by previous calls to the reduce function, for example: reduce(null, [intermediate1,intermediate2,intermediate3], true).


https://blog.pablobm.com/2019/07/18/map-reduce-with-couchdb-a-visual-primer.html
https://cloud.ibm.com/docs/Cloudant?topic=Cloudant-views-mapreduce
https://www.techfreak.net/2013/11/14/a-couchdb-view-example.html


https://www.jb51.cc/nosql/203421.html


https://docs.couchdb.org/en/stable/ddocs/views/intro.html


https://cloud.ibm.com/docs/Cloudant?topic=Cloudant-using-views

|Argument|Description|Optional|Type|Default|Supported values|Partition query|
|---|---|---|---|---|---|---|
|bookmark |	A bookmark to navigate to a specific page.|	Yes|	String|		| | | 	
|conflicts|	Can be set only if include_docs is true. Adds information about conflicts to each document.|	Yes|	Boolean|	False|	|	No|
|descending	|Return the documents in "descending by key" order.	|Yes	|Boolean	|False	|	|Yes|
|endkey	|Stop returning records when the specified key is reached.	|Yes	|String or JSON array|	|		|Yes|
|endkey_docid	|Stop returning records when the specified document ID is reached.	|Yes|	String	|	|	|Yes|
|group	|Using the reduce function, group the results to a group or single row.	|Yes|	Boolean|	False	|	|Yes|
|group_level |	Only applicable if the view uses complex keys: keys that are JSON arrays. Groups reduce results for the specified number of array fields.|	Yes	|Numeric	| | |		Yes|
|include_docs|	Include the full content of the documents in the response.	|Yes|	Boolean|	False	 | |	Yes|
|inclusive_end|	Include rows with the specified endkey.|	Yes|	Boolean |	True	| |  Yes |
|key	| Return only documents that match the specified key. Keys are JSON values, and must be URL encoded.|	Yes|	JSON strings or arrays |	|	| 	Yes|
| keys |	Return only documents that match the specified keys. Keys are JSON values, and must be URL encoded. |	Yes |	Array of JSON strings or arrays	|	| |	Yes |
|limit 1|	Limit the number of returned documents to the specified count.	| Yes |	Numeric	|	| |	Yes |
| page_size | 	Specify the number of returned documents in the result.	| Yes |	Numeric	    |   | |     |
| reduce |	Use the reduce function.	| Yes |	Boolean |	True	| |	Yes |
| skip |	Skip this number of rows from the start. |	Yes |	Numeric	| 0	 | | 	Yes |
| stable |	Prefer view results from a 'stable' set of shards. The results are from a view that is less likely to be updated soon. |	Yes |	Boolean |	False	| |	No |
| stale |	Allow the results from a stale view to be used. The request returns immediately, even if the view isn't built yet. If this parameter isn't specified, a response is returned only after the view is built. |	Yes |	String |	False	| |	No |
| startkey | Return records, starting with the specified key. |	Yes |	String or JSON array | | |			Yes |
| startkey_docid |	Return records, starting with the specified document ID. |	Yes |	String	| |	|	Yes |
| update |	Ensure that the view is updated before results are returned. | 	Yes |	String |	true |	Yes | |


### 参数解析

#### descending
view的显示结果是默认按照acsii升序进行排序的，如果使用?descending=true关键字，则会按照降序排列。

#### include_docs

请求的响应结果中获取整个文档，例子:

http://admin:password@192.168.16.70:5984/basic/_design/view1/_view/view_all?include_docs=true

在响应的结果中除了有key和value字段以外，还有doc字段，包含了整个doc的信息。

官方文档中这一段需要整理:

Warning

Do not emit the entire document as the value of your emit(key, value) statement unless you’re sure you know you want it. This stores an entire additional copy of your document in the view’s secondary index. Views with emit(key, doc) take longer to update, longer to write to disk, and consume significantly more disk space. The only advantage is that they are faster to query than using the ?include_docs=true parameter when querying a view.

Consider the trade-offs before emitting the entire document. Often it is sufficient to emit only a portion of the document, or just a single key / value pair, in your views.

#### key

查询对应指定key的数据，要求使用url编码。

比如查询Chongqing carrefour，通过url编码之后结果为:Chongqing+carrefour，编码的网站为: http://tool.chinaz.com/tools/urlencode.aspx

http://admin:password@192.168.16.70:5984/basic/_design/view1/_view/view_all?key="Chongqing+carrefour"

会发现查询结果中只有key匹配的数据


#### keys
类似于 sql查询中的in，keys用json数组的方式传递

http://admin:password@192.168.16.70:5984/basic/_design/view1/_view/view_all?keys=["Chongqing+carrefour","Beijing+carrefour"]

#### limit 
限制返回结果的条数

#### page_size
页码值，3.1以下版本的couchdb目测暂时不支持该值，需要进一步确认

#### skip
跳过从开始到skip指定值的记录，其实这就是分页查询中的start值。limit就是offset值。

























Preparing CouchDB nodes to be joined into a cluster
Before you can add nodes to form a cluster, you must have them listening on an IP address accessible from the other nodes in the cluster. You should also ensure that a few critical settings are identical across all nodes before joining them.

The settings we recommend you set now, before joining the nodes into a cluster, are:

etc/vm.args settings as described in the previous two sections
At least one server administrator user (and password)
Bind the node’s clustered interface (port 5984) to a reachable IP address
A consistent UUID. The UUID is used in identifying the cluster when replicating. If this value is not consistent across all nodes in the cluster, replications may be forced to rewind the changes feed to zero, leading to excessive memory, CPU and network use.
A consistent httpd secret. The secret is used in calculating and evaluating cookie and proxy authentication, and should be set consistently to avoid unnecessary repeated session cookie requests.




### couchdb环境准备
### map-reduce过程分析
### map-reduce参数分析
### map-reduce实践（水果店例子）
### couchdb单主机多节点实贱
### couchdb分区分片研究







































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

这里采用的是用Docker的方式安装，如果需要二进制的安装方式移步官方文档。

```dockerfile
docker run --name my-couchdb \
    -v /opt/local/containers/couchdb/data:/opt/couchdb/data \
    -v /opt/local/containers/couchdb/log/couch.log:/opt/couchdb/couch.log \
    -p 5984:5984 \
    -e COUCHDB_USER=admin \
    -e COUCHDB_PASSWORD=password \
    -d couchdb:3.0

sleep 5

curl localhost:5984
curl -X PUT http://admin:password@localhost:5984/_users
curl -X PUT http://admin:password@localhost:5984/_replicator
curl -X PUT http://admin:password@localhost:5984/_global_changes  
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

http://guide.couchdb.org/editions/1/en/index.html

https://callahan.io/blog/2016/06/04/debugging-couchdb-design-documents

https://blog.csdn.net/u012731379/article/details/79872120

https://github.com/apache/couchdb/issues/1354

// map-reduce process
https://blog.pablobm.com/2019/07/18/map-reduce-with-couchdb-a-visual-primer.html

http://www.srcmini.com/apache-couchdb/

### Design Document

A design document is a CouchDB document with an id that begins with _design/. For
instance, the example blog application, Sofa, is stored in a design document with the
ID _design/sofa (see Figure 5-1). Design documents are just like any other CouchDB
document—they replicate along with the other documents in their database and track
edit conflicts with the rev parameter.

Design Document 是CouchDB的一种标注报文格式，其URL以 _design/开头，并且携带一个ID

Design Document是一种标准的JSON格式。

首先调用下面的命令创建一个仓库：

```shell script
curl -X PUT http://admin:password@127.0.0.1:5984/basic
```

然后执行下面的命令提交view
```json
curl -X PUT http://admin:password@127.0.0.1:5984/basic/_design/example -d @js_examples/first.json
```

执行几次下面的命令，给basic这个仓库增加测试数据
```shell script
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{}'
```

然后执行下面的命令，调用刚才的view里面的查询函数foo，获取查询出来的数据
```
curl http://admin:password@localhost:5984/basic/_design/example/_view/foo
```

得到执行结果如下：

```shell script
{"total_rows":3,"offset":0,"rows":[
{"id":"592029f8e459a449c3c8b54171000cd3","key":"592029f8e459a449c3c8b54171000cd3","value":"1-967a00dff5e02add41819138abb3284d"},
{"id":"592029f8e459a449c3c8b54171001434","key":"592029f8e459a449c3c8b54171001434","value":"1-967a00dff5e02add41819138abb3284d"},
{"id":"592029f8e459a449c3c8b5417100209b","key":"592029f8e459a449c3c8b5417100209b","value":"1-967a00dff5e02add41819138abb3284d"}
]}
```

### View

```Javascript
function(doc) {
    if(doc.date && doc.title) {
        emit(doc.date, doc.title);
    }
}
```

view可以理解为是mysql中的view，也可以理解为是其他后台语言中的业务层代码，其实质目的都是用于将数据按照用户的要求查出。

view在用户查询的时候执行，会将数据进行整理、排序、筛选。最终按照用户要求的格式展示。

All map functions have a single parameter doc. This is a single document in the database.
Our map function checks whether our document has a date and a title attribute—
luckily, all of our documents have them—and then calls the built-in emit() function
with these two attributes as arguments.

所有的map函数都接受一个单参数doc，其是数据库中的一个文档，实例总的map函数检查了两个参数，一个是doc.date，一个是doc.title，均检查以上两个值是否存在。

The emit() function always takes two arguments: the first is key, and the second is
value. The emit(key, value) function creates an entry in our view result. One more
thing: the emit() function can be called multiple times in the map function to create
multiple entries in the view results from a single document, but we are not doing that
yet.

emit函数总是接受两个参数，第一个是键(key)，第二个是值(value)，此处传入的是doc.date和doc.title。emit函数会被调用多次。没调用一次，创建一行数据结果。

CouchDB takes whatever you pass into the emit() function and puts it into a list (see
Table 6-1). Each row in that list includes the key and value. More importantly, the list
is sorted by key (by doc.date in our case). The most important feature of a view result
is that it is sorted by key. We will come back to that over and over again to do neat
things. Stay tuned.

CouchDB 将emit中传入的参数放入一个列表中，然后列表中的每一行都由键值对组成，并且该列表是由键排序的？比如例子中的doc.data

马上来做个测试，写入几行数据，其中每行有 doc.data日期类型，然后按日期排序试试

执行几次下面的命令，给basic这个仓库增加测试数据
```shell script
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2019-01-01 14:02:11", "related_value":"Some content"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2020-04-01 08:12:24", "related_value":"Some content2"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2018-08-23 12:49:05", "related_value":"Some content3"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2020-08-16 04:35:12", "related_value":"Some content4"}'
```

创建一个view，文件名为view2.json
```shell script
{
  "_id": "_design/example",
  "views": {
    "view2": {
      "map": "function(doc){ if(doc.date && doc.title) { emit(doc.date, doc.title); } }"
    }
  }
}
```

提交上述的view
```json
curl -X PUT http://admin:password@127.0.0.1:5984/basic/_design/example -d @js_examples/view2.json
```


然后执行下面的命令，调用刚才的view里面的查询函数foo，获取查询出来的数据
```
curl http://admin:password@localhost:5984/basic/_design/example/_view/view2
```

// 在做一个测试，看看是否会带出更多的数据
执行几次下面的命令，给basic这个仓库增加测试数据
```shell script
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2019-01-01 14:02:11", "related_value":"Some content", "related_person":"Jimmy wang"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2020-04-01 08:12:24", "related_value":"Some content2"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2018-08-23 12:49:05", "related_value":"Some content3"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2020-08-16 04:35:12", "related_value":"Some content4"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2017-01-22 07:29:04", "related_value":"Some content5"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_date":"2020-06-14 01:28:11", "related_value":"Some content6", "related_person":"Kelly Zuo"}'
```

经过测试证明，view会带出整个文档，只是在reduce过程中会选用指定的值进行reduct


用下面的命令可以进行key的范围查询，注意字母大小写敏感，一旦写错会失效
```shell script
http://admin:password@192.168.16.70:5984/basic/_design/example/_view/view2?startkey="2018-08-23 12:49:05"&endkey="2022-08-23 12:49:05"
```

增加测试数据如下：

```shell script
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_key":"a", "sample_value":1, "related_person":"Kelly Zuo"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_key":"a", "sample_value":"6", "related_person":"Tom Jacky"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_key":"b", "sample_value":"55", "related_person":"Naomi Sandy"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_key":"b", "sample_value":189, "related_person":"Naomi Sandy"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_key":"b", "sample_value":67, "related_person":"Naomi Sandy"}'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"create_key":"c", "sample_value":5, "related_person":"Kelly Zuo"}'
```



水果的map函数
```shell script
function(doc) {
    var shop, price;
    if (doc.item && doc.prices) {
        doc.prices.forEach(function(i) {
              emit(doc.item, i);
        });
    }
}
```


通话记录例子

```shell script
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1001", "billSeconds": 180  }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1001", "billSeconds": 120  }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1002", "billSeconds": 214  }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1002", "billSeconds": 80  }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1003", "billSeconds": 160  }'
```

基于上面的例子，构造map函数

```map
function(doc) {
    if (doc.phoneNumber && doc.billSeconds) {
        emit(doc.phoneNumber, doc.billSeconds);
    }
}
```

再构造reduce函数
```reduce
function(keys, values) {
    return sum(values);
}
```

得到结果：

|key|value|	
|---|---|
|1001|300|
|1002|294|
|1003|160|


通话记录例子2
```shell script
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1011", "billSeconds": 160, "cardNumber": "11842f91-59b0-4364-8744-f1bbfe5fbdb0"  }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1011", "billSeconds": 140, "cardNumber": "92b7d293-6b14-4cc7-b034-8f8e103b70d9"   }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1012", "billSeconds": 294, "cardNumber": "71944c95-776f-4cb6-b88f-2d7507257ba7"   }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1012", "billSeconds": 111, "cardNumber": "d8fa568a-8328-418c-aa17-b45e68f26953"   }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"phoneNumber":"1013", "billSeconds": 78, "cardNumber": "9e8c231c-2d0d-4c77-9760-92a9e77aec88"   }'
```

将多个字段组合到value中的map
```map
function(doc) {    
  if(doc.phoneNumber && doc.cardNumber){
    emit(doc.phoneNumber, {billSeconds: doc.billSeconds, cardNumber: doc.cardNumber}); 
  }
}
```

得到结果：

|id|key|value|	
|---|---|---|
|592029f8e459a449c3c8b5417101cd09|1011|{ "billSeconds": 160, "cardNumber": "11842f91-59b0-4364-8744-f1bbfe5fbdb0" }	|
|592029f8e459a449c3c8b5417101d667|1011|{ "billSeconds": 140, "cardNumber": "92b7d293-6b14-4cc7-b034-8f8e103b70d9" }	|
|592029f8e459a449c3c8b5417101e5e9|1012|{ "billSeconds": 294, "cardNumber": "71944c95-776f-4cb6-b88f-2d7507257ba7" }	|
|592029f8e459a449c3c8b5417101ea5a|1012|{ "billSeconds": 111, "cardNumber": "d8fa568a-8328-418c-aa17-b45e68f26953" }	|
|592029f8e459a449c3c8b5417101f39e|1013|{ "billSeconds": 78, "cardNumber": "9e8c231c-2d0d-4c77-9760-92a9e77aec88" }	|

进行一个简单的reduce过程，reduce目标是：

```shell script
function (keys, values) {
    return values[0];
}
```

得到下面的结果：

|key|value|	
|---|---|
|1011|{ "billSeconds": 140, "cardNumber": "92b7d293-6b14-4cc7-b034-8f8e103b70d9" }|
|1012|{ "billSeconds": 111, "cardNumber": "d8fa568a-8328-418c-aa17-b45e68f26953" }|
|1013|{ "billSeconds": 78, "cardNumber": "9e8c231c-2d0d-4c77-9760-92a9e77aec88" }|



Reduce functions must handle two cases:

When rereduce is false:

keys is an array whose elements are arrays of the form [key, id], where key is a key that is emitted by the map function, and id identifies the document from which the key was generated.
values is an array of the values that are emitted for the respective elements in keys, for example: reduce([ [key1,id1], [key2,id2], [key3,id3] ], [value1,value2,value3], false).
When rereduce is true:

keys is null.
values is an array of the values that are returned by previous calls to the reduce function, for example: reduce(null, [intermediate1,intermediate2,intermediate3], true).


https://blog.pablobm.com/2019/07/18/map-reduce-with-couchdb-a-visual-primer.html
https://cloud.ibm.com/docs/Cloudant?topic=Cloudant-views-mapreduce
https://www.techfreak.net/2013/11/14/a-couchdb-view-example.html


https://www.jb51.cc/nosql/203421.html


https://docs.couchdb.org/en/stable/ddocs/views/intro.html


https://cloud.ibm.com/docs/Cloudant?topic=Cloudant-using-views

|Argument|Description|Optional|Type|Default|Supported values|Partition query|
|---|---|---|---|---|---|---|
|bookmark |	A bookmark to navigate to a specific page.|	Yes|	String|		| | | 	
|conflicts|	Can be set only if include_docs is true. Adds information about conflicts to each document.|	Yes|	Boolean|	False|	|	No|
|descending	|Return the documents in "descending by key" order.	|Yes	|Boolean	|False	|	|Yes|
|endkey	|Stop returning records when the specified key is reached.	|Yes	|String or JSON array|	|		|Yes|
|endkey_docid	|Stop returning records when the specified document ID is reached.	|Yes|	String	|	|	|Yes|
|group	|Using the reduce function, group the results to a group or single row.	|Yes|	Boolean|	False	|	|Yes|
|group_level |	Only applicable if the view uses complex keys: keys that are JSON arrays. Groups reduce results for the specified number of array fields.|	Yes	|Numeric	| | |		Yes|
|include_docs|	Include the full content of the documents in the response.	|Yes|	Boolean|	False	 | |	Yes|
|inclusive_end|	Include rows with the specified endkey.|	Yes|	Boolean |	True	| |  Yes |
|key	| Return only documents that match the specified key. Keys are JSON values, and must be URL encoded.|	Yes|	JSON strings or arrays |	|	| 	Yes|
| keys |	Return only documents that match the specified keys. Keys are JSON values, and must be URL encoded. |	Yes |	Array of JSON strings or arrays	|	| |	Yes |
|limit 1|	Limit the number of returned documents to the specified count.	| Yes |	Numeric	|	| |	Yes |
| page_size | 	Specify the number of returned documents in the result.	| Yes |	Numeric	    |   | |     |
| reduce |	Use the reduce function.	| Yes |	Boolean |	True	| |	Yes |
| skip |	Skip this number of rows from the start. |	Yes |	Numeric	| 0	 | | 	Yes |
| stable |	Prefer view results from a 'stable' set of shards. The results are from a view that is less likely to be updated soon. |	Yes |	Boolean |	False	| |	No |
| stale |	Allow the results from a stale view to be used. The request returns immediately, even if the view isn't built yet. If this parameter isn't specified, a response is returned only after the view is built. |	Yes |	String |	False	| |	No |
| startkey | Return records, starting with the specified key. |	Yes |	String or JSON array | | |			Yes |
| startkey_docid |	Return records, starting with the specified document ID. |	Yes |	String	| |	|	Yes |
| update |	Ensure that the view is updated before results are returned. | 	Yes |	String |	true |	Yes | |


### 参数解析

#### descending
view的显示结果是默认按照acsii升序进行排序的，如果使用?descending=true关键字，则会按照降序排列。

#### include_docs

请求的响应结果中获取整个文档，例子:

http://admin:password@192.168.16.70:5984/basic/_design/view1/_view/view_all?include_docs=true

在响应的结果中除了有key和value字段以外，还有doc字段，包含了整个doc的信息。

官方文档中这一段需要整理:

Warning

Do not emit the entire document as the value of your emit(key, value) statement unless you’re sure you know you want it. This stores an entire additional copy of your document in the view’s secondary index. Views with emit(key, doc) take longer to update, longer to write to disk, and consume significantly more disk space. The only advantage is that they are faster to query than using the ?include_docs=true parameter when querying a view.

Consider the trade-offs before emitting the entire document. Often it is sufficient to emit only a portion of the document, or just a single key / value pair, in your views.

#### key

查询对应指定key的数据，要求使用url编码。

比如查询Chongqing carrefour，通过url编码之后结果为:Chongqing+carrefour，编码的网站为: http://tool.chinaz.com/tools/urlencode.aspx

http://admin:password@192.168.16.70:5984/basic/_design/view1/_view/view_all?key="Chongqing+carrefour"

会发现查询结果中只有key匹配的数据


#### keys
类似于 sql查询中的in，keys用json数组的方式传递

http://admin:password@192.168.16.70:5984/basic/_design/view1/_view/view_all?keys=["Chongqing+carrefour","Beijing+carrefour"]

#### limit
限制返回结果的条数

#### page_size
页码值，3.1以下版本的couchdb目测暂时不支持该值，需要进一步确认

#### skip
跳过从开始到skip指定值的记录，其实这就是分页查询中的start值。limit就是offset值。
























