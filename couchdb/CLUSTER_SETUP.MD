https://github.com/apache/couchdb-docker/blob/master/README.md

CouchDB uses Erlang-native clustering functionality to achieve a clustered installation. Erlang uses TCP port 4369 (EPMD) to find other nodes, so all servers must be able to speak to each other on this port. In an Erlang cluster, all nodes are connected to all other nodes, in a mesh network configuration.

First, get two UUIDs to use later on. Be sure to use the SAME UUIDs on all nodes.
curl http://<server-IP|FQDN>:5984/_uuids?count=2

CouchDB will respond with something like:
   {"uuids":["60c9e8234dfba3e2fdab04bf92001142","60c9e8234dfba3e2fdab04bf92001cc2"]}
Copy the provided UUIDs into your clipboard or a text editor for later use.
Use the first UUID as the cluster UUID.
Use the second UUID as the cluster shared http secret.

Create the admin user and password:
curl -X PUT http://<server-IP|FQDN>:5984/_node/_local/_config/admins/admin -d '"password"'

Now, bind the clustered interface to all IP addresses availble on this machine
curl -X PUT http://<server-IP|FQDN>:5984/_node/_local/_config/chttpd/bind_address -d '"0.0.0.0"'

If not using the setup wizard / API endpoint, the following 2 steps are required:
Set the UUID of the node to the first UUID you previously obtained:
curl -X PUT http://<server-IP|FQDN>:5984/_node/_local/_config/couchdb/uuid -d '"FIRST-UUID-GOES-HERE"'

Finally, set the shared http secret for cookie creation to the second UUID:
curl -X PUT http://<server-IP|FQDN>:5984/_node/_local/_config/couch_httpd_auth/secret -d '"SECOND-UUID-GOES-HERE"'



After that we can join all the nodes together. Choose one node as the “setup coordination node” to run all these commands on. This “setup coordination node” only manages the setup and requires all other nodes to be able to see it and vice versa. It has no special purpose beyond the setup process; CouchDB does not have the concept of a “master” node in a cluster.


A shard is a horizontal partition of data in a database. Partitioning data into shards and distributing copies of each shard (called “shard replicas” or just “replicas”) to different nodes in a cluster gives the data greater durability against node loss. CouchDB clusters automatically shard databases and distribute the subsets of documents that compose each shard among nodes. Modifying cluster membership and sharding behavior must be done manually.

shard

分片是数据库中数据的水平分区。 将数据划分为多个分片，并将每个分片的副本（称为“碎片副本”或简称为“副本”）分发到群集中的不同节点，可以提高数据的持久性，防止节点丢失。 CouchDB群集自动分片数据库，并在节点之间分配组成每个分片的文档子集。 修改群集成员身份和分片行为必须手动完成。

replicate

复制（复本）

node
节点


[cluster]
q=2
n=3

q分片，n副本

```shell script
$ curl -X PUT "$COUCH_URL:5984/database-name?q=4&n=2"
```
This creates a database that is split into 4 shards and 2 replicas, yielding 8 shard replicas distributed throughout the cluster.

上面的命令创建了一个数据库，分为4个分片和2个副本，因此会有8个分片分布在整个集群上。



This section describes how to manually place and replace shards. These activities are critical steps when you determine your cluster is too big or too small, and want to resize it successfully, or you have noticed from server metrics that database/shard layout is non-optimal and you have some “hot spots” that need resolving.

Consider a three-node cluster with q=8 and n=3. Each database has 24 shards, distributed across the three nodes. If you add a fourth node to the cluster, CouchDB will not redistribute existing database shards to it. This leads to unbalanced load, as the new node will only host shards for databases created after it joined the cluster. To balance the distribution of shards from existing databases, they must be moved manually.



Ensure the target node has joined the cluster.
Copy the shard(s) and any secondary index shard(s) onto the target node.
Set the target node to maintenance mode.
Update cluster metadata to reflect the new target shard(s).
Monitor internal replication to ensure up-to-date shard(s).
Clear the target node’s maintenance mode.
Update cluster metadata again to remove the source shard(s)
Remove the shard file(s) and secondary index file(s) from the source node.


https://docs.couchdb.org/en/stable/setup/single-node.html




## 安装
描述安装脚本，说明端口配置


