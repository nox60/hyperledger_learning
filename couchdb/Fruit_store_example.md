水果店项目，首先创建相关的数据。

```shell script
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"fruitName":"apple", "prices":  { [{"carrefour": 13.09},{"walmart": 14.38},{"Auchan": 20.79}] }   }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"fruitName":"orange", "prices":  { [{"carrefour": 11.22},{"walmart": 13.87},{"Auchan": 10.01}]  }   }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"fruitName":"banana", "prices":  { [{"carrefour": 9.25},{"walmart": 4.8},{"Auchan": 8.7}]  }"  }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"fruitName":"mango", "prices":  { [{"carrefour": 17.11},{"walmart": 16.00},{"Auchan": 15.11}]  }   }'
```

在数据的操作方面，可以利用linux下的curl工具进行post请求发送提交数据，但是其他


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

