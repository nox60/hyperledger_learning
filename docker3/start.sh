#!/bin/bash

docker network rm ymy-net

docker network create --subnet=172.33.0.0/16 ymy-net

docker rmi -f $(docker images --format "{{.Repository}}" |grep "^dev-peer*")

docker rm -f $(docker_ymy ps -a | grep "dev-peer*" | awk '{print $1}')

docker rm -f orderer.ymy.com

docker run -it -d  \
  --name orderer.ymy.com \rledger/orderer/tls/ca.crt]" \
      -e ORDERER_KAFKA_TOPIC_REPLICATIONFACTOR="
      --network ymy-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e ORDERER_GENERAL_LISTENADDRESS="0.0.0.0" \
      -e ORDERER_GENERAL_GENESISMETHOD="file" \
      -e ORDERER_GENERAL_GENESISFILE="/var/hyperledger/orderer/orderer.genesis.block" \
      -e ORDERER_GENERAL_LOCALMSPID="OrdererMSP" \
      -e ORDERER_GENERAL_LOCALMSPDIR="/var/hyperledger/orderer/msp" \
      -e ORDERER_GENERAL_TLS_ENABLED="true" \
      -e ORDERER_GENERAL_TLS_PRIVATEKEY="/var/hyperledger/orderer/tls/server.key" \
      -e ORDERER_GENERAL_TLS_CERTIFICATE="/var/hyperledger/orderer/tls/server.crt" \
      -e ORDERER_GENERAL_TLS_ROOTCAS="[/var/hype1" \
      -e ORDERER_KAFKA_VERBOSE="true" \
      -e ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE="/var/hyperledger/orderer/tls/server.crt" \
      -e ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY="/var/hyperledger/orderer/tls/server.key" \
      -e ORDERER_GENERAL_CLUSTER_ROOTCAS="[/var/hyperledger/orderer/tls/ca.crt]" \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/ordererOrganizations/ymy.com/orderers/orderer.ymy.com/msp:/var/hyperledger/orderer/msp \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/ordererOrganizations/ymy.com/orderers/orderer.ymy.com/tls:/var/hyperledger/orderer/tls \
      -v /opt/local/codes/docker_ymy/hyperledger_data/orderer.genesis.block:/var/hyperledger/orderer/orderer.genesis.block \
      -v /opt/local/codes/docker_ymy/hyperledger_data:/var/hyperledger/production/orderer \
      -v /var/run:/var/run \
      hyperledger/fabric-orderer:1.4.3


docker rm -f couchdb_cec
docker run -it -d  \
--name couchdb_cec \
--network ymy-net \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /opt/local/codes/docker_ymy/hyperledger_data/couchdb_cec/peer0:/opt/couchdb/data  \
-p 5984:5984 \
-p 9100:9100 \
-d hyperledger/fabric-couchdb  


docker rm -f peer0.cec.ymy.com
docker run -it -d \
  --name peer0.cec.ymy.com \
      --network ymy-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer0.cec.ymy.com" \
      -e CORE_PEER_ADDRESS="peer0.cec.ymy.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.cec.ymy.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.cec.ymy.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.cec.ymy.com:7051" \
      -e CORE_PEER_LOCALMSPID="cecMSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_cec:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="ymy-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/cec.ymy.com/peers/peer0.cec.ymy.com/tls:/etc/hyperledger/fabric/tls \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/cec.ymy.com/peers/peer0.cec.ymy.com/msp:/etc/hyperledger/fabric/msp \
      -v /opt/local/codes/docker_ymy/hyperledger_data/cecpeer0:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3       




docker rm -f couchdb_aes
docker run -ti -d \
--name couchdb_aes \
--network ymy-net \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /opt/local/codes/docker_ymy/hyperledger_data/couchdb_aes_peer0/:/opt/couchdb/data  \
-p 5985:5984 \
-p 9101:9100 \
-d hyperledger/fabric-couchdb  


docker rm -f peer0.aes.ymy.com
docker run -it -d \
  --name peer0.aes.ymy.com \
      --network ymy-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer0.aes.ymy.com" \
      -e CORE_PEER_ADDRESS="peer0.aes.ymy.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.aes.ymy.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.aes.ymy.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.aes.ymy.com:7051" \
      -e CORE_PEER_LOCALMSPID="aesMSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_aes:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="ymy-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/aes.ymy.com/peers/peer0.aes.ymy.com/tls:/etc/hyperledger/fabric/tls \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/aes.ymy.com/peers/peer0.aes.ymy.com/msp:/etc/hyperledger/fabric/msp \
      -v /opt/local/codes/docker_ymy/hyperledger_data/aespeer0:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3       


