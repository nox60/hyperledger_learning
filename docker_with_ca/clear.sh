#!/bin/bash

docker rm -f ca.cec.dams.com
docker rm -f orderer.dams.com
docker rm -f peer0.cec.dams.com
docker rm -f peer0.ia3.dams.com
docker rm -f peer0.ic3.dams.com
docker rm -f peer0.gov.dams.com
docker rm -f couchdb_cec
docker rm -f couchdb_ia3
docker rm -f couchdb_ic3
docker rm -f couchdb_gov
docker rm -f cli
docker rm -f $(docker ps -a | grep "dev-peer*" | awk '{print $1}')




docker rmi -f $(docker images --format "{{.Repository}}" |grep "^dev-peer*")
