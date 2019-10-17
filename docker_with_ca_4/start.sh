#!/bin/bash

docker network rm bc-net

docker network create --subnet=172.20.0.0/16 bc-net

docker rmi -f $(docker images --format "{{.Repository}}" |grep "^dev-peer*")

docker rm -f $(docker ps -a | grep "dev-peer*" | awk '{print $1}')

#sh -c 'fabric-ca-server start --ca.certfile /etc/hyperledger/fabric-ca-server-config/ca.cec.dams.com-cert.pem --ca.keyfile /etc/hyperledger/fabric-ca-server-config/${CEC_CA_PRIVATE_KEY} -b admin:adminpw -d' \
#["sh","-c","java $JAVA_OPTS  -Dfile.encoding=utf-8 -jar /opt/*.jar"]

rm -rf /root/codes/hyperledger_learning/docker_with_ca_4/hyperledger_data/*

docker rm -f ca.tls
docker run \
  -it -d \
  --name ca.tls \
      --network bc-net \
      -e FABRIC_CA_SERVER_HOME=/etc/hyperledger/ca.tls/ca.home \
      -e FABRIC_CA_SERVER_TLS_ENABLED=true \
      -e FABRIC_CA_SERVER_CSR_CN=ca.tls \
      -e FABRIC_CA_SERVER_CSR_HOSTS=ca.tls \
      -e FABRIC_CA_SERVER_DEBUG=false \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.tls:/etc/hyperledger/ca.tls \
      --entrypoint="fabric-ca-server" hyperledger/fabric-ca:1.4.3  \
      start -d -b \
      ca-tls-admin:ca-tls-adminpw --port 7052


# enroll tls.ca admin
docker run --rm -it -d\
  --name enroll.tls.ca.admin \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ca.tls/ca.admin.home \
      -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.tls/ca.home/ca-cert.pem \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.tls:/etc/hyperledger/ca.tls \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -u https://ca-tls-admin:ca-tls-adminpw@ca.tls:7052

# register orderer
docker run --rm -it \
    --name register.orderer \
        --network bc-net \
        -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ca.tls/ca.admin.home \
        -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.tls/ca.home/ca-cert.pem \
        -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.tls:/etc/hyperledger/ca.tls \
        hyperledger/fabric-ca:1.4.3 \
        fabric-ca-client register \
        -d --id.name orderer --id.secret ordererpw --id.type orderer  \
        -u https://ca.tls:7052


# register peer
docker run --rm -it \
    --name register.cec.peer0.ca \
        --network bc-net \
        -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ca.tls/ca.admin.home \
        -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.tls/ca.home/ca-cert.pem \
        -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.tls:/etc/hyperledger/ca.tls \
        hyperledger/fabric-ca:1.4.3 \
        fabric-ca-client register \
        -d --id.name peer0-cec --id.secret peer0cecpw --id.type peer  \
        -u https://ca.tls:7052


# create orderer ca
docker rm -f ca.orderer
docker run \
  -it -d \
  --name ca.orderer \
      --network bc-net \
      -e FABRIC_CA_SERVER_HOME=/etc/hyperledger/ca.order/ca.home \
      -e FABRIC_CA_SERVER_TLS_ENABLED=true \
      -e FABRIC_CA_SERVER_CSR_CN=ca.orderer \
      -e FABRIC_CA_SERVER_CSR_HOSTS=ca.orderer \
      -e FABRIC_CA_SERVER_DEBUG=false \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.order:/etc/hyperledger/ca.order \
      --entrypoint="fabric-ca-server" hyperledger/fabric-ca:1.4.3  \
      start -d -b \
      ca-order-admin:ca-order-adminpw --port 7053

# enroll orderer ca admin
docker run --rm -it \
  --name enroll.ca.orderer.admin \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ca.order/ca.admin.home \
      -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.order/ca.home/ca-cert.pem \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.order:/etc/hyperledger/ca.order \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -u https://ca-order-admin:ca-order-adminpw@ca.orderer:7053


# register orderre?
# register orderer admin?

# create cec org ca
docker rm -f ca.cec
docker run \
  -it -d \
  --name ca.cec \
      --network bc-net \
      -e FABRIC_CA_SERVER_HOME=/etc/hyperledger/ca.cec/ca.home \
      -e FABRIC_CA_SERVER_TLS_ENABLED=true \
      -e FABRIC_CA_SERVER_CSR_CN=ca.cec \
      -e FABRIC_CA_SERVER_CSR_HOSTS=ca.cec \
      -e FABRIC_CA_SERVER_DEBUG=false \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.cec:/etc/hyperledger/ca.cec \
      --entrypoint="fabric-ca-server" hyperledger/fabric-ca:1.4.3  \
      start -d -b \
      ca-cec-admin:ca-cec-adminpw --port 7054

# enroll cec admin
docker run --rm -it \
  --name enroll.ca.cec.admin \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ca.cec/ca.admin.home \
      -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.cec/ca.home/ca-cert.pem \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.cec:/etc/hyperledger/ca.cec \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -u https://ca-cec-admin:ca-cec-adminpw@ca.cec:7054

# register peer0
docker run --rm -it \
    --name register.cec.peer0 \
        --network bc-net \
        -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ca.cec/ca.admin.home \
        -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.cec/ca.home/ca-cert.pem \
        -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.cec:/etc/hyperledger/ca.cec \
        hyperledger/fabric-ca:1.4.3 \
        fabric-ca-client register \
        -d --id.name peer0-cec --id.secret peer0cecpw --id.type peer  \
        -u https://ca.cec:7054

# enroll peer0 information
docker run --rm -it \
  --name enroll.cec.peer0 \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ca.cec/ca.peer.home \
      -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.cec/ca.home/ca-cert.pem \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.cec:/etc/hyperledger/ca.cec \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -u https://peer0-cec:peer0cecpw@ca.cec:7054


export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org1/ca/admin
fabric-ca-client enroll -d -u https://rca-org1-admin:rca-org1-adminpw@0.0.0.0:7054
fabric-ca-client register -d --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7054


# register cec peer0


# create peer?



export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/tls-ca/admin
fabric-ca-client enroll -d -u https://tls-ca-admin:tls-ca-adminpw@0.0.0.0:7052
fabric-ca-client register -d --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name peer2-org1 --id.secret peer2PW --id.type peer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name peer1-org2 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name peer2-org2 --id.secret peer2PW --id.type peer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name orderer1-org0 --id.secret ordererPW --id.type orderer -u https://0.0.0.0:7052







export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/tls-ca/crypto/tls-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/tls-ca/admin
fabric-ca-client enroll -d -u https://tls-ca-admin:tls-ca-adminpw@0.0.0.0:7052
fabric-ca-client register -d --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name peer2-org1 --id.secret peer2PW --id.type peer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name peer1-org2 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name peer2-org2 --id.secret peer2PW --id.type peer -u https://0.0.0.0:7052
fabric-ca-client register -d --id.name orderer1-org0 --id.secret ordererPW --id.type orderer -u https://0.0.0.0:7052





docker rm -f ca.ia3.dams.com
docker run \
  -it -d \
  --name ca.ia3.dams.com \
      --network bc-net \
      -e FABRIC_CA_HOME="/etc/hyperledger/fabric-ca-server" \
      -e FABRIC_CA_SERVER_CA_NAME="ca-ia3" \
      -e FABRIC_CA_SERVER_TLS_ENABLED=true \
      -e FABRIC_CA_SERVER_TLS_CERTFILE="/etc/hyperledger/fabric-ca-server-config/ca.ia3.dams.com-cert.pem" \
      -e FABRIC_CA_SERVER_TLS_KEYFILE="/etc/hyperledger/fabric-ca-server-config/${IA3_CA_PRIVATE_KEY}" \
      -e FABRIC_CA_SERVER_PORT=7054 \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ia3.dams.com/ca:/etc/hyperledger/fabric-ca-server-config \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/ia3-ca:/etc/hyperledger/ia3-ca \
      --entrypoint="fabric-ca-server" hyperledger/fabric-ca:1.4.3  start --ca.certfile /etc/hyperledger/fabric-ca-server-config/ca.ia3.dams.com-cert.pem --ca.keyfile /etc/hyperledger/fabric-ca-server-config/${IA3_CA_PRIVATE_KEY} -b admin:adminpw -d

docker rm -f ca.ic3.dams.com
docker run \
  -it -d \
  --name ca.ic3.dams.com \
      --network bc-net \
      -e FABRIC_CA_HOME="/etc/hyperledger/fabric-ca-server" \
      -e FABRIC_CA_SERVER_CA_NAME="ca-ic3" \
      -e FABRIC_CA_SERVER_TLS_ENABLED=true \
      -e FABRIC_CA_SERVER_TLS_CERTFILE="/etc/hyperledger/fabric-ca-server-config/ca.ic3.dams.com-cert.pem" \
      -e FABRIC_CA_SERVER_TLS_KEYFILE="/etc/hyperledger/fabric-ca-server-config/${IC3_CA_PRIVATE_KEY}" \
      -e FABRIC_CA_SERVER_PORT=7054 \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ic3.dams.com/ca:/etc/hyperledger/fabric-ca-server-config \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/ic3-ca:/etc/hyperledger/ic3-ca \
      --entrypoint="fabric-ca-server" hyperledger/fabric-ca:1.4.3  start --ca.certfile /etc/hyperledger/fabric-ca-server-config/ca.ic3.dams.com-cert.pem --ca.keyfile /etc/hyperledger/fabric-ca-server-config/${IC3_CA_PRIVATE_KEY} -b admin:adminpw -d

docker rm -f ca.gov.dams.com
docker run \
  -it -d \
  --name ca.gov.dams.com \
      --network bc-net \
      -e FABRIC_CA_HOME="/etc/hyperledger/fabric-ca-server" \
      -e FABRIC_CA_SERVER_CA_NAME="ca-gov" \
      -e FABRIC_CA_SERVER_TLS_ENABLED=true \
      -e FABRIC_CA_SERVER_TLS_CERTFILE="/etc/hyperledger/fabric-ca-server-config/ca.gov.dams.com-cert.pem" \
      -e FABRIC_CA_SERVER_TLS_KEYFILE="/etc/hyperledger/fabric-ca-server-config/${GOV_CA_PRIVATE_KEY}" \
      -e FABRIC_CA_SERVER_PORT=7054 \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/gov.dams.com/ca:/etc/hyperledger/fabric-ca-server-config \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/gov-ca:/etc/hyperledger/gov-ca \
      --entrypoint="fabric-ca-server" hyperledger/fabric-ca:1.4.3  start --ca.certfile /etc/hyperledger/fabric-ca-server-config/ca.gov.dams.com-cert.pem --ca.keyfile /etc/hyperledger/fabric-ca-server-config/${GOV_CA_PRIVATE_KEY} -b admin:adminpw -d


docker rm -f orderer.dams.com
docker run -it -d  \
  --name orderer.dams.com \
      --network bc-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e ORDERER_GENERAL_LISTENADDRESS="0.0.0.0" \
      -e ORDERER_GENERAL_GENESISMETHOD="file" \
      -e ORDERER_GENERAL_GENESISFILE="/var/hyperledger/orderer/orderer.genesis.block" \
      -e ORDERER_GENERAL_LOCALMSPID="OrdererMSP" \
      -e ORDERER_GENERAL_LOCALMSPDIR="/var/hyperledger/orderer/msp" \
      -e ORDERER_GENERAL_TLS_ENABLED="true" \
      -e ORDERER_GENERAL_TLS_PRIVATEKEY="/var/hyperledger/orderer/tls/server.key" \
      -e ORDERER_GENERAL_TLS_CERTIFICATE="/var/hyperledger/orderer/tls/server.crt" \
      -e ORDERER_GENERAL_TLS_ROOTCAS="[/var/hyperledger/orderer/tls/ca.crt]" \
      -e ORDERER_KAFKA_TOPIC_REPLICATIONFACTOR="1" \
      -e ORDERER_KAFKA_VERBOSE="true" \
      -e ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE="/var/hyperledger/orderer/tls/server.crt" \
      -e ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY="/var/hyperledger/orderer/tls/server.key" \
      -e ORDERER_GENERAL_CLUSTER_ROOTCAS="[/var/hyperledger/orderer/tls/ca.crt]" \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/ordererOrganizations/dams.com/orderers/orderer.dams.com/msp:/var/hyperledger/orderer/msp \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/ordererOrganizations/dams.com/orderers/orderer.dams.com/tls:/var/hyperledger/orderer/tls \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/orderer.genesis.block:/var/hyperledger/orderer/orderer.genesis.block \
      -v /opt/local/codes/docker_with_ca/hyperledger_data:/var/hyperledger/production/orderer \
      -v /var/run:/var/run \
      hyperledger/fabric-orderer:1.4.3


docker rm -f couchdb_cec
docker run -it -d  \
--name couchdb_cec \
--network bc-net \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /opt/local/codes/docker_with_ca/hyperledger_data/couchdb_cec/peer0:/opt/couchdb/data  \
-p 5984:5984 \
-p 9100:9100 \
-d hyperledger/fabric-couchdb  


docker rm -f peer0.cec.dams.com
docker run -it -d \
  --name peer0.cec.dams.com \
      --network bc-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer0.cec.dams.com" \
      -e CORE_PEER_ADDRESS="peer0.cec.dams.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.cec.dams.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.cec.dams.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.cec.dams.com:7051" \
      -e CORE_PEER_LOCALMSPID="cecMSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_cec:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="bc-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls:/etc/hyperledger/fabric/tls \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/msp:/etc/hyperledger/fabric/msp \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/cecpeer0:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3       


docker rm -f couchdb_ia3
docker run -ti -d \
--name couchdb_ia3 \
--network bc-net \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /opt/local/codes/docker_with_ca/hyperledger_data/couchdb_ia3_peer0/:/opt/couchdb/data  \
-d hyperledger/fabric-couchdb  



docker rm -f peer0.ia3.dams.com
docker run -it -d \
  --name peer0.ia3.dams.com \
      --network bc-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer0.ia3.dams.com" \
      -e CORE_PEER_ADDRESS="peer0.ia3.dams.com:7151" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7151" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.ia3.dams.com:7152" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7152" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.ia3.dams.com:7151" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.ia3.dams.com:7151" \
      -e CORE_PEER_LOCALMSPID="ia3MSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_ia3:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="bc-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ia3.dams.com/peers/peer0.ia3.dams.com/tls:/etc/hyperledger/fabric/tls \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ia3.dams.com/peers/peer0.ia3.dams.com/msp:/etc/hyperledger/fabric/msp \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/ia3peer0:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3       


docker rm -f couchdb_ic3
docker run -ti -d \
--name couchdb_ic3 \
--network bc-net \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /opt/local/codes/docker_with_ca/hyperledger_data/couchdb_ic3/:/opt/couchdb/data  \
-d hyperledger/fabric-couchdb  


docker rm -f peer0.ic3.dams.com
docker run -it -d \
  --name peer0.ic3.dams.com \
      --network bc-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer0.ic3.dams.com" \
      -e CORE_PEER_ADDRESS="peer0.ic3.dams.com:7251" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7251" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.ic3.dams.com:7252" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7252" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.ic3.dams.com:7251" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.ic3.dams.com:7251" \
      -e CORE_PEER_LOCALMSPID="ic3MSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_ic3:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="bc-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ic3.dams.com/peers/peer0.ic3.dams.com/tls:/etc/hyperledger/fabric/tls \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/ic3.dams.com/peers/peer0.ic3.dams.com/msp:/etc/hyperledger/fabric/msp \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/ic3peer0:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3       


docker rm -f couchdb_gov
docker run -ti -d \
--name couchdb_gov \
--network bc-net \
-e COUCHDB_USER=admin \
-e COUCHDB_PASSWORD=dev@2019  \
-v /opt/local/codes/docker_with_ca/hyperledger_data/couchdb_gov/:/opt/couchdb/data  \
-d hyperledger/fabric-couchdb  

docker rm -f peer0.gov.dams.com
docker run -it -d \
  --name peer0.gov.dams.com \
      --network bc-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/fabric/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/fabric/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/fabric/tls/ca.crt" \
      -e CORE_PEER_ID="peer0.gov.dams.com" \
      -e CORE_PEER_ADDRESS="peer0.gov.dams.com:7351" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7351" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.gov.dams.com:7352" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7352" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.gov.dams.com:7351" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.gov.dams.com:7351" \
      -e CORE_PEER_LOCALMSPID="govMSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_gov:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="bc-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/gov.dams.com/peers/peer0.gov.dams.com/tls:/etc/hyperledger/fabric/tls \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config/peerOrganizations/gov.dams.com/peers/peer0.gov.dams.com/msp:/etc/hyperledger/fabric/msp \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/govpeer0:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3       

docker rm -f cli
docker run -it -d \
  --name cli \
      --network bc-net \
      -e SYS_CHANNEL="byfn-sys-channel" \
      -e GOPATH="/opt/gopath" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_ID="cli" \
      -e CORE_PEER_ADDRESS="peer0.cec.dams.com:7051" \
      -e CORE_PEER_LOCALMSPID="cecMSP" \
      -e CORE_PEER_TLS_ENABLED="true"  \
      -e CORE_PEER_TLS_CERT_FILE="/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/server.crt" \
      -e CORE_PEER_TLS_KEY_FILE="/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/server.key" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/opt/crypto/peerOrganizations/cec.dams.com/peers/peer0.cec.dams.com/tls/ca.crt" \
      -e CORE_PEER_MSPCONFIGPATH="/opt/crypto/peerOrganizations/cec.dams.com/users/Admin@cec.dams.com/msp" \
      -e PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/go/bin:/opt/gopath/bin" \
      -e GOROOT="/opt/go" \
      -e GOCACHE="off" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/crypto-config:/opt/crypto \
      -v /opt/local/codes/docker_with_ca/hyperledger_data:/opt/channel-artifacts \
      -v /opt/local/codes/docker_with_ca/chaincode/mychaincode:/opt/gopath/src/mychaincode \
      -v /opt/local/codes/docker_with_ca/chaincode/example_code:/opt/gopath/src/example_code \
      -v /var/run:/var/run \
      hyperledger/fabric-tools:1.4.3


