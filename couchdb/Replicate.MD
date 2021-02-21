There are two different ways to set up a replication. The first one that was introduced into CouchDB leads to a replication that could be called transient. Transient means that there are no documents backing up the replication. So after a restart of the CouchDB server the replication will disappear. Later, the _replicator database was introduced, which keeps documents containing your replication parameters. Such a replication can be called persistent. Transient replications were kept for backward compatibility. Both replications can have different replication states.

两种复制类型：

transient:
单次复制，CouchDB服务器重启之后就不存在了。

persistent:
replicate信息保存在_replicator数据库里面，持续性复制。



```json
{
    "_id": "my_rep",
    "source": "http://myserver.com/foo",
    "target":  "http://user:pass@localhost:5984/bar",
    "create_target":  true,
    "continuous": true
}
```


```json
{
    "database": "_replicator",
    "doc_id": "my_rep",
    "error_count": 0,
    "id": "a81a78e822837e66df423d54279c15fe+continuous+create_target",
    "info": {
        "revisions_checked": 113,
        "missing_revisions_found": 113,
        "docs_read": 113,
        "docs_written": 113,
        "changes_pending": 0,
        "doc_write_failures": 0,
        "checkpointed_source_seq": "113-g1AAAACTeJzLYWBgYMpgTmHgz8tPSTV0MDQy1zMAQsMckEQiQ1L9____szKYE01ygQLsZsYGqcamiZjKcRqRxwIkGRqA1H-oSbZgk1KMLCzTDE0wdWUBAF6HJIQ",
        "source_seq": "113-g1AAAACTeJzLYWBgYMpgTmHgz8tPSTV0MDQy1zMAQsMckEQiQ1L9____szKYE01ygQLsZsYGqcamiZjKcRqRxwIkGRqA1H-oSbZgk1KMLCzTDE0wdWUBAF6HJIQ",
        "through_seq": "113-g1AAAACTeJzLYWBgYMpgTmHgz8tPSTV0MDQy1zMAQsMckEQiQ1L9____szKYE01ygQLsZsYGqcamiZjKcRqRxwIkGRqA1H-oSbZgk1KMLCzTDE0wdWUBAF6HJIQ"
    },
    "last_updated": "2017-04-05T19:18:15Z",
    "node": "node1@127.0.0.1",
    "source_proxy": null,
    "target_proxy": null,
    "source": "http://myserver.com/foo/",
    "start_time": "2017-04-05T19:18:15Z",
    "state": "running",
    "target": "http://adm:*****@localhost:5984/bar/"
}
```


The default replicator database is _replicator. Additional replicator databases can be created. To be recognized as such by the system, their database names should end with /_replicator.

系统replicator的命名是以_replicator结尾的。

比如：_design/_replicator

It is RECOMMENDED that one follow this algorithm specification, use the same HTTP endpoints, and run requests with the same parameters to provide a completely compatible implementation. Custom Replicator implementations MAY use different HTTP API endpoints and request parameters depending on their local specifics and they MAY implement only part of the Replication Protocol to run only Push or Pull Replication. However, while such solutions could also run the Replication process, they loose compatibility with the CouchDB Replicator.


## protocol document

https://docs.couchdb.org/en/stable/replication/protocol.html


创建数据库
```shell script
http://admin:password@192.168.16.70:5984/sample
```

写入一行测试数据

```shell script
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/sample -d '{ "fruitName":"cherry", "city":"Xian","prices":[{"carrefour": 19.99},{"walmart": 12.06},{"Auchan": 16.67}] }'
```


https://docs.couchdb.org/en/stable/ddocs/views/intro.html

"afrikaans", 1

































There are two different ways to set up a replication. The first one that was introduced into CouchDB leads to a replication that could be called transient. Transient means that there are no documents backing up the replication. So after a restart of the CouchDB server the replication will disappear. Later, the _replicator database was introduced, which keeps documents containing your replication parameters. Such a replication can be called persistent. Transient replications were kept for backward compatibility. Both replications can have different replication states.

两种复制类型：

transient:
单次复制，CouchDB服务器重启之后就不存在了。

persistent:
replicate信息保存在_replicator数据库里面，持续性复制。



```json
{
    "_id": "my_rep",
    "source": "http://myserver.com/foo",
    "target":  "http://user:pass@localhost:5984/bar",
    "create_target":  true,
    "continuous": true
}
```


```json
{
    "database": "_replicator",
    "doc_id": "my_rep",
    "error_count": 0,
    "id": "a81a78e822837e66df423d54279c15fe+continuous+create_target",
    "info": {
        "revisions_checked": 113,
        "missing_revisions_found": 113,
        "docs_read": 113,
        "docs_written": 113,
        "changes_pending": 0,
        "doc_write_failures": 0,
        "checkpointed_source_seq": "113-g1AAAACTeJzLYWBgYMpgTmHgz8tPSTV0MDQy1zMAQsMckEQiQ1L9____szKYE01ygQLsZsYGqcamiZjKcRqRxwIkGRqA1H-oSbZgk1KMLCzTDE0wdWUBAF6HJIQ",
        "source_seq": "113-g1AAAACTeJzLYWBgYMpgTmHgz8tPSTV0MDQy1zMAQsMckEQiQ1L9____szKYE01ygQLsZsYGqcamiZjKcRqRxwIkGRqA1H-oSbZgk1KMLCzTDE0wdWUBAF6HJIQ",
        "through_seq": "113-g1AAAACTeJzLYWBgYMpgTmHgz8tPSTV0MDQy1zMAQsMckEQiQ1L9____szKYE01ygQLsZsYGqcamiZjKcRqRxwIkGRqA1H-oSbZgk1KMLCzTDE0wdWUBAF6HJIQ"
    },
    "last_updated": "2017-04-05T19:18:15Z",
    "node": "node1@127.0.0.1",
    "source_proxy": null,
    "target_proxy": null,
    "source": "http://myserver.com/foo/",
    "start_time": "2017-04-05T19:18:15Z",
    "state": "running",
    "target": "http://adm:*****@localhost:5984/bar/"
}
```


The default replicator database is _replicator. Additional replicator databases can be created. To be recognized as such by the system, their database names should end with /_replicator.

系统replicator的命名是以_replicator结尾的。

比如：_design/_replicator

It is RECOMMENDED that one follow this algorithm specification, use the same HTTP endpoints, and run requests with the same parameters to provide a completely compatible implementation. Custom Replicator implementations MAY use different HTTP API endpoints and request parameters depending on their local specifics and they MAY implement only part of the Replication Protocol to run only Push or Pull Replication. However, while such solutions could also run the Replication process, they loose compatibility with the CouchDB Replicator.


## protocol document

https://docs.couchdb.org/en/stable/replication/protocol.html


创建数据库
```shell script
http://admin:password@192.168.16.70:5984/sample
```

写入一行测试数据

```shell script
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/sample -d '{ "fruitName":"cherry", "city":"Xian","prices":[{"carrefour": 19.99},{"walmart": 12.06},{"Auchan": 16.67}] }'
```


https://docs.couchdb.org/en/stable/ddocs/views/intro.html

"afrikaans", 1

