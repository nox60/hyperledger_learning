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

