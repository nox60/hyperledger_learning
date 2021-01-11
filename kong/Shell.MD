#!/bin/bash

docker rm -f kong-postgres

rm -rf /root/kong/postgre_db/*

docker run --name kong-postgres \
        -v /root/kong/postgre_db:/var/lib/postgresql/data \
        -e POSTGRES_PASSWORD=123456 \
        -e POSTGRES_USER=kong \
        -e POSTGRES_DB=kong \
        -e PGDATA=/var/lib/postgresql/data/pgdata \
        -p 5432:5432 \
        -d postgres:9.6

docker rm -f adminer

docker run   \
        --name=adminer -d -p 13000:8080 \
        --restart=always \
        -e ADMINER_PLUGINS='tables-filter tinymce' adminer



#docker rm -f pgadmin
#docker run  --name pgadmin -p 5080:80 \
#    -e 'PGADMIN_DEFAULT_EMAIL=test@abc.com' \
#    -e 'PGADMIN_DEFAULT_PASSWORD=123456' \
#    -e 'PGADMIN_CONFIG_ENHANCED_COOKIE_PROTECTION=True' \
#    -e 'PGADMIN_CONFIG_LOGIN_BANNER="Authorised users only!"' \
#    -e 'PGADMIN_CONFIG_CONSOLE_LOG_LEVEL=10' \
#    -d dpage/pgadmin4:4.17


sleep 5

docker run --rm \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_PG_HOST=kong-postgres" \
    -e "KONG_PG_PASSWORD=123456" \
    -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
    --link kong-postgres:kong-postgres \
    kong kong migrations bootstrap


docker rm -f kong

docker run -d  --name kong \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_PG_HOST=kong-postgres" \
    -e "KONG_PG_PASSWORD=123456" \
    -e "KONG_PG_USER=kong" \
    -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
    -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
    -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
    -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
    --link kong-postgres:kong-postgres \
    -p 8000:8000 \
    -p 8443:8443 \
    -p 8001:8001 \
    -p 8080-8090:8080-8090 \
    -p 8444:8444 \
    kong

sleep 5

docker run --rm --link kong-postgres:kong-postgres pantsel/konga:latest \
        -c prepare \
        -a postgres \
        -u postgresql://kong:123456@kong-postgres:5432/postgres 
        


docker run -d  --name konga \
        -p 1337:1337 \
        -e "DB_ADAPTER=postgres" \
        -e "DB_HOST=kong-postgres" \
        -e "DB_PORT=5432" \
        -e "DB_USER=kong" \
        -e "DB_PASSWORD=123456" \
        -e "DB_DATABASE=postgres" \
        -e "NODE_ENV=production" \
        --link kong-postgres:kong-postgres \
        pantsel/konga


#测试tomcat1, 8.0
docker run -it -d --name tomcat8 tomcat:8.0
#测试tomcat2, 9.0
docker run -it -d --name tomcat9 tomcat:9.0
#测试tomcat3, 10.0
docker run -it -d --name tomcat10 tomcat:10.0
