### local document
The Local (non-replicating) document interface allows you to create local documents that are not replicated to other databases. These documents can be used to hold configuration or other information that is required specifically on the local CouchDB instance.

local document 允许创建不会被其他数据库备份的文档。这种文档一般用于保存当前环境的配置信息（同步到其他机器可能不太合适）

#### 测试例子
##### 节点创建、
使用下面的脚本创建三个节点

```shell script
docker network rm k-network
docker network create k-network

docker rm -f my.couchdb1
docker rm -f my.couchdb2
docker rm -f my.couchdb3

docker run --name my.couchdb1 \
   --network=k-network \
   -p 5984:5984 \
   -p 9100-9200:9100-9200 \
   -e NODENAME=my.couchdb1 \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -e ERL_FLAGS='-setcookie "brumbrum" -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9200' \
   -d couchdb:3.0
   
docker run --name my.couchdb2 \
   --network=k-network \
   -p 5985:5984 \
   -p 9300-9400:9300-9400 \
   -e NODENAME=my.couchdb2 \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -e ERL_FLAGS='-setcookie "brumbrum2" -kernel inet_dist_listen_min 9300 -kernel inet_dist_listen_max 9400' \
   -d couchdb:3.0
   
docker run --name my.couchdb3 \
   --network=k-network \
   -p 5986:5984 \
   -p 9500-9600:9500-9600 \
   -e NODENAME=my.couchdb3 \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -e ERL_FLAGS='-setcookie "brumbrum3" -kernel inet_dist_listen_min 9500 -kernel inet_dist_listen_max 9600' \
   -d couchdb:3.0   
```

以上脚本会创建三个节点my.couchdb1, my.couchdb2, my.couchdb3。

##### 集群创建

###### 使用Fauxton进行配置

通过下面的地址登陆访问Fauxton，其中前面的ip地址是服务器ip地址。

```shell script
http://192.168.16.70:5984/_utils
```

进入界面之后点击右侧的扳手按钮，进入setup界面，选择Configure a Cluster。

首先在Specify your Admin credentials下面的输入框中填写用户名和密码，根据前面初始化脚本中配置的相关信息，此处填入用户名admin，密码password，然后在界面下方的Add Nodes to the Cluster，在Remote host中先填my.couchdb2，然后点击Add Node，此时会看到my.couchdb2:5984会出现在界面最下方。然后在Remote host中填写my.couchdb3,再次点击Add Node，会看到my.couchdb3:5984排列加入到列表中，出现在my.couchdb2:5984的下方。

点击Configure Cluster，完成节点配置。

利用POSTMAN或者CRUL工具，通过下面的api查询集群情况：

```shell script
http://127.0.0.1:5984/_membership
```
会返回如下的信息：

```json
{
  "all_nodes": [
    "couchdb@my.couchdb1",
    "couchdb@my.couchdb2",
    "couchdb@my.couchdb3"
  ],
  "cluster_nodes": [
    "couchdb@my.couchdb1",
    "couchdb@my.couchdb2",
    "couchdb@my.couchdb3"
  ]
}
```

该结果说明集群配置成功。

all_nodes are all the nodes thats this node knows about.
cluster_nodes are the nodes that are connected to this node.

##### 创建数据库(集群复制库)

###### 创建库

请求地址：
```shell script
http://192.168.16.70:5984/cluster_db
```

请求方式：**PUT**

返回下面的结果，说明操作成功：
```shell
{
    "ok": true
}
```

###### 插入数据（会被同步复制）

因为该数据库是会被复制同步的数据库，插入一行数据以确定是否被同步

请求地址：
```shell
http://192.168.16.70:5984/cluster_db
```

请求方式POST，请求的报文如下：
```json
{
	"mySongs":  
	[
		{"周杰伦": "《双截棍》"},
		{"陈奕迅": "《富士山下》"},
		{"Taylor Swift": "《Blank Space》"}
	] 
}
```

返回结果：
```json
{
    "ok": true,
    "id": "98312fbfb0d8ee4613edf7b6790005c4",
    "rev": "1-612aeb6d24bf9647ef630c246aa69e44"
}
```
以上返回结果表明数据插入成功

###### 验证是否被同步
请求另外一个数据库以查看该数据是否被同步过去

请求地址：
```shell
http://192.168.16.70:5985/cluster_db/98312fbfb0d8ee4613edf7b6790005c4
```

请求方式GET，从上面的接口参数中可以看到，所使用的是才插入的数据库的id，但请求的端口为5985端口，这是my.couchdb2数据库的端口。

