#!/bin/bash

docker network rm bc-net

docker network create --subnet=172.20.0.0/16 bc-net

docker rmi -f $(docker images --format "{{.Repository}}" |grep "^dev-peer*")

docker rm -f $(docker ps -a | grep "dev-peer*" | awk '{print $1}')

#sh -c 'fabric-ca-server start --ca.certfile /etc/hyperledger/fabric-ca-server-config/ca.cec.dams.com-cert.pem --ca.keyfile /etc/hyperledger/fabric-ca-server-config/${CEC_CA_PRIVATE_KEY} -b admin:adminpw -d' \
#["sh","-c","java $JAVA_OPTS  -Dfile.encoding=utf-8 -jar /opt/*.jar"]


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

# enroll tls.ca admin 获取 ca.tls的管理员信息，用来后面注册 orderer, peer的tls等账户。
docker run --rm -it -d\
  --name enroll.tls.ca.admin \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ca.tls/ca.admin.home \
      -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.tls/ca.home/ca-cert.pem \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.tls:/etc/hyperledger/ca.tls \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -u https://ca-tls-admin:ca-tls-adminpw@ca.tls:7052

# register orderer tls 给orderer注册tls证书，用于启动orderer节点时候的tls通信
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

# register peer0.cec tls 给cec.peer0注册tls账户，用于启动cec.peer0的tls通信
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

# create orderer ca 创建 orderer的ca服务，该服务用于提供orderer的ca身份证书, 这里没有tls相关的公私钥，有问题。
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

# enroll orderer ca admin  获取 orderer ca 的 admin账户信息
docker run --rm -it \
  --name enroll.ca.orderer.admin \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ca.orderer/ca.admin.home \
      -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.orderer/ca.home/ca-cert.pem \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.orderer:/etc/hyperledger/ca.orderer \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -u https://ca-order-admin:ca-order-adminpw@ca.orderer:7053

# register orderer in ca.orderer  在 orderer ca 注册 orderer节点
# fabric-ca-client register -d --id.name orderer1-org0 --id.secret ordererpw --id.type orderer -u https://0.0.0.0:7053
docker run --rm -it \
    --name register.orderer.ca \
        --network bc-net \
        -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/ca.orderer/ca.admin.home \
        -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.orderer/ca.home/ca-cert.pem \
        -e FABRIC_CA_CLIENT_CSR_NAMES="[C=US,ST=NorthCarolinaee,O=Hyperledger,OU=Fabric,CN=ca.orderer]" \
        -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.orderer:/etc/hyperledger/ca.orderer \
        hyperledger/fabric-ca:1.4.3 \
        fabric-ca-client register \
        -d --id.name orderer --id.secret ordererpw --id.type orderer  \
        -u https://ca.orderer:7053

# register orderer admin?

# setup orderer
# enroll orderer tls from ca.tls
# fabric-ca-client enroll -d -u https://orderer-org0:ordererPW@0.0.0.0:7052 --enrollment.profile tls --csr.hosts orderer1-org0
docker run --rm -it \
  --name enroll.orderer.tls \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/orderer/tls \
      -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.tls/ca.home/ca-cert.pem \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/orderer:/etc/hyperledger/orderer \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.tls:/etc/hyperledger/ca.tls \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      --enrollment.profile tls --csr.hosts orderer.com \
      -u https://orderer:ordererpw@ca.tls:7052

# enroll orderer msp from ca.orderer
docker run --rm -it \
  --name enroll.orderer.ca \
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
# mkdir -p /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/generatedir/orderer/msp/cacerts
# mkdir -p /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/generatedir/orderer/msp/admincerts
# mkdir -p /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/generatedir/orderer/msp/tlscacerts
# mkdir -p /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/generatedir/orderer/msp/signcerts

cp /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.orderer/ca.home/ca-cert.pem \
/opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/generatedir/orderer/msp/cacerts/order-ca-cert.pem

cp /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.tls/ca.home/ca-cert.pem \
/opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/generatedir/orderer/msp/tlscacerts/order-tls-ca-cert.pem

# 生成generatedir的初衷是为了解决生成创世区块和channel.tx文件，后面如果想不起来就废弃掉，使用 /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/orderer/msp/msp 这个msp目录
cp /opt/local/codes/docker_with_ca_4/config_orderer.yaml /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/generatedir/orderer/msp/config.yaml

