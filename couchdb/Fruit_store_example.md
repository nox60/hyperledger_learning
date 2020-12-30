水果店项目，首先创建相关的数据。

```shell script
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"fruitName":"apple", "prices":  { [{"carrefour": 13.09},{"walmart": 14.38},{"Auchan": 20.79}] }   }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"fruitName":"orange", "prices":  { [{"carrefour": 11.22},{"walmart": 13.87},{"Auchan": 10.01}]  }   }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"fruitName":"banana", "prices":  { [{"carrefour": 9.25},{"walmart": 4.8},{"Auchan": 8.7}]  }"  }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"fruitName":"mango", "prices":  { [{"carrefour": 17.11},{"walmart": 16.00},{"Auchan": 15.11}]  }   }'
```

### 数据增加:

#### 利用 curl

#### 利用CouchDB自带的Fauxton

#### 利用postman工具：

在数据的操作方面，可以利用linux下的curl工具进行post请求发送提交数据，但是在命令行里面发送大量的Json数据需要对格式进行较多调整，比较麻烦。

此处选用Postman工具进行数据提交，具体的操作是：

请求下面的地址，发送的数据类型是application/json
```javascript
http://admin:password@192.168.16.70:5984/basic
```
数据是
```Json
{
	"fruitName":"mango", 
	"prices":  
	[
		{"carrefour": 17.11},
		{"walmart": 16.00},
		{"Auchan": 15.11}
	] 
}
```

继续发送下面的三个水果到couchdb
```Json
{
	"fruitName":"orange", 
	"prices":  
	[
		{"carrefour": 17.11},
		{"walmart": 16.00},
		{"Auchan": 15.11}
	] 
}
```
```Json
{
	"fruitName":"orange", 
	"prices":  
	[
		{"carrefour": 17.11},
		{"walmart": 16.00},
		{"Auchan": 15.11}
	] 
}
```
```Json
{
	"fruitName":"orange", 
	"prices":  
	[
		{"carrefour": 17.11},
		{"walmart": 16.00},
		{"Auchan": 15.11}
	] 
}
```


筛选出'Fresh'的key信息

```javascript
function(doc) {
    var shop, price;
    if (doc.item && doc.prices) {
        doc.prices.forEach(function(i) {
              for (var key in i) {
                  if ( key.indexOf("Fresh") != -1 ) {
                    emit(doc.item, i);
                  }
              }
        });
    }
}
```