返回结果：
```json
{
    "_id": "98312fbfb0d8ee4613edf7b6790005c4",
    "_rev": "1-612aeb6d24bf9647ef630c246aa69e44",
    "mySongs": [
        {
            "周杰伦": "《双截棍》"
        },
        {
            "陈奕迅": "《富士山下》"
        },
        {
            "Taylor Swift": "《Blank Space》"
        }
    ]
}
```
可见该数据被同步到了my.couchdb2数据库中。

##### 创建本地数据库

###### 创建
本地数据库，是不会被同步的数据库，其他创建接口和会被同步的数据库是不一样的

注意, local是指的是数据，不是数据库

请求地址：
```shell
http://192.168.16.70:5984/local_db
```

请求方式：**PUT**

返回下面的结果，说明操作成功：
```shell
{
    "ok": true
}
```



###### 插入数据（不会被同步复制）

因为该数据库是会被复制同步的数据库，插入一行数据以确定是否被同步

请求地址：
```shell
http://192.168.16.70:5984/cluster_db/_local
```

请求方式POST，请求的报文如下：
```json
{
	"mySongs":  
	[
		{"周杰伦": "《一路向北》"},
		{"林俊杰": "《曹操》"}
	] 
}
```

返回结果：
```json
{
    "ok": true,
    "id": "98312fbfb0d8ee4613edf7b6790005c4",
    "rev": "1-612aeb6d24bf9647ef630c246aa69e44"
}
```
以上返回结果表明数据插入成功


###### 验证是否被同步
请求另外一个数据库以查看该数据是否被同步过去

请求地址：
```shell
http://192.168.16.70:5985/cluster_db/_local/1
```

请求方式GET，从上面的接口参数中可以看到，所使用的是才插入的数据库的id，但请求的端口为5985端口，这是my.couchdb2数据库的端口。

返回结果：
```json
{
    "_id": "98312fbfb0d8ee4613edf7b6790005c4",
    "_rev": "1-612aeb6d24bf9647ef630c246aa69e44",
    "mySongs": [
        {
            "周杰伦": "《双截棍》"
        },
        {
            "陈奕迅": "《富士山下》"
        },
        {
            "Taylor Swift": "《Blank Space》"
        }
    ]
}
```
可见该数据被同步到了my.couchdb2数据库中。


https://docs.couchdb.org/en/stable/cluster/sharding.html#cluster-sharding


#### 创建自定义的replicate任务，看看该数据是否会被同步

https://docs.couchdb.org/en/stable/replication/replicator.html

##### 创建集群1

```shell script
docker network rm k-network
docker network create k-network

docker rm -f my.couchdb1
docker rm -f my.couchdb2
docker rm -f my.couchdb3

docker run --name my.couchdb1 \
   --network=k-network \
   -p 5984:5984 \
   -p 9100-9200:9100-9200 \
   -e NODENAME=my.couchdb1 \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -e ERL_FLAGS='-setcookie "brumbrum" -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9200' \
   -d couchdb:3.0
   
docker run --name my.couchdb2 \
   --network=k-network \
   -p 5985:5984 \
   -p 9300-9400:9300-9400 \
   -e NODENAME=my.couchdb2 \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -e ERL_FLAGS='-setcookie "brumbrum2" -kernel inet_dist_listen_min 9300 -kernel inet_dist_listen_max 9400' \
   -d couchdb:3.0
   
docker run --name my.couchdb3 \
   --network=k-network \
   -p 5986:5984 \
   -p 9500-9600:9500-9600 \
   -e NODENAME=my.couchdb3 \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -e ERL_FLAGS='-setcookie "brumbrum3" -kernel inet_dist_listen_min 9500 -kernel inet_dist_listen_max 9600' \
   -d couchdb:3.0   
```


##### 集群配置
上述操作只是将两个集群中分别的3个node安装完毕，还没有形成集群。用下述命令可以查询到

```shell script
http://192.168.16.70:5984/_membership
```

返回结果
```json
{
    "all_nodes": [
        "couchdb@my.couchdb1"
    ],
    "cluster_nodes": [
        "couchdb@my.couchdb1"
    ]
}
```

https://docs.couchdb.org/en/stable/setup/cluster.html#preparing-couchdb-nodes-to-be-joined-into-a-cluster

返回结果说明该集群里面只有一个节点，就是所请求的节点本身。

###### 创建必要的数据库
分别请求下面的接口，请求方式都是PUT，以创建必要的数据库。
```shell script
http://192.168.16.70:5984/_users
http://192.168.16.70:5985/_users
http://192.168.16.70:5986/_users


```

```shell script
http://192.168.16.70:5984/_replicator
http://192.168.16.70:5985/_replicator
http://192.168.16.70:5986/_replicator

```