cp /opt/local/codes/docker_with_ca_4/config_orderer.yaml /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/orderer/msp/msp/config.yaml


# cp /opt/local/codes/docker_with_ca_4/configtx.yaml


# create cec org ca 创建 cec节点的 ca服务，这里似乎发现了坑。没有提供tls 相关证书。
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

# register peer0 in cec.ca
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

# setup peer0
# enroll peer0 tls information
docker run --rm -it \
  --name enroll.cec.peer0.tls \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/cec/peer0.home/tls \
      -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.tls/ca.home/ca-cert.pem \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/cec:/etc/hyperledger/cec \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.tls:/etc/hyperledger/ca.tls \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      --enrollment.profile tls --csr.hosts peer0.cec.com \
      -u https://peer0-cec:peer0cecpw@ca.tls:7052

# enroll peer0 msp from ca.cec
docker run --rm -it \
  --name enroll.cec.peer0.msp \
      --network bc-net \
      -e FABRIC_CA_CLIENT_HOME=/etc/hyperledger/cec/peer0.home/msp \
      -e FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/ca.cec/ca.home/ca-cert.pem \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/cec:/etc/hyperledger/cec \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.cec:/etc/hyperledger/ca.cec \
      hyperledger/fabric-ca:1.4.3 \
      fabric-ca-client enroll \
      -u https://peer0-cec:peer0cecpw@ca.cec:7054

cp /opt/local/codes/docker_with_ca_4/config_peer0_cec.yaml /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/cec/peer0.home/msp/msp/config.yaml

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

# lunch cec-peer0

export CEC_PEER0_TLS_PRIVATE_KEY=$(cd /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/cec/peer0.home/tls/msp/keystore && ls *_sk)
export CEC_PEER0_MSP_PRIVATE_KEY=$(cd /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/cec/peer0.home/msp/msp/keystore && ls *_sk)


docker rm -f peer0.cec.com
docker run -it -d \
  --name peer0.cec.com \
      --network bc-net \
      -e FABRIC_LOGGING_SPEC="DEBUG" \
      -e CORE_PEER_TLS_ENABLED="true" \
      -e CORE_PEER_GOSSIP_USELEADERELECTION="false" \
      -e CORE_PEER_GOSSIP_ORGLEADER="true" \
      -e CORE_PEER_PROFILE_ENABLED="true" \
      -e CORE_PEER_TLS_CERT_FILE="/etc/hyperledger/cec/tls/signcerts/cert.pem" \
      -e CORE_PEER_TLS_KEY_FILE="/etc/hyperledger/cec/tls/keystore/${CEC_PEER0_TLS_PRIVATE_KEY}" \
      -e CORE_PEER_TLS_ROOTCERT_FILE="/etc/hyperledger/cec/tls/tlscacerts/tls-ca-tls-7052.pem" \
      -e CORE_PEER_ID="peer0.cec.com" \
      -e CORE_PEER_ADDRESS="peer0.cec.com:7051" \
      -e CORE_PEER_LISTENADDRESS="0.0.0.0:7051" \
      -e CORE_PEER_CHAINCODEADDRESS="peer0.cec.com:7052" \
      -e CORE_PEER_CHAINCODELISTENADDRESS="0.0.0.0:7052" \
      -e CORE_PEER_GOSSIP_BOOTSTRAP="peer0.cec.com:7051" \
      -e CORE_PEER_GOSSIP_EXTERNALENDPOINT="peer0.cec.com:7051" \
      -e CORE_PEER_LOCALMSPID="cecMSP" \
      -e CORE_PEER_MSPCONFIGPATH="/etc/hyperledger/fabric/msp" \
      -e CORE_LEDGER_STATE_STATEDATABASE="CouchDB" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS="couchdb_cec:5984" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME="admin" \
      -e CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD="dev@2019" \
      -e CORE_VM_ENDPOINT="unix:///var/run/docker.sock" \
      -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE="bc-net" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/cec:/etc/hyperledger/cec \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/cec/peer0.home/msp/msp:/etc/hyperledger/fabric/msp \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/cec/peer0.home/tls/msp:/etc/hyperledger/cec/tls \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/cecpeer0:/var/hyperledger/production \
      -v /var/run:/var/run \
      hyperledger/fabric-peer:1.4.3

# Join cec-peer0 to channel

# register cec peer0

# create peer?

