#!/bin/bash

docker rm -f orderer.example.com
docker run -it -d \
  --name orderer.example.com \
      -e username="ritchie"  \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e ORDERER_GENERAL_LISTENADDRESS="0.0.0.0" \
      -e ORDERER_GENERAL_GENESISMETHOD="file" \
      -e ORDERER_GENERAL_GENESISFILE="/var/hyperledger/orderer/orderer.genesis.block" \
      -e ORDERER_GENERAL_LOCALMSPID="OrdererMSP" \
      -e ORDERER_GENERAL_LOCALMSPDIR="/var/hyperledger/orderer/msp" \
      -e ORDERER_GENERAL_TLS_ENABLED="true" \
      -e ORDERER_GENERAL_TLS_PRIVATEKEY="/var/hyperledger/orderer/tls/server.key" \
      -e ORDERER_GENERAL_TLS_CERTIFICATE="/var/hyperledger/orderer/tls/server.crt" \
      -e ORDERER_GENERAL_TLS_ROOTCAS="/var/hyperledger/orderer/tls/ca.crt" \
      -e ORDERER_KAFKA_TOPIC_REPLICATIONFACTOR="1" \
      -e ORDERER_KAFKA_VERBOSE="true" \
      -e ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE="/var/hyperledger/orderer/tls/server.crt" \
      -e ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY="/var/hyperledger/orderer/tls/server.key" \
      -e ORDERER_GENERAL_CLUSTER_ROOTCAS="/var/hyperledger/orderer/tls/ca.crt" \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp:/var/hyperledger/orderer/msp \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls:/var/hyperledger/orderer/tls \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/orderer.genesis.block:/var/hyperledger/orderer/orderer.genesis.block \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data:/var/hyperledger/production/orderer \
      -v /etc/hosts:/etc/hosts \
      -v /var/run:/var/run \
      -p 7050:7050 \
      hyperledger/fabric-orderer:1.4.3

#couchdb节点目前是link的方式和peer关联。

docker rm -f couchdb_org1_peer0
docker run -ti -d \
--name couchdb_org1_peer0 \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /root/codes/hyperledger_learning/docker/hyperledger_data/couchdb_org1/peer0:/opt/couchdb/data  \
-d hyperledger/fabric-couchdb  


docker rm -f peer0.org1.example.com
docker run -it -d \
  --name peer0.org1.example.com \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="true" \
      -e CORE_PEER_GOSSIP_ORGLEADER="false" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer0.org1.example.com" \
      -e CORE_PEER_ADDRESS="peer0.org1.example.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.org1.example.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer1.org1.example.com:7351" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.org1.example.com:7051" \
      -e CORE_PEER_LOCALMSPID="Org1MSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="couchdb" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls:/etc/hyperledger/fabric/tls \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp:/etc/hyperledger/fabric/msp \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/org1peer0:/var/hyperledger/production \
      -v /etc/hosts:/etc/hosts \
      -v /var/run:/var/run \
      --link couchdb_org1_peer0:couchdb \
      -p 7051:7051 \
      -p 7052:7052 \
      hyperledger/fabric-peer:1.4.3       


docker rm -f couchdb_org1_peer1
docker run -ti -d \
--name couchdb_org1_peer1 \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /root/codes/hyperledger_learning/docker/hyperledger_data/couchdb_org1_peer1/:/opt/couchdb/data  \
-d hyperledger/fabric-couchdb  


docker rm -f peer1.org1.example.com
docker run -it -d \
  --name peer1.org1.example.com \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="true" \
      -e CORE_PEER_GOSSIP_ORGLEADER="false" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer1.org1.example.com" \
      -e CORE_PEER_ADDRESS="peer1.org1.example.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer1.org1.example.com:7352" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.org1.example.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer1.org1.example.com:7351" \
      -e CORE_PEER_LOCALMSPID="Org1MSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="couchdb" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls:/etc/hyperledger/fabric/tls \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp:/etc/hyperledger/fabric/msp \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/org1peer1:/var/hyperledger/production \
      -v /etc/hosts:/etc/hosts \
      -v /var/run:/var/run \
      --link couchdb_org1_peer1:couchdb \
      -p 7351:7051 \
      -p 7352:7052 \
      hyperledger/fabric-peer:1.4.3       


docker rm -f couchdb_org2
docker run -ti -d \
--name couchdb_org2 \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /root/codes/hyperledger_learning/docker/hyperledger_data/couchdb_org2/:/opt/couchdb/data  \
-d hyperledger/fabric-couchdb  


docker rm -f peer0.org2.example.com
docker run -it -d \
  --name peer0.org2.example.com \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer0.org2.example.com" \
      -e CORE_PEER_ADDRESS="peer0.org2.example.com:7151" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.org2.example.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.org2.example.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.org2.example.com:7051" \
      -e CORE_PEER_LOCALMSPID="Org2MSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="couchdb" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls:/etc/hyperledger/fabric/tls \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp:/etc/hyperledger/fabric/msp \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/org2peer:/var/hyperledger/production \
      -v /etc/hosts:/etc/hosts \
      -v /var/run:/var/run \
      --link couchdb_org2:couchdb \
      -p 7151:7051 \
      -p 7152:7052 \
      hyperledger/fabric-peer:1.4.3       

docker rm -f couchdb_org3
docker run -ti -d \
--name couchdb_org3 \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /root/codes/hyperledger_learning/docker/hyperledger_data/couchdb_org3/:/opt/couchdb/data  \
-d hyperledger/fabric-couchdb  

docker rm -f peer0.org3.example.com
docker run -it -d \
  --name peer0.org3.example.com \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer0.org3.example.com" \
      -e CORE_PEER_ADDRESS="peer0.org3.example.com:7151" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.org3.example.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.org3.example.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.org3.example.com:7051" \
      -e CORE_PEER_LOCALMSPID="Org3MSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="couchdb" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/crypto-config/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls:/etc/hyperledger/fabric/tls \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/crypto-config/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/msp:/etc/hyperledger/fabric/msp \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/org3peer:/var/hyperledger/production \
      -v /etc/hosts:/etc/hosts \
      -v /var/run:/var/run \
      --link couchdb_org3:couchdb \
      -p 7251:7051 \
      -p 7252:7052 \
      hyperledger/fabric-peer:1.4.3       

docker rm -f cli
docker run -it -d \
  --name cli \
      -e SYS_CHANNEL="byfn-sys-channel" \
      -e GOPATH="/opt/gopath" \
      -e CORE_VM_ENDPOINT="unix:///host/var/run/docker.sock" \
      -e FABRIC_LOGGING_SPEC="DEBUG" \
      -e CORE_PEER_ID="cli" \
      -e CORE_PEER_ADDRESS="peer0.org1.example.com:7051" \
      -e CORE_PEER_LOCALMSPID="Org1MSP" \
      -e CORE_PEER_TLS_ENABLED="true"  \
      -e CORE_PEER_TLS_CERT_FILE="/opt/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/opt/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/opt/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" \
      -e CORE_PEER_MSPCONFIGPATH="/opt/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" \
      -e PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/go/bin:/opt/gopath/bin" \
      -e GOROOT="/opt/go" \
      -e GOCACHE="off" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /etc/hosts:/etc/hosts \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/crypto-config:/opt/crypto \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data:/opt/channel-artifacts \
      -v /root/codes/chaincodes/authority:/opt/gopath/src/authority \
      -v /var/run:/host/var/run \
      -v /var/run:/var/run \
      hyperledger/fabric-tools:1.4.3



