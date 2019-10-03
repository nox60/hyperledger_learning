#!/bin/bash

docker run -it -d \
--name nginx_with_ssl \
-v /root/codes/hyperledger_learning/docker_with_ca/openssl_ca/nginx/nginx_data/conf/nginx.conf:/etc/nginx/nginx.conf \
-v /root/codes/hyperledger_learning/docker_with_ca/openssl_ca/nginx/nginx_data/ssl:/opt/ssl \
-p 80:80 \
nginx