## 配置
### 1. 使用界面上的方式进行配置
通过地址：http://127.0.0.1:5984/_utils#setup 访问Fauxton，然后会被询问是要配置单节点(single-node)还是设置一个集群，如果选择单节点，则要输入用户名和密码。

同时可以把couchdb和公网地址进行绑定，这样可以被局域网或者互联网上的主机访问到，比如绑定到0.0.0.0低智商，则绑定到了主机的所有地址上。然后配置工具会要求输入用户名和密码，创建下面的三个系统数据库：

```shell script
_users
_replicator
_global_changes
```

### 通过配置文件设置使用单节点
如果在local.ini文件中设置了 
```shell script
[couchdb] single_node=true
```
则CouchDB会自动创建上述的三个数据库（在restart的时候？）

### 通过API创建
如果不想通过Fauxton的设置中心进行设置，
Alternatively, if you don’t want to use the Setup Wizard or set that value, and run 3.x as a single node with a server administrator already configured via config file, make sure to create the three system databases manually on startup:

通过下面的接口创造三个数据库：

```shell script
curl -X PUT http://127.0.0.1:5984/_users
curl -X PUT http://127.0.0.1:5984/_replicator
curl -X PUT http://127.0.0.1:5984/_global_changes
```

## 集群配置
集群端口如下：

|Port Number|	Protocol|	Recommended binding|	Usage|
|---|---|---|---|
|5984|	tcp|	As desired, by default localhost|	用于API请求|
|4369|	tcp	|All interfaces by default	|Erlang port mapper daemon (epmd)|
|大于1024|	tcp|	自动分配	| 和集群中的其他接口通信的端口|

CouchDB uses Erlang-native clustering functionality to achieve a clustered installation. Erlang uses TCP port 4369 (EPMD) to find other nodes, so all servers must be able to speak to each other on this port. In an Erlang cluster, all nodes are connected to all other nodes, in a mesh network configuration.

CouchDB利用Erlang原生的集群能力进行集群部署。Erlang通过TCP 4369端口寻找其他节点，因此所有的服务器需要能够通过该端口和其他节点通信，在Erlang集群中，所有的节点都连接到其他节点，在同一个服务网格中。


If you expose the port 4369 to the Internet or any other untrusted network, then the only thing protecting you is the Erlang cookie.
如果把4369端口暴露到公网或者其他非信任的网络环境中，唯一能够保护服务得方式就是Erlang cookie.

Every Erlang application running on that machine (such as CouchDB) then uses automatically assigned ports for communciation with other nodes. Yes, this means random ports. This will obviously not work with a firewall, but it is possible to force an Erlang application to use a specific port range.
所有运行在同一台机器上的Erlang进程都使用自动分配的端口和其他节点进行通信，因为端口号随机分配的，这对于防火墙保护下的网络不可行，因为需要指定端口进行网络开发。因此解决方案就是使用指定一个端口范围。

This documentation will use the range TCP 9100-9200, but this range is unnecessarily broad. If you only have a single Erlang application running on a machine, the range can be limited to a single port: 9100-9100, since the ports epmd assign are for inbound connections only. Three CouchDB nodes running on a single machine, as in a development cluster scenario, would need three ports in this range.

当前文档会要求使用TCP 9100-9200 范围，但是这个范围是非必需的。如果仅仅是运行一个单Erlang进程在这台机器上，可以将该节点压缩成一个端口号：9100-9100。如果有三个CouchDB节点运行在一个机器上，则要求在该端口范围中至少有三个端口。


将CouchDB绑定到一个FQDN域名上。
```shell script
In file etc/vm.args change the line -name couchdb@127.0.0.1 to -name couchdb@<reachable-ip-address|fully-qualified-domain-name> which defines the name of the node. Each node must have an identifier that allows remote systems to talk to it. The node name is of the form <name>@<reachable-ip-address|fully-qualified-domain-name>.

```


For a CouchDB cluster you need to provide the NODENAME setting as well as the erlang cookie. Settings to Erlang can be made with the environment variable ERL_FLAGS, e.g. ERL_FLAGS=-setcookie "brumbrum". By default, this image exposes the epmd port 4369 and the Erlang cluster communication port 9100 (i.e. inet_dist_listen_min and inet_dist_listen_max are both 9100). Further information can be found here.

