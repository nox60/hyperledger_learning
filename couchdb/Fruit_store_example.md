水果店项目，首先创建相关的数据。

```shell script
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"fruitName":"apple", "prices": " { [\"Fresh Mart\": 1.59], [\"Price Max\": 5.99], [\"Fruit Express\": 0.79]  } "  }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"fruitName":"orange", "prices": " { [\"Fresh Mart\": 2.59], [\"Price Max\": 6.00], [\"Fruit Express\": 1.09]  } "  }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"fruitName":"banana", "prices": " { [\"Fresh Mart\": 3.09], [\"Price Max\": 4.38], [\"Fruit Express\": 2.46]  } "  }'
curl -H "Content-Type:application/json" -X POST http://admin:password@localhost:5984/basic -d '{"fruitName":"mango", "prices": " { [\"Fresh Mart\": 4.00], [\"Price Max\": 8.99], [\"Fruit Express\": 5.88]  } "  }'
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

