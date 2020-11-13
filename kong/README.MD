# 准备

创建docker网络
```
docker network create k-network 
```

跑个tomcat

```
docker run -it -d \
    --network=k-network \
    --name=tomcat9 \
    --restart=always \
    -p 18080:8080 \
    -e JAVA_OPTS='-server -Xmx768m -Xms32m -Xss256k -Djava.security.egd=file:/dev/./urandom' \
    tomcat
```

启动pg，作为kong需要的数据库
```gotemplate
docker run -d --name k-database \
    --network=k-network \
    --restart=always \
    -p 5432:5432 \
    -e "POSTGRES_USER=kong" \
    -e "POSTGRES_DB=kong" \
    -e POSTGRES_PASSWORD=password \
    postgres:9.6
```

初始化kong数据库
```gotemplate
docker run --rm \
    --network=k-network \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_PG_HOST=k-database" \
    -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
    -e "KONG_PASSWORD=password" \
    kong:latest kong migrations bootstrap
```