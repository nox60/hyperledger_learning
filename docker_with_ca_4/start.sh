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

# register orderer tls
# fabric-ca-client register -d --id.name orderer1-org0 --id.secret ordererPW --id.type orderer -u https://0.0.0.0:7052
docker run --rm -it \
    --name register.orderer.tls \
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
      -e FABRIC_CA_SERVER_HOME=/etc/hyperledger/ca.orderer/ca.home \
      -e FABRIC_CA_SERVER_TLS_ENABLED=true \
      -e FABRIC_CA_SERVER_CSR_CN=ca.orderer \
      -e FABRIC_CA_SERVER_CSR_HOSTS=ca.orderer \
      -e FABRIC_CA_SERVER_DEBUG=false \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.orderer:/etc/hyperledger/ca.orderer \
      --entrypoint="fabric-ca-server" hyperledger/fabric-ca:1.4.3  \
      start -d -b \
      ca-order-admin:ca-order-adminpw --port 7053

# enroll orderer ca admin
docker run --rm -it \
  --name enroll.ca.orderer.admin \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ca.orderer/ca.admin.home \
      -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.orderer/ca.home/ca-cert.pem \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.orderer:/etc/hyperledger/ca.orderer \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -u https://ca-order-admin:ca-order-adminpw@ca.orderer:7053

# register orderer ca
# fabric-ca-client register -d --id.name orderer1-org0 --id.secret ordererpw --id.type orderer -u https://0.0.0.0:7053
docker run --rm -it \
    --name register.orderer.ca \
        --network bc-net \
        -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ca.orderer/ca.admin.home \
        -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.orderer/ca.home/ca-cert.pem \
        -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.orderer:/etc/hyperledger/ca.orderer \
        hyperledger/fabric-ca:1.4.3 \
        fabric-ca-client register \
        -d --id.name orderer --id.secret ordererpw --id.type orderer  \
        -u https://ca.orderer:7053

# register orderer admin?

# setup orderer
# enroll orderer tls
# fabric-ca-client enroll -d -u https://orderer-org0:ordererPW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts orderer1-org0
docker run --rm -it \
  --name enroll.ca.orderer.admin \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/orderer/tls \
      -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.tls/ca.home/ca-cert.pem \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/orderer:/etc/hyperledger/orderer \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.tls:/etc/hyperledger/ca.tls \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      --enrollment.profile tls --csr.hosts orderer.com \
      -u https://orderer:ordererpw@ca.tls:7052


# enroll orderer msp
docker run --rm -it \
  --name enroll.ca.orderer.admin \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/orderer/msp \
      -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.orderer/ca.home/ca-cert.pem \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/orderer:/etc/hyperledger/orderer \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.orderer:/etc/hyperledger/ca.orderer \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -u https://orderer:ordererpw@ca.orderer:7053

# Create Genesis Block and Channel Transaction
# orderer msp 目录下面 ：admincerts  cacerts  config.yaml  tlscacerts
mkdir -p /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/generatedir/orderer/msp/cacerts
mkdir -p /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/generatedir/orderer/msp/admincerts
mkdir -p /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/generatedir/orderer/msp/tlscacerts

cp /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.orderer/ca.home/ca-cert.pem \
/opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/generatedir/orderer/msp/cacerts/order-ca-cert.pem

cp /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.tls/ca.home/ca-cert.pem \
/opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/generatedir/orderer/msp/tlscacerts/order-tls-ca-cert.pem

cp /opt/local/codes/docker_with_ca_4/configt.yaml /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/generatedir/orderer/msp

# cp /opt/local/codes/docker_with_ca_4/configtx.yaml
# configtxgen -outputBlock hyperledger_data/orderer.genesis.block -channelID byfn-sys-channel -profile TwoOrgsOrdererGenesis
# configtxgen -profile OrgsOrdererGenesis -outputBlock /tmp/hyperledger/org0/orderer/genesis.block
docker run --rm -it \
  --name configtxgen.generate.files \
      --network bc-net \
      -e FABRIC_CFG_PATH=/etc/hyperledger/ \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data:/etc/hyperledger/hyperledger_data \
      -v /opt/local/codes/docker_with_ca_4/configtx.yaml:/etc/hyperledger/configtx.yaml \
      -w /etc/hyperledger \
      hyperledger/fabric-tools:1.4.3 \
      configtxgen \
      -outputBlock /etc/hyperledger/hyperledger_data/orderer.genesis.block \
      -channelID byfn-sys-channel \
      -profile TwoOrgsOrdererGenesis

