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