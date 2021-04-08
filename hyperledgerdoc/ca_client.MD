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

尝试修改 -e FABRIC_CA_SERVER_CSR_HOSTS=ca.tls 为不一样的值

#### msp的0知识证明验证
#### msp的revoke验证，看看是怎样生效的？

```shell
Usage:
  fabric-ca-client enroll -u http://user:userpw@serverAddr:serverPort [flags]

Global Flags:
      --caname string                  Name of CA
      --csr.cn string                  The common name field of the certificate signing request
      --csr.hosts stringSlice          A list of space-separated host names in a certificate signing request
      --csr.keyrequest.algo string     Specify key algorithm
      --csr.keyrequest.size int        Specify key size
      --csr.names stringSlice          A list of comma-separated CSR names of the form <name>=<value> (e.g. C=CA,O=Org1)
      --csr.serialnumber string        The serial number in a certificate signing request
  -d, --debug                          Enable debug level logging
      --enrollment.attrs stringSlice   A list of comma-separated attribute requests of the form <name>[:opt] (e.g. foo,bar:opt)
      --enrollment.label string        Label to use in HSM operations
      --enrollment.profile string      Name of the signing profile to use in issuing the certificate
      --enrollment.type string         The type of enrollment request: 'x509' or 'idemix' (default "x509")
  -H, --home string                    Client's home directory (default "/Users/sjain68/.fabric-ca-client")
      --id.affiliation string          The identity's affiliation
      --id.attrs stringSlice           A list of comma-separated attributes of the form <name>=<value> (e.g. foo=foo1,bar=bar1)
      --id.maxenrollments int          The maximum number of times the secret can be reused to enroll (default CA's Max Enrollment)
      --id.name string                 Unique name of the identity
      --id.secret string               The enrollment secret for the identity being registered
      --id.type string                 Type of identity being registered (e.g. 'peer, app, user') (default "client")
  -M, --mspdir string                  Membership Service Provider directory (default "msp")
  -m, --myhost string                  Hostname to include in the certificate signing request during enrollment (default "WITSC02X6385JGH")
  -a, --revoke.aki string              AKI (Authority Key Identifier) of the certificate to be revoked
  -e, --revoke.name string             Identity whose certificates should be revoked
  -r, --revoke.reason string           Reason for revocation
  -s, --revoke.serial string           Serial number of the certificate to be revoked
      --tls.certfiles stringSlice      A list of comma-separated PEM-encoded trusted certificate files (e.g. root1.pem,root2.pem)
      --tls.client.certfile string     PEM-encoded certificate file when mutual authenticate is enabled
      --tls.client.keyfile string      PEM-encoded key file when mutual authentication is enabled
  -u, --url string                     URL of fabric-ca-server (default "http://localhost:7054")
```