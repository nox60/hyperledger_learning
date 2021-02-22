### 水果店价格分析案例

芒果，西瓜，苹果，菠萝在多家水果店有售。完成以下任务：
1. 分析所有水果在各家水果店的平均价格；
2. 找到每个水果最低的单价；
3. 一种水果列出价格最高的三家店，按照价格降序排列；


### 创建数据库
```shell
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X PUT http://192.168.88.128:5984/fruits-db?q=3&n=1
```

### 数据准备
```shell script
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"1", "fruit_name":"apple", "price":"10.9"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"2", "fruit_name":"banana", "price":"5.6"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"3", "fruit_name":"apple", "price":"11.9"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"4", "fruit_name":"lemon", "price":"2"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"5", "fruit_name":"mango", "price":"5.62"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"6", "fruit_name":"watermelon", "price":"4.78"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"7", "fruit_name":"watermelon", "price":"3"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"8", "fruit_name":"watermelon", "price":"4.7"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"9", "fruit_name":"apple", "price":"7.27"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"10", "fruit_name":"apple", "price":"4.0"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"11", "fruit_name":"apple", "price":"19.23"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"12", "fruit_name":"mango", "price":"11.2"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"13", "fruit_name":"mango", "price":"6.63"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"14", "fruit_name":"mango", "price":"4.82"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"15", "fruit_name":"mango", "price":"7.3"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"16", "fruit_name":"watermelon", "price":"5.0"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"17", "fruit_name":"watermelon", "price":"30"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"18", "fruit_name":"banana", "price":"0.98"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"19", "fruit_name":"banana", "price":"11.2"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"20", "fruit_name":"banana", "price":"50.3"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"21", "fruit_name":"banana", "price":"4.96"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"22", "fruit_name":"banana", "price":"9.90"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"23", "fruit_name":"banana", "price":"13"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"24", "fruit_name":"lemon", "price":"28.7"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"25", "fruit_name":"lemon", "price":"43.1"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"26", "fruit_name":"lemon", "price":"0.76"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"27", "fruit_name":"lemon", "price":"3"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"28", "fruit_name":"lemon", "price":"55"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"29", "fruit_name":"lemon", "price":"27.34"}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"30", "fruit_name":"banana", "price":"3.33"}'
```

### 1. 分析所有水果在各家水果店的平均价格；

分析：map阶段使用fruit_name作为key值，价格作为value; reduce阶段计算价格的平均值。

map函数如下：

```javascript
function (document) {
    emit(document.fruit_name, document.price);
}
```

reduce函数如下：
```javascript
function (keys, values, rereduce) {
    let counts = 0;
    let sum = 1;
    values.forEach(function(i,index){
      counts++;
      sum = sum + i;
    })
    return sum/counts;
}
```

```shell
curl -H "Content-Type:application/json" \
-H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" \
-X GET http://localhost:5984/fruits-db/_design/fruits_funs/_view/average?group_level=1 | jq
```



