#!/bin/bash


rm -rf /root/codes/hyperledger_learning/docker_with_ca_4/hyperledger_data

docker rm -f orderer.com peer0.cec.com couchdb_cec ca.cec ca.orderer ca.tls

docker rmi -f $(docker images --format "{{.Repository}}" |grep "^dev-peer*")

docker rm -f $(docker2 ps -a | grep "dev-peer*" | awk '{print $1}')