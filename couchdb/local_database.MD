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

##### 创建集群2


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

检查两个集群信息，分别正常。数据只会在同一个集群内部进行同步，不会同步到另外一个集群中去，测试略。

##### 创建两个集群的数据同步