docker rm -f couchdb_hos
docker run -ti -d \
--name couchdb_hos \
--network ymy-net \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /opt/local/codes/docker_ymy/hyperledger_data/couchdb_hos/:/opt/couchdb/data  \
-p 5986:5984 \
-p 9102:9100 \
-d hyperledger/fabric-couchdb  


docker rm -f peer0.hos.ymy.com
docker run -it -d \
  --name peer0.hos.ymy.com \
      --network ymy-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer0.hos.ymy.com" \
      -e CORE_PEER_ADDRESS="peer0.hos.ymy.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.hos.ymy.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.hos.ymy.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.hos.ymy.com:7051" \
      -e CORE_PEER_LOCALMSPID="hosMSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_hos:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="ymy-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/hos.ymy.com/peers/peer0.hos.ymy.com/tls:/etc/hyperledger/fabric/tls \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/hos.ymy.com/peers/peer0.hos.ymy.com/msp:/etc/hyperledger/fabric/msp \
      -v /opt/local/codes/docker_ymy/hyperledger_data/hospeer0:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3       


docker rm -f couchdb_gov
docker run -ti -d \
--name couchdb_gov \
--network ymy-net \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /opt/local/codes/docker_ymy/hyperledger_data/couchdb_gov/:/opt/couchdb/data  \
-p 5987:5984 \
-p 9103:9100 \
-d hyperledger/fabric-couchdb  

docker rm -f peer0.gov.ymy.com
docker run -it -d \
  --name peer0.gov.ymy.com \
      --network ymy-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer0.gov.ymy.com" \
      -e CORE_PEER_ADDRESS="peer0.gov.ymy.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.gov.ymy.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.gov.ymy.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.gov.ymy.com:7051" \
      -e CORE_PEER_LOCALMSPID="govMSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_gov:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="ymy-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/gov.ymy.com/peers/peer0.gov.ymy.com/tls:/etc/hyperledger/fabric/tls \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/gov.ymy.com/peers/peer0.gov.ymy.com/msp:/etc/hyperledger/fabric/msp \
      -v /opt/local/codes/docker_ymy/hyperledger_data/govpeer0:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3











#!/bin/bash

docker network rm ymy-net

docker network create --subnet=172.33.0.0/16 ymy-net

docker rmi -f $(docker images --format "{{.Repository}}" |grep "^dev-peer*")

docker rm -f $(docker_ymy ps -a | grep "dev-peer*" | awk '{print $1}')

docker rm -f orderer.ymy.com

docker run -it -d  \
  --name orderer.ymy.com \rledger/orderer/tls/ca.crt]" \
      -e ORDERER_KAFKA_TOPIC_REPLICATIONFACTOR="
      --network ymy-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e ORDERER_GENERAL_LISTENADDRESS="0.0.0.0" \
      -e ORDERER_GENERAL_GENESISMETHOD="file" \
      -e ORDERER_GENERAL_GENESISFILE="/var/hyperledger/orderer/orderer.genesis.block" \
      -e ORDERER_GENERAL_LOCALMSPID="OrdererMSP" \
      -e ORDERER_GENERAL_LOCALMSPDIR="/var/hyperledger/orderer/msp" \
      -e ORDERER_GENERAL_TLS_ENABLED="true" \
      -e ORDERER_GENERAL_TLS_PRIVATEKEY="/var/hyperledger/orderer/tls/server.key" \
      -e ORDERER_GENERAL_TLS_CERTIFICATE="/var/hyperledger/orderer/tls/server.crt" \
      -e ORDERER_GENERAL_TLS_ROOTCAS="[/var/hype1" \
      -e ORDERER_KAFKA_VERBOSE="true" \
      -e ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE="/var/hyperledger/orderer/tls/server.crt" \
      -e ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY="/var/hyperledger/orderer/tls/server.key" \
      -e ORDERER_GENERAL_CLUSTER_ROOTCAS="[/var/hyperledger/orderer/tls/ca.crt]" \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/ordererOrganizations/ymy.com/orderers/orderer.ymy.com/msp:/var/hyperledger/orderer/msp \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/ordererOrganizations/ymy.com/orderers/orderer.ymy.com/tls:/var/hyperledger/orderer/tls \
      -v /opt/local/codes/docker_ymy/hyperledger_data/orderer.genesis.block:/var/hyperledger/orderer/orderer.genesis.block \
      -v /opt/local/codes/docker_ymy/hyperledger_data:/var/hyperledger/production/orderer \
      -v /var/run:/var/run \
      hyperledger/fabric-orderer:1.4.3


