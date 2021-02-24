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

创建下面的三个数据库。
```shell
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X PUT http://localhost:5984/_users
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X PUT http://localhost:5984/_replicator
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X PUT http://localhost:5984/_global_changes
```

### 创建数据库
```shell
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X PUT http://localhost:5984/sample-db?q=3&n=1
```

其中，q是该数据库的分片数量，n副本数量。因为我们是在一个单机版的couchdb上进行试验，所以n的值设大是没有意义的，系统会强制数据库的副本为1，也就是n值无论设置为多少在单机版的系统中均会被忽略。

### 分析刚才创建的数据库
https://docs.couchdb.org/en/stable/cluster/sharding.html#examining-database-shards

```shell
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X GET http://localhost:5984/sample-db | jq
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

### 可以查看一条数据的分片情况
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

### 编写view对数据进行map操作

在couchdb中，通过javascript语法编写的map函数，将数据库中得数据进行map，然后输出成需要的结果。这个过程类似mysql类型的关系数据库的sql操作。

此时通过Fauxton工具配置view, 其实也可以选用curl工具利用couchdb的api进行配置，但是因为map函数为多行，如果合并成一行放到curl命令中可读性会比较差，并且合并过程也有一定的难度，因此使用Fauxton工具在线生成。

操作方式：Design Documents > +号 > New View

其中design名称此处取为year-month-day，Index Name就为view1

```javascript
function (document) {
    const [year, month, day] = document.create_date.split("-");
    emit([year, month, day], document.person_name);
}
```

请求该view
```shell
curl -H "Content-Type:application/json" \
-H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" \
-X GET http://localhost:5984/sample-db/_design/year-month-day/_view/view1?reduce=false| jq
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
      "value": "Wang Si Cong"
    },
    {
      "id": "6",
      "key": [
        "2017",
        "01",
        "22"
      ],
      "value": "Song Xiao Feng"
    },
    {
      "id": "3",
      "key": [
        "2018",
        "08",
        "23"
      ],
      "value": "Li Xiao Ming"
    },
    {
      "id": "1",
      "key": [
        "2019",
        "01",
        "01"
      ],
      "value": "Jimmy Wang"
    },
    {
      "id": "8",
      "key": [
        "2019",
        "01",
        "09"
      ],
      "value": "Fan Li Li"
    },
    {
      "id": "7",
      "key": [
        "2019",
        "01",
        "12"
      ],
      "value": "He Xu Hua"
    },
    {
      "id": "2",
      "key": [
        "2020",
        "04",
        "01"
      ],
      "value": "Kelly Zhang"
    },
    {
      "id": "4",
      "key": [
        "2020",
        "08",
        "16"
      ],
      "value": "Zhang hong"
    }
  ]
}
```
可以看到，通过map函数，我们将数据按照我们需要的结果进行了映射输出

### 利用reduce函数对数据进行分析

#### 任务1. 以年为分组，统计当年注册的用户数量
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

上述结果表明每一年对应的注册人。

如果使用下面的命令进行分组，命令中相比上一次执行的命令唯一差别是将group_level值改成了2，表明使用map输出key的前两个字段（年和月）进行分组。
```shell
curl -H "Content-Type:application/json" \
-H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" \
-X GET http://localhost:5984/sample-db/_design/year-month-day/_view/view1?group_level=2 | jq
```

可以看到输出结果如下，表明某年某月注册的人数，比如2017年1月，有两个人注册。
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
        return values.length;
    }
}
```

然后分别调用group_level为1和2的请求，也均能得到和上面的请求一样的结果。

但是reduce函数的写法让人有些迷惑，尤其是函数中有rereduce这个参数。另外两个参数keys和values比较好理解，可以理解是map函数的输出。但是这个rereduce就比较难以理解了。

试着在Fauxton中将reduce函数修改成下面:
```javascript
function (keys, values) {
        return values.length;
}
```

```javascript
function (keys, values) {
    
    
        let temp = '';
        if(Array.isArray(values)){
            for(j = 0,len=values.length; j < len; j++) {
               temp = temp + values[j] + '|'
            }
        } else {
            temp = values;
        }         

        return temp;
}
```

然后调用group_level=1的请求，会得到下面的结果：
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
      "value": 2
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
会发现该统计结果是有问题的，因为2019年的注册用户有三位，此处的统计的结果值为2。

为了分析这个问题，此处进一步修改reduce函数为下面的样子：
```javascript
function (keys, values) {
        return values;
}
```
相当于对map输出的结果不进行任何处理，直接输出，会发现输出结果如下：
```json
{
  "rows": [
    {
      "key": [
        "2017"
      ],
      "value": [
        [
          "Wang Si Cong"
        ],
        [
          "Song Xiao Feng"
        ]
      ]
    },
    {
      "key": [
        "2018"
      ],
      "value": [
        [
          "Li Xiao Ming"
        ]
      ]
    },
    {
      "key": [
        "2019"
      ],
      "value": [
        [
          "He Xu Hua",
          "Jimmy Wang"
        ],
        [
          "Fan Li Li"
        ]
      ]
    },
    {
      "key": [
        "2020"
      ],
      "value": [
        [
          "Kelly Zhang"
        ],
        [
          "Zhang hong"
        ]
      ]
    }
  ]
}
```

