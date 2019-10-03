openssl genrsa -out simple.key 2048

openssl req -new -out simple.csr -key simple.key

openssl x509 -req -in simple.csr -out simple.crt -signkey simple.key -days 3650