```shell script
http://192.168.16.70:5984/_global_changes
http://192.168.16.70:5985/_global_changes
http://192.168.16.70:5986/_global_changes
```


###### 检查节点是否可以开始集群配置
首先通过API检查所有节点是否已经能够配置集群，请求方式为GET，请求地址:
```shell script
http://192.168.16.70:5984/_cluster_setup
```
如果返回结果是：
```json
{
    "state": "cluster_enabled"
}
```

说明已经可以进行集群配置，反之则要在所有不是"cluster_enabled"的节点进行下面的操作，请求方式为POST
```shell script
http://192.168.16.70:5984/_cluster_setup
```

```json
{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "admin", "password":"password", "node_count":"3"}
```
###### 将节点组成集群
在couchdb的集群设计逻辑中，是没有所谓中心节点或者主节点这样的概念的，所有机器以平等的资格组成集群。所以在集群配置的过程中，可以随便找一台规划的集群中的机器，作为协调节点进行集群配置过程。

通过下面的接口，将节点进行集群配置，请求方式POST
```shell script
http://192.168.16.70:5984/_cluster_setup
```

下面为提交到的接口的消息体参数信息，可以看到host为my.couchdb2，而端口信息则是5984，不是5985（第二个节点从主机映射的端口），这是因为此处设计的couchdb集群是通过docker network进行通信的，所以使用了couchdb的内网端口5984，而不是映射到主机上的端口5985。

```json
{
    "action": "add_node", 
    "host": "my.couchdb2", 
    "port": "5984",
    "username": "admin", 
    "password": "password" 
}
```

当操作结果正确的时候返回的结果：
```json
{
    "ok": true
}
```

此时调用查看集群成员信息的接口：
```shell
http://192.168.16.70:5984/_membership
或：
http://192.168.16.70:5985/_membership
```

均能的到下面的返回结果：
```json
{
    "all_nodes": [
        "couchdb@my.couchdb1",
        "couchdb@my.couchdb2"
    ],
    "cluster_nodes": [
        "couchdb@my.couchdb1",
        "couchdb@my.couchdb2"
    ]
}
```
说明my.couchdb1和my.couchdb2已经组成了集群，按照上面类似的方式，将mycouchdb3加入到集群中，则三个节点组成的集群完成。当查看集群状态时候得到下面的结果信息时，说明集群组建成功。
```json
{
    "all_nodes": [
        "couchdb@my.couchdb1",
        "couchdb@my.couchdb2",
        "couchdb@my.couchdb3"
    ],
    "cluster_nodes": [
        "couchdb@my.couchdb1",
        "couchdb@my.couchdb2",
        "couchdb@my.couchdb3"
    ]
}
```

###### 集群重启之后会发现变化

需要分析：
```json
{
    "all_nodes": [
        "couchdb@my.couchdb1"
    ],
    "cluster_nodes": [
        "couchdb@my.couchdb1",
        "couchdb@my.couchdb2",
        "couchdb@my.couchdb3"
    ]
}
```


##### 创建集群2

类似集群1的操作，对集群2进行配置。

创建集群节点命令：
```shell script
docker network rm k-network2
docker network create k-network2

docker rm -f my.couchdb_a_1
docker rm -f my.couchdb_a_2
docker rm -f my.couchdb_a_3

docker run --name my.couchdb_a_1 \
   --network=k-network2 \
   -p 5987:5984 \
   -p 19100-19200:19100-19200 \
   -e NODENAME=my.couchdb_a_1 \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -e ERL_FLAGS='-setcookie "brumbruma" -kernel inet_dist_listen_min 19100 -kernel inet_dist_listen_max 19200' \
   -d couchdb:3.0
   
docker run --name my.couchdb_a_2 \
   --network=k-network2 \
   -p 5988:5984 \
   -p 19300-19400:19300-19400 \
   -e NODENAME=my.couchdb_a_2 \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -e ERL_FLAGS='-setcookie "brumbruma2" -kernel inet_dist_listen_min 19300 -kernel inet_dist_listen_max 19400' \
   -d couchdb:3.0
   
docker run --name my.couchdb_a_3 \
   --network=k-network2 \
   -p 5989:5984 \
   -p 19500-19600:19500-19600 \
   -e NODENAME=my.couchdb_a_3 \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -e ERL_FLAGS='-setcookie "brumbruma3" -kernel inet_dist_listen_min 19500 -kernel inet_dist_listen_max 19600' \
   -d couchdb:3.0   
```

其他诸如初始化集群中节点的users, replicator, global_changes数据库，以及将各节点组织成集群的操作略。最终需要查询到节点能够组成如下的集群结果：

```json

```

