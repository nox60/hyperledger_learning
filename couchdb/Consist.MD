
https://docs.couchdb.org/en/stable/intro/consistency.html

验证这张图流程

![img.png](images/img.png)


The first time we use this backup application, we feed our playlists to the application and initiate a backup. Each playlist is converted to a JSON object and handed to a CouchDB database. As illustrated in Figure 5. Backing up to a single database, CouchDB hands back the document ID and revision of each playlist as it’s saved to the database.

通过程序向couchdb第一次提交播放列表对象。CouchDB会将这个播放列表视为一个文档进行保存，并返回一个文档ID和版本号。

在postman中，首次创建一个数据库名叫playlist.

