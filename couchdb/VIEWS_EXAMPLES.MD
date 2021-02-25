### 水果店价格分析案例

芒果，西瓜，苹果，菠萝在多家水果店有售。完成以下任务：
1. 分析所有水果在各家水果店的平均价格；
2. 找到每个水果最低的单价；
3. 一种水果列出价格最高的三家店，按照价格降序排列；


### 创建数据库
```shell script
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X PUT http://localhost:5984/fruits-db?q=3&n=1
```

### 数据准备
```shell script
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"1", "fruit_name":"apple", "price":10.9}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"2", "fruit_name":"banana", "price":5.6}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"3", "fruit_name":"apple", "price":11.9}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"4", "fruit_name":"lemon", "price":2}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"5", "fruit_name":"mango", "price":5.62}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"6", "fruit_name":"watermelon", "price":4.78}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"7", "fruit_name":"watermelon", "price":3}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"8", "fruit_name":"watermelon", "price":4.7}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"9", "fruit_name":"apple", "price":7.27}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"10", "fruit_name":"apple", "price":4.0}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"11", "fruit_name":"apple", "price":19.23}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"12", "fruit_name":"mango", "price":11.2}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"13", "fruit_name":"mango", "price":6.63}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"14", "fruit_name":"mango", "price":4.82}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"15", "fruit_name":"mango", "price":7.3}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"16", "fruit_name":"watermelon", "price":5.0}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"17", "fruit_name":"watermelon", "price":30}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"18", "fruit_name":"banana", "price":0.98}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"19", "fruit_name":"banana", "price":11.2}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"20", "fruit_name":"banana", "price":50.3}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"21", "fruit_name":"banana", "price":4.96}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"22", "fruit_name":"banana", "price":9.90}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"23", "fruit_name":"banana", "price":13}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"24", "fruit_name":"lemon", "price":28.7}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"25", "fruit_name":"lemon", "price":43.1}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"26", "fruit_name":"lemon", "price":0.76}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"27", "fruit_name":"lemon", "price":3}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"28", "fruit_name":"lemon", "price":55}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"29", "fruit_name":"lemon", "price":27.34}'
curl -H "Content-Type:application/json" -H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" -X POST http://localhost:5984/fruits-db -d '{"_id":"30", "fruit_name":"banana", "price":3.33}'
```

### 1. 统计每种水果的记录数量
通过Fauxton创建一个view，design分组名称为design1，view名称为view1

map函数如下：
```javascript
function (document) {
    emit(document.fruit_name, document.price);
}
```

reduce函数如下：
```javascript
function (keys, values, rereduce) {
  if (rereduce) {
    return sum(values);
  } else {
    return values.length;
  }
}
```

通过下面的命令请求：
```shell
curl -H "Content-Type:application/json" \
-H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" \
-X GET http://localhost:5984/fruits-db/_design/design1/_view/view1?group_level=1 | jq
```

得到如下的结果，符合期望值：
```json
{
  "rows": [
    {
      "key": "apple",
      "value": 5
    },
    {
      "key": "banana",
      "value": 8
    },
    {
      "key": "lemon",
      "value": 7
    },
    {
      "key": "mango",
      "value": 5
    },
    {
      "key": "watermelon",
      "value": 5
    }
  ]
}
```

### 2. 分析所有水果在各家水果店的平均价格；
通过Fauxton创建一个view，design分组归属为之前已经创建的design1，view名称为view2


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
    let sum = 0;
    for(k = 0,len=values.length; k < len; k++) {
        sum = sum + values[k]
        counts++
    }
    return (Math.floor(sum/counts * 100) / 100)
}
```

请求命令如下:
```shell
curl -H "Content-Type:application/json" \
-H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" \
-X GET http://localhost:5984/fruits-db/_design/fruits_funs/_view/view2?group_level=1 | jq
```

得到如下符合预期的结果：
```json
{
  "rows": [
    {
      "key": "apple",
      "value": 13.87
    },
    {
      "key": "banana",
      "value": 12.06
    },
    {
      "key": "lemon",
      "value": 18.43
    },
    {
      "key": "mango",
      "value": 7.14
    },
    {
      "key": "watermelon",
      "value": 6.98
    }
  ]
}
```


### 3. 找到每个水果最低的单价；
通过Fauxton创建一个view，design分组归属为之前已经创建的design1，view名称为view2


map函数如下：

```javascript
function (document) {
    emit(document.fruit_name, document.price);
}
```

reduce函数如下：
```javascript
function (keys, values, rereduce) {
  if (rereduce) {
    let arr = new Array()
    for(i = 0,len=values.length; i < len; i++) {
        if(Array.isArray(values[i])){
            for(j = 0,len2=values[i].length; j < len2; j++) {
                arr.push(values[i][j])            
            }
        } else {
            arr.push(values[i])
        }
    }
    // 排序之后返回
    // arr.sort()
    return arr
  } else {
    return values.length;
  }
}
```

请求命令如下:
```shell
curl -H "Content-Type:application/json" \
-H "Authorization:Basic YWRtaW46cGFzc3dvcmQ=" \
-X GET http://localhost:5984/fruits-db/_design/design1/_view/view4?group_level=1 | jq
```

得到如下符合预期的结果：
```json

```