- COUCHDB_USER and COUCHDB_PASSWORD will create an ini-file based local admin user with the given username and password in the file /opt/couchdb/etc/local.d/docker.ini.
- COUCHDB_SECRET will set the CouchDB shared cluster secret value, in the file /opt/couchdb/etc/local.d/docker.ini.
- NODENAME will set the name of the CouchDB node inside the container to couchdb@${NODENAME}, in the file /opt/couchdb/etc/vm.args. This is used for clustering purposes and can be ignored for single-node setups.
- Erlang Environment Variables like ERL_FLAGS will be used by Erlang itself. For a complete list have a look here
table/add
要设置的值
COUCHDB_USER
COUCHDB_PASSWORD
COUCHDB_SECRET
NODENAME
ERL_FLAGS  (ERL_FLAGS=-setcookie "brumbrum")
inet_dist_listen_min   9100
inet_dist_listen_max   9100

-setcookie 'brumbrum' -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9200

```shell
$docker run -itd -p 4000:4000 4368:4369 9000:9000 <docker_image_name> iex \
  --name test@1.2.3.4 \
    --cookie secret \
      --erl '-kernel inet_dist_listen_min 9000' \
      --erl '-kernel inet_dist_listen_max 9000' \
         -S mix phx.server`


erl the Erlang shell.
-name bus@192.168.0.1 the name of the Erlang node and its IP address or FQDN.
-setcookie 'brumbrum' the “password” used when nodes connect to each other.
-kernel inet_dist_listen_min 9100 the lowest port in the range.
-kernel inet_dist_listen_max 9200 the highest port in the range.


```

```shell script
The content of these environment variables will be added to the end of the command line for erl.

erl -name bus@192.168.0.1 -setcookie 'brumbrum' -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9200
//testing......1. 测试是否能够正确将参数应用到erlang环境中。2.测试是否生效。
```

```shell
docker run --name my-couchdb \
   -v /opt/local/containers/couchdb/data:/opt/couchdb/data \
   -v /opt/local/containers/couchdb/log/couch.log:/opt/couchdb/couch.log \
   -p 5984:5984 \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -e ERL_FLAGS='-setcookie "brumbrum" -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9100' \
   -d couchdb:3.0

sleep 10

curl -X PUT http://admin:password@127.0.0.1:5984/_users
curl -X PUT http://admin:password@127.0.0.1:5984/_replicator
curl -X PUT http://admin:password@127.0.0.1:5984/_global_changes

# First, get two UUIDs to use later on. Be sure to use the SAME UUIDs on all nodes.
curl http://192.168.88.128:5984/_uuids?count=2

# Now, bind the clustered interface to all IP addresses availble on this machine
curl -X PUT http://admin:password@192.168.88.128:5984/_node/_local/_config/chttpd/bind_address -d '"0.0.0.0"'

# If not using the setup wizard / API endpoint, the following 2 steps are required:
# Set the UUID of the node to the first UUID you previously obtained:
curl -X PUT http://admin:password@192.168.88.128:5984/_node/_local/_config/couchdb/uuid -d '"c50e7f04ea232ab636d90fb59e000780"'

# Finally, set the shared http secret for cookie creation to the second UUID:
curl -X PUT http://admin:password@192.168.88.128:5984/_node/_local/_config/couch_httpd_auth/secret -d '"c50e7f04ea232ab636d90fb59e000c2a"'


curl http://admin:password@127.0.0.1:5984/_membership
```



单机器部署正确：
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



在界面上进行配置，测试使用172IP先完成链接。



https://docs.couchdb.org/en/stable/setup/cluster.html


```shell
docker run --name my-couchdb \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -d couchdb:3.0
```

docker exec -it my-couchdb /opt/couchdb/bin/remsh
https://stackoverflow.com/questions/9238671/erlang-connecting-to-local-node-error-shell-process-terminated
有问题

1. 不同虚拟机测试构建集群。
2. kong转发



##### 正确的配置

4369端口是默认的，不好修改，修改之后集群的配置会相对比较麻烦。

```shell script
docker run --name my.couchdb \
   -p 5984:5984 \
   -p 5986:5986 \
   -p 9100-9200:9100-9200 \
   -p 4369:4369 \
   -e NODENAME=my.couchdb1 \
   --hostname my.couchdb1 \
   --add-host my.couchdb1:192.168.16.70 \
   --add-host my.couchdb2:192.168.16.71 \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -e ERL_FLAGS='-setcookie "brumbrum" -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9200' \
   -d couchdb:3.0
   
