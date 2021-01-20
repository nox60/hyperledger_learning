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

首先在Specify your Admin credentials下面的输入框中填写用户名和密码，根据前面初始化脚本中配置的相关信息，此处填入用户名admin，密码password，然后在界面下方的Add Nodes to the Cluster
                                                                                                   Remote host