分析上面的输出结果，发现2019年度注册的用户中，三位用户的名字均正确输出，但是用户名的数组结构比较奇怪，有两位用户被放到了同一个数组单元中，这样三个用户构成的数组长度就是2，也就不难解释为什么上面的reduce函数中使用return values.length方式统计注册用户数会出现和预期不一样的情况了。


在处理过程中，首先由map函数对所有的行进行映射处理，输出的结果为两个值：key和value，然后会作为reduce函数的输入，reduce函数的入参默认为是keys, values, rereduce三个参数，但当第一次处理map函数给出的结果（key, value）时，无论map所返回的key和value是什么样的数据结果，比如json或者数组，reduce函数均会作为**长度为1的数组**进行处理：将map函数所输出的key作为reduce函数的keys[0]，相应的，会将map函数所输出的value作为values[0]，rereduce值为false。在处理过程中，会根据group_level值进行分组操作，但是因为couchdb的分布式特性，同一个分组（比如年代2019）可能存在在不同的数据节点中，其所有的孩子节点在reduce处理之后，会合并成新的 keys, values, rereduce值（为true）由reduce函数继续进行循环处理，此时的keys数组长度则可能是大于1的数组，最终该过程会一直循环直到结束。

因此在reduce的过程中，除了对叶子节点的处理以外，在对其他内部节点进行处理的时候，values可能为不规则的多维数组。

这就要求了reduce函数中，要根据rereduce值判断当前处理的情况和阶段并对数据进行合理的处理，以便最终输出正确的结果。








couchdb的数据存储是分布式存储结构，同一个父亲节点下面，有多个叶子节点，当使用某种规则，比如上面的年代分组，则同为2019年的多行数据，分布在分布式结构中。其中可能有多行数据有共同的父亲节点。reduce函数在处理完这些叶子节点之后，会将结果以数组的不同单元的方式合并，形成新的入参（values），再次由reduce函数进行处理，此时的rereduce参数值则为true。


造成这一问题的根本原因是，couchdb的reduce过程，是一个循环处理的过程，这和couchdb的分布式结构有关。reduce首先会在不同的节点进行处理，数据库sample-db定义了三个分片（节点），2019年注册的三个用户分别分散在两个不同的分片中。在处理方式为return values 的reduce函数中，没有对map函数的结果（reduce的输入）进行过多的计算和统计，只是直接返回，但是对于不同的分片节点，reduce函数的初次处理会首先将处理结果进行合并，然后在重新整理的过程中进行再次处理（rereduce），因此reduce函数会在其中一个节点把两个2019年的注册用户合并到同一个value中，然后在rereduce过程中再次处理，就形成了下面的入参结构：
节点1的输出结果：
```javascript
key:2019, values:[节点一的处理结果合并结果]
```

节点2的输出结果：
```javascript
key:2019, values:[节点二的处理结果合并结果]
```

然后把节点1和节点2的处理结果合并成新的reduce过程的入参，此时rereduce参数为true，然后统计相应的结果。这也就解释了为什么在reduce函数中忽略掉rereduce参数，方法体中直接返回return values.length的结果，会得到不正确的结果的原因。

首先

### 官方文档

这里比较难以理解的，是reduce函数中rereduce参数的概念。官方文档解释如下：

When run on leaf nodes (which contain actual map rows), the reduce function’s third parameter, rereduce, is false. The arguments in this case are the keys and values as output by the map function. The function has a single returned reduction value, which is stored on the inner node that a working set of leaf nodes have in common, and is used as a cache in future reduce calculations.

当reduce函数执行到叶子节点的时候，reduce函数中的第三个参数rereduce为false，然后keys和values值，是map函数的输出值。此时该函数会有一个单返回值，保存在该叶子节点的父亲节点中，作为后续的reduce函数继续计算所需要的值。

When the reduce function is run on inner nodes, the rereduce flag is true. This allows the function to account for the fact that it will be receiving its own prior output. When rereduce is true, the values passed to the function are intermediate reduction values as cached from previous calculations. When the tree is more than two levels deep, the rereduce phase is repeated, consuming chunks of the previous level’s output until the final reduce value is calculated at the root node.

当reduce函数执行到非叶子节点时，rereduce参数为true，将对之前在叶子节点上的计算结果进行重新计算。此时传入reduce函数中的另外两个参数为之前在叶子节点中结算的结果值。当该树的深度超过两层时，rereduce过程一直重复执行，直到达到根节点。

A common mistake new CouchDB users make is attempting to construct complex aggregate values with a reduce function. Full reductions should result in a scalar value, like 5, and not, for instance, a JSON hash with a set of unique keys and the count of each. The problem with this approach is that you’ll end up with a very large final value. The number of unique keys can be nearly as large as the number of total keys, even for a large set. It is fine to combine a few scalar calculations into one reduce function; for instance, to find the total, average, and standard deviation of a set of numbers in a single function.

If you’re interested in pushing the edge of CouchDB’s incremental reduce functionality, have a look at Google’s paper on Sawzall, which gives examples of some of the more exotic reductions that can be accomplished in a system with similar constraints.