docker rm -f couchdb_cec
docker run -it -d  \
--name couchdb_cec \
--network ymy-net \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /opt/local/codes/docker_ymy/hyperledger_data/couchdb_cec/peer0:/opt/couchdb/data  \
-p 5984:5984 \
-p 9100:9100 \
-d hyperledger/fabric-couchdb  


docker rm -f peer0.cec.ymy.com
docker run -it -d \
  --name peer0.cec.ymy.com \
      --network ymy-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer0.cec.ymy.com" \
      -e CORE_PEER_ADDRESS="peer0.cec.ymy.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.cec.ymy.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.cec.ymy.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.cec.ymy.com:7051" \
      -e CORE_PEER_LOCALMSPID="cecMSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_cec:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="ymy-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/cec.ymy.com/peers/peer0.cec.ymy.com/tls:/etc/hyperledger/fabric/tls \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/cec.ymy.com/peers/peer0.cec.ymy.com/msp:/etc/hyperledger/fabric/msp \
      -v /opt/local/codes/docker_ymy/hyperledger_data/cecpeer0:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3       




docker rm -f couchdb_aes
docker run -ti -d \
--name couchdb_aes \
--network ymy-net \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /opt/local/codes/docker_ymy/hyperledger_data/couchdb_aes_peer0/:/opt/couchdb/data  \
-p 5985:5984 \
-p 9101:9100 \
-d hyperledger/fabric-couchdb  


docker rm -f peer0.aes.ymy.com
docker run -it -d \
  --name peer0.aes.ymy.com \
      --network ymy-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer0.aes.ymy.com" \
      -e CORE_PEER_ADDRESS="peer0.aes.ymy.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.aes.ymy.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.aes.ymy.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.aes.ymy.com:7051" \
      -e CORE_PEER_LOCALMSPID="aesMSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_aes:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="ymy-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/aes.ymy.com/peers/peer0.aes.ymy.com/tls:/etc/hyperledger/fabric/tls \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/aes.ymy.com/peers/peer0.aes.ymy.com/msp:/etc/hyperledger/fabric/msp \
      -v /opt/local/codes/docker_ymy/hyperledger_data/aespeer0:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3       


docker rm -f couchdb_hos
docker run -ti -d \
--name couchdb_hos \
--network ymy-net \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /opt/local/codes/docker_ymy/hyperledger_data/couchdb_hos/:/opt/couchdb/data  \
-p 5986:5984 \
-p 9102:9100 \
-d hyperledger/fabric-couchdb  


docker rm -f peer0.hos.ymy.com
docker run -it -d \
  --name peer0.hos.ymy.com \
      --network ymy-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer0.hos.ymy.com" \
      -e CORE_PEER_ADDRESS="peer0.hos.ymy.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.hos.ymy.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.hos.ymy.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.hos.ymy.com:7051" \
      -e CORE_PEER_LOCALMSPID="hosMSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_hos:5984" \


































#!/bin/bash

docker network rm ymy-net

docker network create --subnet=172.33.0.0/16 ymy-net

docker rmi -f $(docker images --format "{{.Repository}}" |grep "^dev-peer*")

docker rm -f $(docker_ymy ps -a | grep "dev-peer*" | awk '{print $1}')

docker rm -f orderer.ymy.com

docker run -it -d  \
  --name orderer.ymy.com \rledger/orderer/tls/ca.crt]" \
      -e ORDERER_KAFKA_TOPIC_REPLICATIONFACTOR="
      --network ymy-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e ORDERER_GENERAL_LISTENADDRESS="0.0.0.0" \
      -e ORDERER_GENERAL_GENESISMETHOD="file" \
      -e ORDERER_GENERAL_GENESISFILE="/var/hyperledger/orderer/orderer.genesis.block" \
      -e ORDERER_GENERAL_LOCALMSPID="OrdererMSP" \
      -e ORDERER_GENERAL_LOCALMSPDIR="/var/hyperledger/orderer/msp" \
      -e ORDERER_GENERAL_TLS_ENABLED="true" \
      -e ORDERER_GENERAL_TLS_PRIVATEKEY="/var/hyperledger/orderer/tls/server.key" \
      -e ORDERER_GENERAL_TLS_CERTIFICATE="/var/hyperledger/orderer/tls/server.crt" \
      -e ORDERER_GENERAL_TLS_ROOTCAS="[/var/hype1" \
      -e ORDERER_KAFKA_VERBOSE="true" \
      -e ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE="/var/hyperledger/orderer/tls/server.crt" \
      -e ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY="/var/hyperledger/orderer/tls/server.key" \
      -e ORDERER_GENERAL_CLUSTER_ROOTCAS="[/var/hyperledger/orderer/tls/ca.crt]" \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/ordererOrganizations/ymy.com/orderers/orderer.ymy.com/msp:/var/hyperledger/orderer/msp \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/ordererOrganizations/ymy.com/orderers/orderer.ymy.com/tls:/var/hyperledger/orderer/tls \
      -v /opt/local/codes/docker_ymy/hyperledger_data/orderer.genesis.block:/var/hyperledger/orderer/orderer.genesis.block \
      -v /opt/local/codes/docker_ymy/hyperledger_data:/var/hyperledger/production/orderer \
      -v /var/run:/var/run \
      hyperledger/fabric-orderer:1.4.3


