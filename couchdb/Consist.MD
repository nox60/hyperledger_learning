
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
    "id": "416459795fe1b6621ea6ee984b000d0f",
    "rev": "1-612aeb6d24bf9647ef630c246aa69e44"
}
```
上面的结果说明操作成功， 并且里面包含了这个文档的id以及版本号rev。

After a few days, we find that our playlists have been updated and we want to back up our changes. After we have fed our playlists to the backup application, it fetches the latest versions from CouchDB, along with the corresponding document revisions. When the application hands back the new playlist document, CouchDB requires that the document revision is included in the request.

经过一段时间之后，用户决定更新自己的歌单，首先用户从CouchDB上拉取该歌单的详细信息。

拉取歌单信息的时候，在请求中要带上歌单文档的id，请求如下：
```shell
http://admin:password@192.168.88.128:5984/playlist/416459795fe1b6621ea6ee984b000d0f
```

请求方式：**GET**

请求接口说明：
```shell
server:port/{db}/{docid}

服务器及其对应的端口号后面，是数据库名称和文档id
```

返回下面的结果：
```shell
{
    "_id": "416459795fe1b6621ea6ee984b000d0f",
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

可以看到，返回的数据和之前写入的数据有相同的版本号1-612aeb6d24bf9647ef630c246aa69e44，说明数据没有发生变化。

此时用户对数据进行修改，增加了一条歌曲信息，操作如下

https://docs.couchdb.org/en/3.1.1/api/document/common.html#updating-an-existing-document 

请求地址：
```shell
http://admin:password@192.168.88.128:5984/playlist/416459795fe1b6621ea6ee984b000d0f
```

请求方式：**PUT**

请求接口格式：
```shell
server:port/{db}/{docid}
```
说明：
服务器及其对应的端口号后面，是数据库名称和文档id

#### 第一种更新方式，在json消息体中需要以_rev字段携带当前的文档版本号

```shell
{
    "_rev": "1-612aeb6d24bf9647ef630c246aa69e44",
	"mySongs":  
	[
		{"周杰伦": "《双截棍》"},
		{"陈奕迅": "《富士山下》"},
		{"Taylor Swift": "《Blank Space》"},
		{"林俊杰": "《那些你很冒险的梦》"}
	] 
}
```

请求结果：
```shell
{
    "ok": true,
    "id": "0825d2afeabbbc8a0de2b1ba9e0003ce",
    "rev": "1-2db722b7d6ad1a1df0fd49ccd6eb211e"
}
```

可以看到数据库返回了一个新的版本号：1-2db722b7d6ad1a1df0fd49ccd6eb211e，说明文档已经更新并且有了新的版本。

#### 第二种更新方式，在请求头中携带以下信息：

```
If-Match: 1-917fa2381192822767f010b95b45325b
```

消息体如下：


```shell
{
	"mySongs":  
	[
		{"周杰伦": "《双截棍》"},
		{"陈奕迅": "《富士山下》"},
		{"Taylor Swift": "《Blank Space》"},
		{"林俊杰": "《那些你很冒险的梦》"},
    	{"林俊杰": "《曹操》"}
	] 
}
```

返回信息，说明更新成功

```
{
    "ok": true,
    "id": "b6ef8df4740489d74e128b1644000c78",
    "rev": "3-00501f61a85e6114bf50c00c07d7f17e"
}
```

需要注意的是，_rav参数和请求头中的If-Match不能共存，即只能选用一种方式更新数据



此处需要对这张图进行分析（figure 7）

https://docs.couchdb.org/en/stable/intro/consistency.html#intro-consistency-07


Because CouchDB tracks document revisions, it ensures that updates like these will work only if they are based on current information. If we had made modifications to the playlist backups between synchronization, things wouldn’t go as smoothly.

We back up some changes on our laptop and forget to synchronize. A few days later, we’re editing playlists on our desktop computer, make a backup, and want to synchronize this to our laptop. As illustrated in Figure 7. Synchronization conflicts between two databases, when our backup application tries to replicate between the two databases, CouchDB sees that the changes being sent from our desktop computer are modifications of out-of-date documents and helpfully informs us that there has been a conflict.

Recovering from this error is easy to accomplish from an application perspective. Just download CouchDB’s version of the playlist and provide an opportunity to merge the changes or save local modifications into a new playlist.