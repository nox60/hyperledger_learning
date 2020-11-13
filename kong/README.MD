# 准备

创建docker网络
```
docker network create k-network \
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