docker rm -f couchdb_cec
docker run -it -d  \
--name couchdb_cec \
--network ymy-net \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /opt/local/codes/docker_ymy/hyperledger_data/couchdb_cec/peer0:/opt/couchdb/data  \
-p 5984:5984 \
-p 9100:9100 \
-d hyperledger/fabric-couchdb  


docker rm -f peer0.cec.ymy.com
docker run -it -d \
  --name peer0.cec.ymy.com \
      --network ymy-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer0.cec.ymy.com" \
      -e CORE_PEER_ADDRESS="peer0.cec.ymy.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.cec.ymy.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.cec.ymy.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.cec.ymy.com:7051" \
      -e CORE_PEER_LOCALMSPID="cecMSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_cec:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="ymy-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/cec.ymy.com/peers/peer0.cec.ymy.com/tls:/etc/hyperledger/fabric/tls \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/cec.ymy.com/peers/peer0.cec.ymy.com/msp:/etc/hyperledger/fabric/msp \
      -v /opt/local/codes/docker_ymy/hyperledger_data/cecpeer0:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3       




docker rm -f couchdb_aes
docker run -ti -d \
--name couchdb_aes \
--network ymy-net \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /opt/local/codes/docker_ymy/hyperledger_data/couchdb_aes_peer0/:/opt/couchdb/data  \
-p 5985:5984 \
-p 9101:9100 \
-d hyperledger/fabric-couchdb  


docker rm -f peer0.aes.ymy.com
docker run -it -d \
  --name peer0.aes.ymy.com \
      --network ymy-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer0.aes.ymy.com" \
      -e CORE_PEER_ADDRESS="peer0.aes.ymy.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.aes.ymy.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.aes.ymy.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.aes.ymy.com:7051" \
      -e CORE_PEER_LOCALMSPID="aesMSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_aes:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="ymy-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/aes.ymy.com/peers/peer0.aes.ymy.com/tls:/etc/hyperledger/fabric/tls \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/aes.ymy.com/peers/peer0.aes.ymy.com/msp:/etc/hyperledger/fabric/msp \
      -v /opt/local/codes/docker_ymy/hyperledger_data/aespeer0:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3       


docker rm -f couchdb_hos
docker run -ti -d \
--name couchdb_hos \
--network ymy-net \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /opt/local/codes/docker_ymy/hyperledger_data/couchdb_hos/:/opt/couchdb/data  \
-p 5986:5984 \
-p 9102:9100 \
-d hyperledger/fabric-couchdb  


docker rm -f peer0.hos.ymy.com
docker run -it -d \
  --name peer0.hos.ymy.com \
      --network ymy-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer0.hos.ymy.com" \
      -e CORE_PEER_ADDRESS="peer0.hos.ymy.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.hos.ymy.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.hos.ymy.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.hos.ymy.com:7051" \
      -e CORE_PEER_LOCALMSPID="hosMSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_hos:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="ymy-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/hos.ymy.com/peers/peer0.hos.ymy.com/tls:/etc/hyperledger/fabric/tls \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/hos.ymy.com/peers/peer0.hos.ymy.com/msp:/etc/hyperledger/fabric/msp \
      -v /opt/local/codes/docker_ymy/hyperledger_data/hospeer0:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3       


docker rm -f couchdb_gov
docker run -ti -d \
--name couchdb_gov \
--network ymy-net \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /opt/local/codes/docker_ymy/hyperledger_data/couchdb_gov/:/opt/couchdb/data  \
-p 5987:5984 \
-p 9103:9100 \
-d hyperledger/fabric-couchdb  