# configtxgen -outputBlock hyperledger_data/orderer.genesis.block -channelID byfn-sys-channel -profile TwoOrgsOrdererGenesis
# configtxgen -profile OrgsOrdererGenesis -outputBlock /tmp/hyperledger/org0/orderer/genesis.block
docker run --rm -it \
  --name configtxgen.generate.files \
      --network bc-net \
      -e FABRIC_CFG_PATH=/etc/hyperledger/ \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data:/etc/hyperledger/hyperledger_data \
      -v /opt/local/codes/docker_with_ca_4/configtx.yaml:/etc/hyperledger/configtx.yaml \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/orderer/msp/msp:/etc/hyperledger/orderer/msp \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/cec/peer0.home/msp/msp:/etc/hyperledger/cec/peer0/msp \
      -w /etc/hyperledger \
      hyperledger/fabric-tools:1.4.3 \
      configtxgen \
      -outputBlock /etc/hyperledger/hyperledger_data/orderer.genesis.block \
      -channelID byfn-sys-channel \
      -profile TwoOrgsOrdererGenesis

# generate channel.tx file
docker run --rm -it \
  --name configtxgen.generate.files.channel.tx.file \
      --network bc-net \
      -e FABRIC_CFG_PATH=/etc/hyperledger/ \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data:/etc/hyperledger/hyperledger_data \
      -v /opt/local/codes/docker_with_ca_4/configtx.yaml:/etc/hyperledger/configtx.yaml \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/orderer/msp/msp:/etc/hyperledger/orderer/msp \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/cec/peer0.home/msp/msp:/etc/hyperledger/cec/peer0/msp \
      -w /etc/hyperledger \
      hyperledger/fabric-tools:1.4.3 \
      configtxgen \
      -profile TwoOrgsChannel \
      -outputCreateChannelTx  /etc/hyperledger/hyperledger_data/channel.tx \
      -channelID mychannel


# lunch orderer container
export ORDERER_TLS_PRIVATE_KEY=$(cd /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/orderer/tls/msp/keystore && ls *_sk)
export ORDERER_MSP_PRIVATE_KEY=$(cd /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/orderer/msp/msp/keystore && ls *_sk)

docker rm -f orderer.com
docker run -it -d  \
  --name orderer.com \
      --network bc-net \
      -e FABRIC_LOGGING_SPEC="DEBUG" \
      -e ORDERER_GENERAL_LISTENADDRESS="0.0.0.0" \
      -e ORDERER_GENERAL_GENESISMETHOD="file" \
      -e ORDERER_GENERAL_GENESISFILE="/etc/hyperledger/hyperledger_data/orderer.genesis.block" \
      -e ORDERER_GENERAL_LOCALMSPID="OrdererMSP" \
      -e ORDERER_GENERAL_LOCALMSPDIR="/etc/hyperledger/fabric/msp" \
      -e ORDERER_GENERAL_TLS_ENABLED="true" \
      -e ORDERER_GENERAL_TLS_PRIVATEKEY="/etc/hyperledger/orderer/tls/keystore/${ORDERER_TLS_PRIVATE_KEY}" \
      -e ORDERER_GENERAL_TLS_CERTIFICATE="/etc/hyperledger/orderer/tls/signcerts/cert.pem" \
      -e ORDERER_GENERAL_TLS_ROOTCAS="[/etc/hyperledger/orderer/tls/tlscacerts/tls-ca-tls-7052.pem]" \
      -e ORDERER_KAFKA_TOPIC_REPLICATIONFACTOR="1" \
      -e ORDERER_KAFKA_VERBOSE="true" \
      -e FABRIC_CFG_PATH="/etc/hyperledger/fabric" \
      -e ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE="/etc/hyperledger/orderer/tls/signcerts/cert.pem" \
      -e ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY="/etc/hyperledger/orderer/tls/keystore/${ORDERER_TLS_PRIVATE_KEY}" \
      -e ORDERER_GENERAL_CLUSTER_ROOTCAS="[/etc/hyperledger/orderer/tls/tlscacerts/tls-ca-tls-7052.pem]" \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/orderer/tls/msp:/etc/hyperledger/orderer/tls \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/orderer/msp/msp:/etc/hyperledger/fabric/msp \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/orderer_data_dir:/etc/hyperledger/production/orderer \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data:/etc/hyperledger/hyperledger_data \
      -v /var/run:/var/run \
      hyperledger/fabric-orderer:1.4.3