# lunch orderer container

docker rm -f orderer.com
docker run -it -d  \
  --name orderer.com \
      --network bc-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e ORDERER_GENERAL_LISTENADDRESS="0.0.0.0" \
      -e ORDERER_GENERAL_GENESISMETHOD="file" \
      -e ORDERER_GENERAL_GENESISFILE="/etc/hyperledger/hyperledger_data/orderer.genesis.block" \
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
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/orderer/msp/msp:/var/hyperledger/orderer/msp \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/orderer/tls/msp:/var/hyperledger/orderer/tls \
      -v /opt/local/codes/docker_with_ca/hyperledger_data/orderer_data_dir:/var/hyperledger/production/orderer \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data:/etc/hyperledger/hyperledger_data \
      -v /var/run:/var/run \
      hyperledger/fabric-orderer:1.4.3






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

# enroll peer0 tls information
docker run --rm -it \
  --name enroll.cec.peer0 \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/cec/peer0.home/tls \
      -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.tls/ca.home/ca-cert.pem \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.tls:/etc/hyperledger/ca.tls \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/cec:/etc/hyperledger/cec \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -u https://peer0-cec:peer0cecpw@ca.tls:7052


# enroll peer0 information
docker run --rm -it \
  --name enroll.cec.peer0 \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/cec/peer0.home/msp \
      -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.cec/ca.home/ca-cert.pem \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.cec:/etc/hyperledger/ca.cec \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/cec:/etc/hyperledger/cec \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -u https://peer0-cec:peer0cecpw@ca.cec:7054

# lunch cec-peer0-couchdb
docker rm -f couchdb_cec
docker run -it -d  \
    --name couchdb_cec \
        --network bc-net \
        -e COUCHDB_USER=admin \
        -e COUCHDB_PASSWORD=dev@2019  \
        -v /opt/local/codes/docker_with_ca_4/hyperledger_data/couchdb_cec/peer0:/opt/couchdb/data  \
        -p 5984:5984 \
        -p 9100:9100 \
        -d hyperledger/fabric-couchdb


export CEC_PEER0_TLS_PRIVATE_KEY=$(cd /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/cec/peer0.home/tls/msp/keystore && ls *_sk)

# lunch cec-peer0
docker rm -f peer0.cec.com
docker run -it -d \
  --name peer0.cec.com \
      --network bc-net \
      -e FABRIC_LOGGING_SPEC="INFO" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/cec/peer0.home/tls/msp/signcerts/cert.pem" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/cec/peer0.home/tls/msp/keystore/${CEC_PEER0_TLS_PRIVATE_KEY}" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/cec/peer0.home/tls/msp/cacerts/ca-tls-7052.pem" \
      -e CORE_PEER_ID="peer0.cec.com" \
      -e CORE_PEER_ADDRESS="peer0.cec.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.cec.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.cec.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.cec.com:7051" \
      -e CORE_PEER_LOCALMSPID="cecMSP" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_cec:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="bc-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/cec:/etc/hyperledger/cec \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/cec/peer0.home/msp/msp:/etc/hyperledger/cec/msp \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/cecpeer0:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3

# Join cec-peer0 to channel





export FABRIC_CA_CLIENT_TLS_CERTFILES=/tmp/hyperledger/org1/ca/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/tmp/hyperledger/org1/ca/admin
fabric-ca-client enroll -d -u https://rca-org1-admin:rca-org1-adminpw@0.0.0.0:7054
fabric-ca-client register -d --id.name peer1-org1 --id.secret peer1PW --id.type peer -u https://0.0.0.0:7054


# register cec peer0


# create peer?






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




