# 创建私钥
openssl genrsa -out simple.key 2048

# 创建证书请求
openssl req -new -out simple.csr -key simple.key

# 生成公钥, 此处crt文件
openssl x509 -req -in simple.csr -out simple.crt -signkey simple.key -days 3650