docker run --name my.couchdb2 \
   -p 5984:5984 \
   -p 5986:5986 \
   -p 9100-9200:9100-9200 \
   -p 4369:4369 \
   -e NODENAME=my.couchdb2 \
   --hostname my.couchdb2 \
   --add-host my.couchdb1:192.168.16.70 \
   --add-host my.couchdb2:192.168.16.71 \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -e ERL_FLAGS='-setcookie "brumbrum2" -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9200' \
   -d couchdb:3.0
```



##### 利用kong进行代理

```shell
docker rm -f kong-postgres

rm -rf /root/kong/postgre_db/*

docker run --name kong-postgres \
        -v /root/kong/postgre_db:/var/lib/postgresql/data \
        -e POSTGRES_PASSWORD=123456 \
        -e POSTGRES_USER=kong \
        -e POSTGRES_DB=kong \
        -e PGDATA=/var/lib/postgresql/data/pgdata \
        -p 5432:5432 \
        -d postgres:9.6


sleep 5

docker run --rm \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_PG_HOST=kong-postgres" \
    -e "KONG_PG_PASSWORD=123456" \
    -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
    --link kong-postgres:kong-postgres \
    kong kong migrations bootstrap

docker rm -f kong

docker run -d  --name kong \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_PG_HOST=kong-postgres" \
    -e "KONG_PG_PASSWORD=123456" \
    -e "KONG_PG_USER=kong" \
    -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
    -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
    -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
    -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
    --link kong-postgres:kong-postgres \
    -p 4369:8000 \
    -p 8443:8443 \
    -p 8001:8001 \
    -p 8080-8090:8080-8090 \
    -p 8444:8444 \
    kong

sleep 5

docker run --rm --link kong-postgres:kong-postgres pantsel/konga:latest \
        -c prepare \
        -a postgres \
        -u postgresql://kong:123456@kong-postgres:5432/postgres 

docker rm -f konga

docker run -d  --name konga \
        -p 1337:1337 \
        -e "DB_ADAPTER=postgres" \
        -e "DB_HOST=kong-postgres" \
        -e "DB_PORT=5432" \
        -e "DB_USER=kong" \
        -e "DB_PASSWORD=123456" \
        -e "DB_DATABASE=postgres" \
        -e "NODE_ENV=production" \
        --link kong-postgres:kong-postgres \
        pantsel/konga

      
```

### bbb

```shell
docker inspect --format='{{.NetworkSettings.IPAddress}}' konga
```

```shell
docker run --name my.couchdb \
   -p 5984:5984 \
   -p 5986:5986 \
   -p 9100-9200:9100-9200 \
   -e NODENAME=my.couchdb1 \
   --hostname my.couchdb1 \
   --add-host my.couchdb1:192.168.16.70 \
   --add-host my.couchdb2:192.168.16.71 \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -e ERL_FLAGS='-setcookie "brumbrum" -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9200' \
   -d couchdb:3.0
   
docker run --name my.couchdb2 \
   -p 5984:5984 \
   -p 5986:5986 \
   -p 9100-9200:9100-9200 \
   -e NODENAME=my.couchdb2 \
   --hostname my.couchdb2 \
   --add-host my.couchdb1:192.168.16.70 \
   --add-host my.couchdb2:192.168.16.71 \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -e ERL_FLAGS='-setcookie "brumbrum2" -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9200' \
   -d couchdb:3.0
```

### 调整端口范围的版本，仅仅暴露映射之后的5984端口

```shell script
docker network rm k-network
docker network create k-network

docker rm -f my.couchdb1
docker rm -f my.couchdb2
docker rm -f my.couchdb3

docker run --name my.couchdb1 \
   --network=k-network \
   -p 5984:5984 \
   -e NODENAME=my.couchdb1 \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -e ERL_FLAGS='-setcookie "brumbrum" -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9200' \
   -d couchdb:3.0
   
docker run --name my.couchdb2 \
   --network=k-network \
   -p 5985:5984 \
   -e NODENAME=my.couchdb2 \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -e ERL_FLAGS='-setcookie "brumbrum2" -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9200' \
   -d couchdb:3.0
   
docker run --name my.couchdb3 \
   --network=k-network \
   -p 5986:5984 \
   -e NODENAME=my.couchdb3 \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -e ERL_FLAGS='-setcookie "brumbrum3" -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9200' \
   -d couchdb:3.0   
```






































https://github.com/apache/couchdb-docker/blob/master/README.md

CouchDB uses Erlang-native clustering functionality to achieve a clustered installation. Erlang uses TCP port 4369 (EPMD) to find other nodes, so all servers must be able to speak to each other on this port. In an Erlang cluster, all nodes are connected to all other nodes, in a mesh network configuration.

First, get two UUIDs to use later on. Be sure to use the SAME UUIDs on all nodes.
curl http://<server-IP|FQDN>:5984/_uuids?count=2

CouchDB will respond with something like:
   {"uuids":["60c9e8234dfba3e2fdab04bf92001142","60c9e8234dfba3e2fdab04bf92001cc2"]}
Copy the provided UUIDs into your clipboard or a text editor for later use.
Use the first UUID as the cluster UUID.
Use the second UUID as the cluster shared http secret.

Create the admin user and password:
curl -X PUT http://<server-IP|FQDN>:5984/_node/_local/_config/admins/admin -d '"password"'

Now, bind the clustered interface to all IP addresses availble on this machine
curl -X PUT http://<server-IP|FQDN>:5984/_node/_local/_config/chttpd/bind_address -d '"0.0.0.0"'

If not using the setup wizard / API endpoint, the following 2 steps are required:
Set the UUID of the node to the first UUID you previously obtained:
curl -X PUT http://<server-IP|FQDN>:5984/_node/_local/_config/couchdb/uuid -d '"FIRST-UUID-GOES-HERE"'

Finally, set the shared http secret for cookie creation to the second UUID:
curl -X PUT http://<server-IP|FQDN>:5984/_node/_local/_config/couch_httpd_auth/secret -d '"SECOND-UUID-GOES-HERE"'



After that we can join all the nodes together. Choose one node as the “setup coordination node” to run all these commands on. This “setup coordination node” only manages the setup and requires all other nodes to be able to see it and vice versa. It has no special purpose beyond the setup process; CouchDB does not have the concept of a “master” node in a cluster.


A shard is a horizontal partition of data in a database. Partitioning data into shards and distributing copies of each shard (called “shard replicas” or just “replicas”) to different nodes in a cluster gives the data greater durability against node loss. CouchDB clusters automatically shard databases and distribute the subsets of documents that compose each shard among nodes. Modifying cluster membership and sharding behavior must be done manually.

shard

分片是数据库中数据的水平分区。 将数据划分为多个分片，并将每个分片的副本（称为“碎片副本”或简称为“副本”）分发到群集中的不同节点，可以提高数据的持久性，防止节点丢失。 CouchDB群集自动分片数据库，并在节点之间分配组成每个分片的文档子集。 修改群集成员身份和分片行为必须手动完成。

replicate

复制（复本）

node
节点


[cluster]
q=2
n=3

q分片，n副本

```shell script
$ curl -X PUT "$COUCH_URL:5984/database-name?q=4&n=2"
```
This creates a database that is split into 4 shards and 2 replicas, yielding 8 shard replicas distributed throughout the cluster.

上面的命令创建了一个数据库，分为4个分片和2个副本，因此会有8个分片分布在整个集群上。



This section describes how to manually place and replace shards. These activities are critical steps when you determine your cluster is too big or too small, and want to resize it successfully, or you have noticed from server metrics that database/shard layout is non-optimal and you have some “hot spots” that need resolving.

Consider a three-node cluster with q=8 and n=3. Each database has 24 shards, distributed across the three nodes. If you add a fourth node to the cluster, CouchDB will not redistribute existing database shards to it. This leads to unbalanced load, as the new node will only host shards for databases created after it joined the cluster. To balance the distribution of shards from existing databases, they must be moved manually.



Ensure the target node has joined the cluster.
Copy the shard(s) and any secondary index shard(s) onto the target node.
Set the target node to maintenance mode.
Update cluster metadata to reflect the new target shard(s).
Monitor internal replication to ensure up-to-date shard(s).
Clear the target node’s maintenance mode.
Update cluster metadata again to remove the source shard(s)
Remove the shard file(s) and secondary index file(s) from the source node.


https://docs.couchdb.org/en/stable/setup/single-node.html




## 安装
描述安装脚本，说明端口配置


## 配置
### 1. 使用界面上的方式进行配置
通过地址：http://127.0.0.1:5984/_utils#setup 访问Fauxton，然后会被询问是要配置单节点(single-node)还是设置一个集群，如果选择单节点，则要输入用户名和密码。

同时可以把couchdb和公网地址进行绑定，这样可以被局域网或者互联网上的主机访问到，比如绑定到0.0.0.0低智商，则绑定到了主机的所有地址上。然后配置工具会要求输入用户名和密码，创建下面的三个系统数据库：

```shell script
_users
_replicator
_global_changes
```

### 通过配置文件设置使用单节点
如果在local.ini文件中设置了 
```shell script
[couchdb] single_node=true
```
则CouchDB会自动创建上述的三个数据库（在restart的时候？）

### 通过API创建
如果不想通过Fauxton的设置中心进行设置，
Alternatively, if you don’t want to use the Setup Wizard or set that value, and run 3.x as a single node with a server administrator already configured via config file, make sure to create the three system databases manually on startup:

通过下面的接口创造三个数据库：

```shell script
curl -X PUT http://127.0.0.1:5984/_users
curl -X PUT http://127.0.0.1:5984/_replicator
curl -X PUT http://127.0.0.1:5984/_global_changes
```

## 集群配置
集群端口如下：

|Port Number|	Protocol|	Recommended binding|	Usage|
|---|---|---|---|
|5984|	tcp|	As desired, by default localhost|	用于API请求|
|4369|	tcp	|All interfaces by default	|Erlang port mapper daemon (epmd)|
|大于1024|	tcp|	自动分配	| 和集群中的其他接口通信的端口|

CouchDB uses Erlang-native clustering functionality to achieve a clustered installation. Erlang uses TCP port 4369 (EPMD) to find other nodes, so all servers must be able to speak to each other on this port. In an Erlang cluster, all nodes are connected to all other nodes, in a mesh network configuration.

CouchDB利用Erlang原生的集群能力进行集群部署。Erlang通过TCP 4369端口寻找其他节点，因此所有的服务器需要能够通过该端口和其他节点通信，在Erlang集群中，所有的节点都连接到其他节点，在同一个服务网格中。


If you expose the port 4369 to the Internet or any other untrusted network, then the only thing protecting you is the Erlang cookie.
如果把4369端口暴露到公网或者其他非信任的网络环境中，唯一能够保护服务得方式就是Erlang cookie.

Every Erlang application running on that machine (such as CouchDB) then uses automatically assigned ports for communciation with other nodes. Yes, this means random ports. This will obviously not work with a firewall, but it is possible to force an Erlang application to use a specific port range.
所有运行在同一台机器上的Erlang进程都使用自动分配的端口和其他节点进行通信，因为端口号随机分配的，这对于防火墙保护下的网络不可行，因为需要指定端口进行网络开发。因此解决方案就是使用指定一个端口范围。

This documentation will use the range TCP 9100-9200, but this range is unnecessarily broad. If you only have a single Erlang application running on a machine, the range can be limited to a single port: 9100-9100, since the ports epmd assign are for inbound connections only. Three CouchDB nodes running on a single machine, as in a development cluster scenario, would need three ports in this range.

当前文档会要求使用TCP 9100-9200 范围，但是这个范围是非必需的。如果仅仅是运行一个单Erlang进程在这台机器上，可以将该节点压缩成一个端口号：9100-9100。如果有三个CouchDB节点运行在一个机器上，则要求在该端口范围中至少有三个端口。


将CouchDB绑定到一个FQDN域名上。
```shell script
In file etc/vm.args change the line -name couchdb@127.0.0.1 to -name couchdb@<reachable-ip-address|fully-qualified-domain-name> which defines the name of the node. Each node must have an identifier that allows remote systems to talk to it. The node name is of the form <name>@<reachable-ip-address|fully-qualified-domain-name>.

```


For a CouchDB cluster you need to provide the NODENAME setting as well as the erlang cookie. Settings to Erlang can be made with the environment variable ERL_FLAGS, e.g. ERL_FLAGS=-setcookie "brumbrum". By default, this image exposes the epmd port 4369 and the Erlang cluster communication port 9100 (i.e. inet_dist_listen_min and inet_dist_listen_max are both 9100). Further information can be found here.

- COUCHDB_USER and COUCHDB_PASSWORD will create an ini-file based local admin user with the given username and password in the file /opt/couchdb/etc/local.d/docker.ini.
- COUCHDB_SECRET will set the CouchDB shared cluster secret value, in the file /opt/couchdb/etc/local.d/docker.ini.
- NODENAME will set the name of the CouchDB node inside the container to couchdb@${NODENAME}, in the file /opt/couchdb/etc/vm.args. This is used for clustering purposes and can be ignored for single-node setups.
- Erlang Environment Variables like ERL_FLAGS will be used by Erlang itself. For a complete list have a look here
table/add
要设置的值
COUCHDB_USER
COUCHDB_PASSWORD
COUCHDB_SECRET
NODENAME
ERL_FLAGS  (ERL_FLAGS=-setcookie "brumbrum")
inet_dist_listen_min   9100
inet_dist_listen_max   9100

-setcookie 'brumbrum' -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9200

```shell
$docker run -itd -p 4000:4000 4368:4369 9000:9000 <docker_image_name> iex \
  --name test@1.2.3.4 \
    --cookie secret \
      --erl '-kernel inet_dist_listen_min 9000' \
      --erl '-kernel inet_dist_listen_max 9000' \
         -S mix phx.server`


erl the Erlang shell.
-name bus@192.168.0.1 the name of the Erlang node and its IP address or FQDN.
-setcookie 'brumbrum' the “password” used when nodes connect to each other.
-kernel inet_dist_listen_min 9100 the lowest port in the range.
-kernel inet_dist_listen_max 9200 the highest port in the range.


```

```shell script
The content of these environment variables will be added to the end of the command line for erl.

erl -name bus@192.168.0.1 -setcookie 'brumbrum' -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9200
//testing......1. 测试是否能够正确将参数应用到erlang环境中。2.测试是否生效。
```

```shell
docker run --name my-couchdb \
   -v /opt/local/containers/couchdb/data:/opt/couchdb/data \
   -v /opt/local/containers/couchdb/log/couch.log:/opt/couchdb/couch.log \
   -p 5984:5984 \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -e ERL_FLAGS='-setcookie "brumbrum" -kernel inet_dist_listen_min 9100 -kernel inet_dist_listen_max 9100' \
   -d couchdb:3.0

sleep 10

curl -X PUT http://admin:password@127.0.0.1:5984/_users
curl -X PUT http://admin:password@127.0.0.1:5984/_replicator
curl -X PUT http://admin:password@127.0.0.1:5984/_global_changes

# First, get two UUIDs to use later on. Be sure to use the SAME UUIDs on all nodes.
curl http://192.168.88.128:5984/_uuids?count=2

# Now, bind the clustered interface to all IP addresses availble on this machine
curl -X PUT http://admin:password@192.168.88.128:5984/_node/_local/_config/chttpd/bind_address -d '"0.0.0.0"'

# If not using the setup wizard / API endpoint, the following 2 steps are required:
# Set the UUID of the node to the first UUID you previously obtained:
curl -X PUT http://admin:password@192.168.88.128:5984/_node/_local/_config/couchdb/uuid -d '"c50e7f04ea232ab636d90fb59e000780"'

# Finally, set the shared http secret for cookie creation to the second UUID:
curl -X PUT http://admin:password@192.168.88.128:5984/_node/_local/_config/couch_httpd_auth/secret -d '"c50e7f04ea232ab636d90fb59e000c2a"'


curl http://admin:password@127.0.0.1:5984/_membership
```



单机器部署正确：
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



在界面上进行配置，测试使用172IP先完成链接。



https://docs.couchdb.org/en/stable/setup/cluster.html


```shell
docker run --name my-couchdb \
   -e COUCHDB_USER=admin \
   -e COUCHDB_PASSWORD=password \
   -d couchdb:3.0
```

docker exec -it my-couchdb /opt/couchdb/bin/remsh
https://stackoverflow.com/questions/9238671/erlang-connecting-to-local-node-error-shell-process-terminated
有问题

1. 不同虚拟机测试构建集群。
2. kong转发




