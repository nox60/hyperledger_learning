https://hyperledger-fabric-ca.readthedocs.io/en/latest/users-guide.html#fabric-ca-client


#### 安装一个ca用于测试

```shell script
docker rm -f ca.tls
docker run \
  -it -d \
  --name ca.tls \
      -e FABRIC_CA_SERVER_HOME=/etc/hyperledger/ca.tls/ca.home \
      -e FABRIC_CA_SERVER_TLS_ENABLED=true \
      -e FABRIC_CA_SERVER_CSR_CN=ca.tls \
      -e FABRIC_CA_SERVER_CSR_HOSTS=ca.tls \
      -e FABRIC_CA_SERVER_DEBUG=false \
      -v /opt/local/codes/docker_with_ca_4/hyperledger_data/crypto/ca.tls:/etc/hyperledger/ca.tls \
      --entrypoint="fabric-ca-server" hyperledger/fabric-ca:1.4.3  \
      start -d -b \
      ca-tls-admin:ca-tls-adminpw --port 7052
```

