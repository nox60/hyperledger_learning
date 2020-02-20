cryptogen generate \
--config=./crypto-config.yaml \
--output="hyperledger_data/crypto-config"

```go

docker rm -f cli
docker run --rm -it \
      --name cli \
      --network bc-net \
      -v /root/temp/gentest:/opt/gen \
      hyperledger/fabric-tools:1.4.3 \
      cryptogen generate --config=/opt/gen/crypto-config.yaml --output="/opt/gen/crypto-config"
```



LSCC(Lifecycle system chaincode) handles lifecycle requests such as install, instantiate and upgrade chaincodes.
CSCC(Configuration system chaincode) handles channel configuration on the peer side.
QSCC(Query system chaincode) provides ledger query APIs such as getting blocks and transactions.
ESCC(Endorsement system chaincode) handles endorsement by signing the transaction proposal response.
VSCC(Validation system chaincode) handles the transaction validation, including checking endorsement policy and multiversioning concurrency control.