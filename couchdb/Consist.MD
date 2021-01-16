
https://docs.couchdb.org/en/stable/intro/consistency.html

验证这张图流程

![img.png](images/img.png)


The first time we use this backup application, we feed our playlists to the application and initiate a backup. Each playlist is converted to a JSON object and handed to a CouchDB database. As illustrated in Figure 5. Backing up to a single database, CouchDB hands back the document ID and revision of each playlist as it’s saved to the database.

通过程序向couchdb第一次提交播放列表对象。CouchDB会将这个播放列表视为一个文档进行保存，并返回一个文档ID和版本号。

在postman中，首次创建一个数据库名叫playlist.

请求地址：
```shell
http://admin:password@192.168.88.128:5984/playlist
```

请求方式：**PUT**

返回下面的结果，说明操作成功：
```shell
{
    "ok": true
}
```

然后提交第一份数据如下：

请求地址：
```shell
http://admin:password@192.168.88.128:5984/playlist
```

请求方式：**POST**

请求体:
```shell
{
	"mySongs":  
	[
		{"周杰伦": "《双截棍》"},
		{"陈奕迅": "《富士山下》"},
		{"Taylor Swift": "《Blank Space》"}
	] 
}
```

返回下面的结果：
```shell
{
    "ok": true,
    "id": "0825d2afeabbbc8a0de2b1ba9e0003ce",
    "rev": "1-612aeb6d24bf9647ef630c246aa69e44"
}
```
上面的结果说明操作成功， 并且里面包含了这个文档的id以及版本号rev