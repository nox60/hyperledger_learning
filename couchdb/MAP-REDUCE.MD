## 创建单机库

### 拉起容器
```shell
docker rm -f my.couchdb.single

docker run --name my.couchdb.single \
   -p 5984:5984 \
   -p 9100-9200:9100-9200 \
   -e NODENAME=my.couchdb.single \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -e ERL_FLAGS='-setcookie "brumbrum" -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9200' \
   -d couchdb:3.0
```

### 请求头进行密码验证

### jq格式化工具

### 初始化

```shell
http://192.168.88.128:5984/_users
http://192.168.88.128:5984/_replicator
http://192.168.88.128:5984/_global_changes
```

### 创建数据库

```shell
http://192.168.88.128:5984/sample-db?q=4&n=2
```

其中，q是分片数量，n副本数量

### 分析刚才创建的数据库
https://docs.couchdb.org/en/stable/cluster/sharding.html#examining-database-shards

```shell
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X GET http://192.168.88.128:5984/sample-db
```

```json
{
    "db_name": "sample-db",
    "purge_seq": "0-g1AAAADLeJzLYWBgYMlgTmGQTM4vTc5ISXLIrdSDMvWKM_PSc1JzgEqY8liAJMMBIPUfCLISGYjW0wDRs584PUkOQDKpnmg7EhmS7CGKswDJ3ENu",
    "update_seq": "0-g1AAAADLeJzLYWBgYMlgTmGQTM4vTc5ISXLIrdSDMvWKM_PSc1JzgEqY8liAJMMBIPUfCLISGYjW0wDRs584PUkOQDKpnmg7EhmS7CGKswDJ3ENu",
    "sizes": {
        "file": 33432,
        "external": 0,
        "active": 0
    },
    "props": {},
    "doc_del_count": 0,
    "doc_count": 0,
    "disk_format_version": 8,
    "compact_running": false,
    "cluster": {
        "q": 4,
        "n": 1,
        "w": 1,
        "r": 1
    },
    "instance_start_time": "0"
}
```

会发现因为是单机，n是无法调高的，只能为1

### 写入数据

```shell script
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/sample-db -d '{"id":"1", "create_date":"2019-01-01 14:02:11", "related_value":"Some content", "related_person":"Jimmy wang"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/sample-db -d '{"id":"2", "create_date":"2020-04-01 08:12:24", "related_value":"Some content2"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/sample-db -d '{"id":"3", "create_date":"2018-08-23 12:49:05", "related_value":"Some content3"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/sample-db -d '{"id":"4", "create_date":"2020-08-16 04:35:12", "related_value":"Some content4"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/sample-db -d '{"id":"5", "create_date":"2017-01-22 07:29:04", "related_value":"Some content5"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/sample-db -d '{"id":"6", "create_date":"2020-06-14 01:28:11", "related_value":"Some content6", "related_person":"Kelly Zuo"}'
```

### 查看刚才写入的数据

```shell
curl -H "Content-Type:application/json" \
-H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" \
-X GET http://localhost:5984/sample-db/_shards/1  | jq
```

结果
```json
{
  "range": "80000000-bfffffff",
  "nodes": [
    "couchdb@my.couchdb.single"
  ]
}
```

配置view, 利用Fauxton配置
```javascript
function (document) {
  const [date, time] = document.create_date.split(" ");
  const [year, month, day] = date.split("-");
  emit([year, month, day], 1);
}
```

请求该view
```shell
curl -H "Content-Type:application/json" \
-H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" \
-X GET http://localhost:5984/sample-db/_design/year-month-day/_view/new-view?group_level=2 | jq
```

























### 官方文档

When run on leaf nodes (which contain actual map rows), the reduce function’s third parameter, rereduce, is false. The arguments in this case are the keys and values as output by the map function. The function has a single returned reduction value, which is stored on the inner node that a working set of leaf nodes have in common, and is used as a cache in future reduce calculations.

When the reduce function is run on inner nodes, the rereduce flag is true. This allows the function to account for the fact that it will be receiving its own prior output. When rereduce is true, the values passed to the function are intermediate reduction values as cached from previous calculations. When the tree is more than two levels deep, the rereduce phase is repeated, consuming chunks of the previous level’s output until the final reduce value is calculated at the root node.

A common mistake new CouchDB users make is attempting to construct complex aggregate values with a reduce function. Full reductions should result in a scalar value, like 5, and not, for instance, a JSON hash with a set of unique keys and the count of each. The problem with this approach is that you’ll end up with a very large final value. The number of unique keys can be nearly as large as the number of total keys, even for a large set. It is fine to combine a few scalar calculations into one reduce function; for instance, to find the total, average, and standard deviation of a set of numbers in a single function.

If you’re interested in pushing the edge of CouchDB’s incremental reduce functionality, have a look at Google’s paper on Sawzall, which gives examples of some of the more exotic reductions that can be accomplished in a system with similar constraints.