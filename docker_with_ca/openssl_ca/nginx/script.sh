openssl genrsa -out simple.key 2048

openssl req -new -out simple.csr -key simple.key

openssl x509 -req -in simple.csr -out simple.crt -signkey simple.key -days 3650


openssl pkcs12 -export \
-in simple.crt \
-inkey simple.key \
-out simple.p12 \
-name tomcat \
-CAfile simple.crt \
-caname root -chain
