#!/bin/bash

docker run -it -d \
--name tomcat9_with_ssl \
-v /root/codes/hyperledger_learning/docker_with_ca/openssl_ca/tomcat9/tomcat_docker_data/conf:/usr/local/tomcat/conf \
-v /root/codes/hyperledger_learning/docker_with_ca/openssl_ca/tomcat9/tomcat_docker_data/logs:/usr/local/tomcat/logs \
-p 8443:8443 \
-p 8080:8080 \
tomcat:9
