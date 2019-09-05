#!/bin/bash


docker rm -f orderer_container

docker rm -f couchdb_org1

docker rm -f org1_peer_0

docker rm -f couchdb_org2

docker rm -f org2_peer_0

docker rm -f couchdb_org3

docker rm -f org3_peer_0

docker rm -f cli
