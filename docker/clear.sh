#!/bin/bash


docker rm -f orderer.example.com
docker rm -f peer0.org1.example.com
docker rm -f peer1.org1.example.com
docker rm -f peer0.org2.example.com
docker rm -f peer0.org3.example.com
docker rm -f couchdb_org1_peer0
docker rm -f couchdb_org1_peer1
docker rm -f couchdb_org2
docker rm -f couchdb_org3
docker rm -f cli

