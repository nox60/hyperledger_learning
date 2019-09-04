#!/bin/bash


docker rm -f orderer_container

docker run -it -d \
  --name orderer_container \
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
      -p 7050:7050 \
      hyperledger/fabric-orderer:1.4.3


docker rm -f org1_peer_0

docker run -it -d \
  --name org1_peer_0 \
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
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer1.org1.example.com:8051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.org1.example.com:7051" \
      -e CORE_PEER_LOCALMSPID="Org1" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls:/etc/hyperledger/fabric/tls \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp:/etc/hyperledger/fabric/msp \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data:/var/hyperledger/production \
      --link orderer_container:orderer.example.com \
      -p 7051:7051 \
      -p 7052:7052 \
      hyperledger/fabric-peer:1.4.3       

docker rm -f org1_peer_1

docker run -it -d \
  --name org1_peer_1 \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="true" \
      -e CORE_PEER_GOSSIP_ORGLEADER="false" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer1.org1.example.com" \
      -e CORE_PEER_ADDRESS="peer1.org1.example.com:8051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:8051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer1.org1.example.com:8052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:8052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.org1.example.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer1.org1.example.com:8051" \
      -e CORE_PEER_LOCALMSPID="Org1" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls:/etc/hyperledger/fabric/tls \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp:/etc/hyperledger/fabric/msp \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data:/var/hyperledger/production \
      --link orderer_container:orderer.example.com \
      -p 8051:8051 \
      -p 8052:8052 \
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
      -v /root/codes/hyperledger_learning/docker/hyperledger_data/crypto-config:/opt/crypto \
      -v /root/codes/hyperledger_learning/docker/hyperledger_data:/opt/channel-artifacts \
      --link orderer_container:orderer.example.com \
      --link org1_peer_0:peer0.org1.example.com \
      --link org1_peer_1:peer1.org1.example.com \
      hyperledger/fabric-tools:1.4.3
