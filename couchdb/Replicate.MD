There are two different ways to set up a replication. The first one that was introduced into CouchDB leads to a replication that could be called transient. Transient means that there are no documents backing up the replication. So after a restart of the CouchDB server the replication will disappear. Later, the _replicator database was introduced, which keeps documents containing your replication parameters. Such a replication can be called persistent. Transient replications were kept for backward compatibility. Both replications can have different replication states.

两种复制类型：

transient:
单次复制，CouchDB服务器重启之后就不存在了。

persistent:
replicate信息保存在_replicator数据库里面，持续性复制。