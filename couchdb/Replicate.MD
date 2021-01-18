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