docker rm -f peer0.gov.ymy.com
docker run -it -d \
  --name peer0.gov.ymy.com \
      --network ymy-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer0.gov.ymy.com" \
      -e CORE_PEER_ADDRESS="peer0.gov.ymy.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.gov.ymy.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.gov.ymy.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.gov.ymy.com:7051" \
      -e CORE_PEER_LOCALMSPID="govMSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_gov:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="ymy-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/gov.ymy.com/peers/peer0.gov.ymy.com/tls:/etc/hyperledger/fabric/tls \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/gov.ymy.com/peers/peer0.gov.ymy.com/msp:/etc/hyperledger/fabric/msp \
      -v /opt/local/codes/docker_ymy/hyperledger_data/govpeer0:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3











#!/bin/bash

docker network rm ymy-net

docker network create --subnet=172.33.0.0/16 ymy-net

docker rmi -f $(docker images --format "{{.Repository}}" |grep "^dev-peer*")

docker rm -f $(docker_ymy ps -a | grep "dev-peer*" | awk '{print $1}')

docker rm -f orderer.ymy.com

docker run -it -d  \
  --name orderer.ymy.com \rledger/orderer/tls/ca.crt]" \
      -e ORDERER_KAFKA_TOPIC_REPLICATIONFACTOR="
      --network ymy-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e ORDERER_GENERAL_LISTENADDRESS="0.0.0.0" \
      -e ORDERER_GENERAL_GENESISMETHOD="file" \
      -e ORDERER_GENERAL_GENESISFILE="/var/hyperledger/orderer/orderer.genesis.block" \
      -e ORDERER_GENERAL_LOCALMSPID="OrdererMSP" \
      -e ORDERER_GENERAL_LOCALMSPDIR="/var/hyperledger/orderer/msp" \
      -e ORDERER_GENERAL_TLS_ENABLED="true" \
      -e ORDERER_GENERAL_TLS_PRIVATEKEY="/var/hyperledger/orderer/tls/server.key" \
      -e ORDERER_GENERAL_TLS_CERTIFICATE="/var/hyperledger/orderer/tls/server.crt" \
      -e ORDERER_GENERAL_TLS_ROOTCAS="[/var/hype1" \
      -e ORDERER_KAFKA_VERBOSE="true" \
      -e ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE="/var/hyperledger/orderer/tls/server.crt" \
      -e ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY="/var/hyperledger/orderer/tls/server.key" \
      -e ORDERER_GENERAL_CLUSTER_ROOTCAS="[/var/hyperledger/orderer/tls/ca.crt]" \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/ordererOrganizations/ymy.com/orderers/orderer.ymy.com/msp:/var/hyperledger/orderer/msp \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/ordererOrganizations/ymy.com/orderers/orderer.ymy.com/tls:/var/hyperledger/orderer/tls \
      -v /opt/local/codes/docker_ymy/hyperledger_data/orderer.genesis.block:/var/hyperledger/orderer/orderer.genesis.block \
      -v /opt/local/codes/docker_ymy/hyperledger_data:/var/hyperledger/production/orderer \
      -v /var/run:/var/run \
      hyperledger/fabric-orderer:1.4.3


docker rm -f couchdb_cec
docker run -it -d  \
--name couchdb_cec \
--network ymy-net \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /opt/local/codes/docker_ymy/hyperledger_data/couchdb_cec/peer0:/opt/couchdb/data  \
-p 5984:5984 \
-p 9100:9100 \
-d hyperledger/fabric-couchdb  


docker rm -f peer0.cec.ymy.com
docker run -it -d \
  --name peer0.cec.ymy.com \
      --network ymy-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer0.cec.ymy.com" \
      -e CORE_PEER_ADDRESS="peer0.cec.ymy.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.cec.ymy.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.cec.ymy.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.cec.ymy.com:7051" \
      -e CORE_PEER_LOCALMSPID="cecMSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_cec:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="ymy-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/cec.ymy.com/peers/peer0.cec.ymy.com/tls:/etc/hyperledger/fabric/tls \
      -v /opt/local/codes/docker_ymy/hyperledger_data/crypto-config/peerOrganizations/cec.ymy.com/peers/peer0.cec.ymy.com/msp:/etc/hyperledger/fabric/msp \
      -v /opt/local/codes/docker_ymy/hyperledger_data/cecpeer0:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3       




docker rm -f couchdb_aes
docker run -ti -d \
--name couchdb_aes \
--network ymy-net \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /opt/local/codes/docker_ymy/hyperledger_data/couchdb_aes_peer0/:/opt/couchdb/data  \
-p 5985:5984 \
-p 9101:9100 \
-d hyperledger/fabric-couchdb  


docker rm -f peer0.aes.ymy.com
docker run -it -d \
  --name peer0.aes.ymy.com \
      --network ymy-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
