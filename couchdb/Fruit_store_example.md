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
		{"carrefour": 22.00},
		{"walmart": 26.10},
		{"Auchan": 18.59}
	] 
}
```
```Json
{
	"fruitName":"apple", 
	"prices":  
	[
		{"carrefour": 13.21},
		{"walmart": 12.90},
		{"Auchan": 9.11}
	] 
}
```
```Json
{
	"fruitName":"banana", 
	"prices":  
	[
		{"carrefour": 19.21},
		{"walmart": 11.02},
		{"Auchan": 7.55}
	] 
}
```

通过下面map函数，可以将数据库中有 fruitName和prices字段的数据筛选到(map)
```javascript
function(doc) {
    if(doc.fruitName && doc.prices) {
        emit(doc.fruitName, doc.prices);
    }
}
```

上述map函数的执行结果是如下所示的四行数据：

|id|fruitName|prices|
|---|---|---|
|403665cb272a933325570190b602d66b|	apple	|[ { "carrefour": 13.21 }, { "walmart": 12.9 }, { "Auchan": 9.11 } ]	|
|403665cb272a933325570190b602e081|	banana	|[ { "carrefour": 19.21 }, { "walmart": 11.02 }, { "Auchan": 7.55 } ] |	
|403665cb272a933325570190b602bf9d|	mango |	[ { "carrefour": 17.11 }, { "walmart": 16 }, { "Auchan": 15.11 } ]	 |
|403665cb272a933325570190b602ccd0|	orange	|[ { "carrefour": 22 }, { "walmart": 26.1 }, { "Auchan": 18.59 } ]	 |


如果我们想看的是所有水果在家乐福的价格，并且需要按照价格排序。我们在Fauxton中建立下面的map函数
```javascript
function(doc) {
    var shop, price;
    if (doc.fruitName && doc.prices) {
        doc.prices.forEach(function(i) {
              for (var key in i) {
                  if ( key.indexOf("carrefour") != -1 ) {
                    emit(doc.fruitName, i);
                  }
              }
        });
    }
}
```

结果如下：

|id	|key|value|	
|---|---|---|
|	403665cb272a933325570190b602d66b|	apple|	{ "carrefour": 13.21 }	|
|	403665cb272a933325570190b602e081|	banana	|{ "carrefour": 19.21 }	|
|	403665cb272a933325570190b602bf9d|	mango|	{ "carrefour": 17.11 }	|
|	403665cb272a933325570190b602ccd0|	orange|	{ "carrefour": 22 }|

计算家乐福超市所有水果的总价

此时直接选择系统提供的_sum函数功能，然后运行，在Fauxton中如果不启用Reduce的话，View是不会去执行reduce过程的，需要点击右上角的Options，然后勾选reduce，然后点击Run query。

会发现结果并没有变化，还是四行，显示了不同水果在carrefour的价格。因为如果使用key进行_sum计算的话，不同的水果是不同的key，自然不会再进一步求总和。

所以此处更改一下map函数如下:

```javascript
function(doc) {
    var shop, price;
    if (doc.fruitName && doc.prices) {
        doc.prices.forEach(function(i) {
              for (var key in i) {   // 这个地方后面也改成forEach
                  if ( key.indexOf("carrefour") != -1 ) {
                    emit("carrefour", i);
                  }
              }
        });
    }
}
```

得到求总和的结果如下：


|key	|value	|
|---|---|
|carrefour	|{ "carrefour": 71.53 }|


如果此处要自己编写sum函数的话， 该怎么编写？

编辑view，然后在reduce下拉菜单中选择CUSTOM，其中系统默认的reduce函数如下：

```javascript
function (keys, values, rereduce) {
    if (rereduce) {
        return sum(values);
    } else {
        return values.length;
    }
}
```
对其进行修改，


couchdb在调试的时候，最好把系统设置为debug的日志模式，这样可以在输出中看到输出。此时会发现自己很难写出系统的_sum函数直接对carrefour进行总和的reduce函数。这和couchdb的分布式存储逻辑有关系。

后续会对这里的问题进行整理和分析。

总的来说，在map阶段，就让value值为数值类型是比较合适的做法，避免使用kv的json复杂类型做value。

具体操作如下。 

所以更改一下map函数如下：

```javascript
function(doc) {
    var shop, price;
    if (doc.fruitName && doc.prices) {
        doc.prices.forEach(function(i) {
              for (var key in i) {   // 这个地方后面也改成forEach
                  if ( key.indexOf("carrefour") != -1 ) {
                    emit("carrefour", i[key]);
                  }
              }
        });
    }
}
```

然后可见输出为：

|		id|	key|	value|
|---|---|---|
|	6395500d6da3317e55dc8915f30014e8	|carrefour	|17.11|	
|	6395500d6da3317e55dc8915f30037a4	|carrefour	|22	|
|	6395500d6da3317e55dc8915f3004faa	|carrefour	|13.21|	
|	6395500d6da3317e55dc8915f300637f	|carrefour	|19.21|	


此时增加一个reduce函数为：

|key|value|
|---|---|
|carrefour|	71.53|


写入下面的数据，做一些不太一样的聚合查询

```json
{ "fruitName":"mango", "city":"Beijing","prices":[{"carrefour": 12.14},{"walmart": 5.00},{"Auchan": 14.09}] }
{ "fruitName":"mango", "city":"Shanghai","prices":[{"carrefour": 9.0},{"walmart": 10.20},{"Auchan": 16.15}] }
{ "fruitName":"mango", "city":"Chengdu","prices":[{"carrefour": 8.77},{"walmart": 12.10},{"Auchan": 17.88}] }
{ "fruitName":"mango", "city":"Chongqing","prices":[{"carrefour": 13.82},{"walmart": 13.10},{"Auchan": 8.99}] }
{ "fruitName":"mango", "city":"Xian","prices":[{"carrefour": 12.1},{"walmart": 12.16},{"Auchan": 14.18}] }
{ "fruitName":"apple", "city":"Beijing","prices":[{"carrefour": 22.0},{"walmart": 5.00},{"Auchan": 14.09}] }
{ "fruitName":"apple", "city":"Shanghai","prices":[{"carrefour": 8.0},{"walmart": 10.20},{"Auchan": 16.15}] }
{ "fruitName":"apple", "city":"Chengdu","prices":[{"carrefour": 14.0},{"walmart": 12.10},{"Auchan": 17.88}] }
{ "fruitName":"apple", "city":"Chongqing","prices":[{"carrefour": 23.12},{"walmart": 13.10},{"Auchan": 8.99}] }
{ "fruitName":"apple", "city":"Xian","prices":[{"carrefour": 16.10},{"walmart": 18.76},{"Auchan": 12.66}] }


```