检查两个集群信息，分别正常。数据只会在同一个集群内部进行同步，不会同步到另外一个集群中去，测试略。

##### 将节点从集群中删除
###### 首先获取节点版本信息
在删除之前首先要获取节点的版本信息
```json
http://192.168.88.128:5984/_node/_local/_nodes/couchdb@my.couchdb2
```

返回信息
```json
{
    "_id": "couchdb@my.couchdb2",
    "_rev": "1-967a00dff5e02add41819138abb3284d"
}
```

###### 删除节点
请求地址，请求方式DELETE
```shell
curl -X DELETE "http://xxx.xxx.xxx.xxx/_node/_local/_nodes/node2@yyy.yyy.yyy.yyy?rev=1-967a00dff5e02add41820138abb3284d"
```

返回结果：
```json
{
    "ok": true,
    "id": "couchdb@my.couchdb2",
    "rev": "2-eec205a9d413992850a6e32678485900"
}
```

## 创建两个集群的数据同步

### 首先创建源数据库和目标数据库

请求方式：put

```json
http://192.168.88.128:5984/source_db
```

```json
http://192.168.88.128:5984/target_db
```

### 将两个数据库定义为复制关系

请求地址：
```shell
http://192.168.88.128:5984/_replicator
```

请求方式POST

请求体
```json
{ 
    "source": {
        "url":"http://192.168.88.128:5984/source_db",
        "headers":{
            "Authorization":"Basic YWRtaW46cGFzc3dvcmQ="
        }
    }, 
    "target": {
         "url":"http://192.168.88.128:5984/target_db",
         "headers":{
             "Authorization":"Basic YWRtaW46cGFzc3dvcmQ="
         }
    },  
    "create_target": false, 
    "continuous": true
}
```


返回结果：
```json
{
    "ok": true,
    "_local_id": "aa2a2e2622758db8412da4a13c26cecb+continuous+create_target"
}
```

？另外一次请求的返回结果是,需要证实常见的返回结果是，
```json
{
  "ok": true,
  "id": "91657cc94842127216faec6810007b5e",
  "rev": "1-ce0fb7a8730f852a4bc1040410a7e604"
}
```

### 向源数据库写入数据进行测试

_请求地址：_
```shell
http://192.168.16.70:5984/source_db
```

_请求方式：_

**POST**

_请求报文：_
```json
{
  "_id":"test001",
  "test": "往source库写入的数据信息，将会自动复制到target库"
}
```

_返回结果：_
```json
{
  "ok": true,
  "id": "test001",
  "rev": "1-3e8b59839dadb4301533183a137df54f"
}
```

此时查看复制情况会发现该条记录已经被同步到了target_db数据库，通过下面的GET请求
```json
http://192.168.88.128:5984/target_db/test001
```

可以获得如下的结果，说明数据被同步到了target_db数据库
```json
{
    "_id": "test001",
    "_rev": "1-3e8b59839dadb4301533183a137df54f",
    "test": "往source库写入的数据信息，将会自动复制到target库"
}
```

然而，如果向target_db写入数据，是不会被复制到source_db数据库的。证明过程略。

### 向源数据库写入要求不允许复制的数据进行测试

_请求地址：_
```shell
http://192.168.88.128:5984/source_db/_local/test004
```

_请求方式：_**PUT**。 _请求报文如下：_
```json
{
  "test": "往source库写入的数据信息，以local方式进行保存"
}
```

_返回结果：_
```json
{
  "ok": true,
  "id": "_local/test004",
  "rev": "0-1"
}
```

以上返回结果表明数据插入成功



### 冲突解决

https://docs.couchdb.org/en/stable/replication/conflicts.html

```text
  DESKTOP                          LAPTOP
+---------+
| /db/bob |                                     INITIAL
|   v1    |                                     CREATION
+---------+

+---------+                      +---------+
| /db/bob |  ----------------->  | /db/bob |     PUSH
|   v1    |                      |   v1    |
+---------+                      +---------+

+---------+                      +---------+  INDEPENDENT
| /db/bob |                      | /db/bob |     LOCAL
|   v2a   |                      |   v2b   |     EDITS
+---------+                      +---------+

+---------+                      +---------+
| /db/bob |  ----------------->  | /db/bob |     PUSH
|   v2a   |                      |   v2a   |
+---------+                      |   v2b   |
                                 +---------+

+---------+                      +---------+
| /db/bob |  <-----------------  | /db/bob |     PULL
|   v2a   |                      |   v2a   |
|   v2b   |                      |   v2b   |
+---------+                      +---------+
```



## 复制协议

https://docs.couchdb.org/en/stable/replication/protocol.html