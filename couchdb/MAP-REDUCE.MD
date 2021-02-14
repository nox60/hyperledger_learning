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
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X PUT http://192.168.88.128:5984/sample-db?q=3&n=1
```

其中，q是该数据库的分片数量，n副本数量。因为我们是在一个单机版的couchdb上进行试验，所以n的值设大是没有意义的，系统会强制数据库的副本为1，也就是n值无论设置为多少在单机版的系统中均会被忽略。

### 分析刚才创建的数据库
https://docs.couchdb.org/en/stable/cluster/sharding.html#examining-database-shards

```shell
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X GET http://192.168.88.128:5984/sample-db | jq
```

```json
{
  "db_name": "sample-db",
  "purge_seq": "0-g1AAAACZeJzLYWBgYM5gTmGQTM4vTc5ISXLIrdSDMvWKM_PSc1JzgEqY8lgYVgEBkPoPBFmJDEToSQoFAqCOlUCNxOlIZADpCQEqzgIAUR4yxg",
  "update_seq": "0-g1AAAACZeJzLYWBgYM5gTmGQTM4vTc5ISXLIrdSDMvWKM_PSc1JzgEqY8lgYVgEBkPoPBFmJDEToSQoFAqCOlUCNxOlIZADpCQEqzgIAUR4yxg",
  "sizes": {
    "file": 25074,
    "external": 0,
    "active": 0
  },
  "props": {},
  "doc_del_count": 0,
  "doc_count": 0,
  "disk_format_version": 8,
  "compact_running": false,
  "cluster": {
    "q": 3,
    "n": 1,
    "w": 1,
    "r": 1
  },
  "instance_start_time": "0"
}
```

### 写入数据

```shell script
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/sample-db -d '{"_id":"1", "create_date":"2019-01-01", "person_name":"Jimmy Wang"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/sample-db -d '{"_id":"2", "create_date":"2020-04-01", "person_name":"Kelly Zhang"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/sample-db -d '{"_id":"3", "create_date":"2018-08-23", "person_name":"Li Xiao Ming"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/sample-db -d '{"_id":"4", "create_date":"2020-08-16", "person_name":"Zhang hong"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/sample-db -d '{"_id":"5", "create_date":"2017-01-22", "person_name":"Wang Si Cong"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/sample-db -d '{"_id":"6", "create_date":"2017-01-22", "person_name":"Song Xiao Feng"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/sample-db -d '{"_id":"7", "create_date":"2019-01-12", "person_name":"He Xu Hua"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/sample-db -d '{"_id":"8", "create_date":"2019-01-09", "person_name":"Fan Li Li"}'
```

### 查看sample-db数据库的分片情况
```shell
curl -H "Content-Type:application/json" \
-H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" \
-X GET http://localhost:5984/sample-db/_shards | jq .
```

可以看到三个分片的情况如下：
```json
{
  "shards": {
    "00000000-55555554": [
      "couchdb@my.couchdb.single"
    ],
    "55555555-aaaaaaa9": [
      "couchdb@my.couchdb.single"
    ],
    "aaaaaaaa-ffffffff": [
      "couchdb@my.couchdb.single"
    ]
  }
}
```

### 查看刚才写入的数据
```shell
curl -H "Content-Type:application/json" \
-H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" \
-X GET http://localhost:5984/sample-db/_shards/1  | jq
```

结果如下所示，代表该行数据的所在分片信息：
```json
{
  "range": "80000000-bfffffff",
  "nodes": [
    "couchdb@my.couchdb.single"
  ]
}
```

此时通过Fauxton工具配置一个view, 其实也可以选用curl工具利用couchdb的api进行配置，但是因为map函数为多行，合并成一行到curl命令中，可读性较差，也具备一定的合并难度，因此使用Fauxton工具在线生成。
```javascript
function (document) {
  const [year, month, day] = document.create_date.split("-");
  emit([year, month, day], 1);
}
```

请求该view
```shell
curl -H "Content-Type:application/json" \
-H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" \
-X GET http://localhost:5984/sample-db/_design/year-month-day/_view/view1 | jq
```

结果如下：
```json
{
  "total_rows": 8,
  "offset": 0,
  "rows": [
    {
      "id": "5",
      "key": [
        "2017",
        "01",
        "22"
      ],
      "value": 1
    },
    {
      "id": "6",
      "key": [
        "2017",
        "01",
        "22"
      ],
      "value": 1
    },
    {
      "id": "3",
      "key": [
        "2018",
        "08",
        "23"
      ],
      "value": 1
    },
    {
      "id": "1",
      "key": [
        "2019",
        "01",
        "01"
      ],
      "value": 1
    },
    {
      "id": "8",
      "key": [
        "2019",
        "01",
        "09"
      ],
      "value": 1
    },
    {
      "id": "7",
      "key": [
        "2019",
        "01",
        "12"
      ],
      "value": 1
    },
    {
      "id": "2",
      "key": [
        "2020",
        "04",
        "01"
      ],
      "value": 1
    },
    {
      "id": "4",
      "key": [
        "2020",
        "08",
        "16"
      ],
      "value": 1
    }
  ]
}

```

### 给该view加上reduce函数
直接在系统中选择_count reduce函数，然后使用下面的命令请求该view。其中group_level参数代表使用map输出的key中的第一个字段（年）进行数据分组。
```shell
curl -H "Content-Type:application/json" \
-H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" \
-X GET http://localhost:5984/sample-db/_design/year-month-day/_view/view1?group_level=1 | jq
```

结果如下：
```json
{
  "rows": [
    {
      "key": [
        "2017"
      ],
      "value": 2
    },
    {
      "key": [
        "2018"
      ],
      "value": 1
    },
    {
      "key": [
        "2019"
      ],
      "value": 3
    },
    {
      "key": [
        "2020"
      ],
      "value": 2
    }
  ]
}
```

上述结果表明每一年对应的出生数。

如果使用下面的命令进行分组，命令中和上面的唯一差别是将group_level值改成了2，表明使用map输出key的前两个字段（年和月）进行分组。
```shell
curl -H "Content-Type:application/json" \
-H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" \
-X GET http://localhost:5984/sample-db/_design/year-month-day/_view/view1?group_level=2 | jq
```

可以看到输出结果如下，表明某年某月出生的人数，比如2017年1月，有两个人出生。
```json
{
  "rows": [
    {
      "key": [
        "2017",
        "01"
      ],
      "value": 2
    },
    {
      "key": [
        "2018",
        "08"
      ],
      "value": 1
    },
    {
      "key": [
        "2019",
        "01"
      ],
      "value": 3
    },
    {
      "key": [
        "2020",
        "04"
      ],
      "value": 1
    },
    {
      "key": [
        "2020",
        "08"
      ],
      "value": 1
    }
  ]
}
```

上述统计因为业务逻辑比较简单，可以用系统自带的_count reduce函数进行统计。同时，也可以使用自定义的reduce函数进行统计，写法如下：
```javascript
function (keys, values, rereduce) {
  if (rereduce) {
    return sum(values);
  } else {
    return sum(values);
  }
}
```

然后分别调用group_level为1和2的请求，也均能得到和上面的请求一样的结果。

这里比较难以理解的，是reduce函数中rereduce参数的概念。官方文档解释如下：

When run on leaf nodes (which contain actual map rows), the reduce function’s third parameter, rereduce, is false. The arguments in this case are the keys and values as output by the map function. The function has a single returned reduction value, which is stored on the inner node that a working set of leaf nodes have in common, and is used as a cache in future reduce calculations.

当reduce函数执行到叶子节点的时候，reduce函数中的第三个参数rereduce为false，然后keys和values值，是map函数的输出值。此时该函数会有一个单返回值，保存在该叶子节点的父亲节点中，作为后续的reduce函数继续计算所需要的值。

When the reduce function is run on inner nodes, the rereduce flag is true. This allows the function to account for the fact that it will be receiving its own prior output. When rereduce is true, the values passed to the function are intermediate reduction values as cached from previous calculations. When the tree is more than two levels deep, the rereduce phase is repeated, consuming chunks of the previous level’s output until the final reduce value is calculated at the root node.

当reduce函数执行到非叶子节点时，rereduce参数为true，将对之前在叶子节点上的计算结果进行重新计算。此时传入reduce函数中的另外两个参数为之前在叶子节点中结算的结果值。当该树的深度超过两层时，rereduce过程一直重复执行，直到达到根节点。

A common mistake new CouchDB users make is attempting to construct complex aggregate values with a reduce function. Full reductions should result in a scalar value, like 5, and not, for instance, a JSON hash with a set of unique keys and the count of each. The problem with this approach is that you’ll end up with a very large final value. The number of unique keys can be nearly as large as the number of total keys, even for a large set. It is fine to combine a few scalar calculations into one reduce function; for instance, to find the total, average, and standard deviation of a set of numbers in a single function.

If you’re interested in pushing the edge of CouchDB’s incremental reduce functionality, have a look at Google’s paper on Sawzall, which gives examples of some of the more exotic reductions that can be accomplished in a system with similar constraints.


### 官方文档



### 芒果，西瓜，苹果，菠萝在多家水果店有售，找到每个水果最低的单价

### 某平台销售多个品牌的电脑，计算每个月，每个品牌的销售总价