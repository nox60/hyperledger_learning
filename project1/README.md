加入通道
```joinchanneannel
peer channel join \
-b mychannel.block \
-o orderer.test.com:7050 \
--cafile ./hyperledger_data/crypto-config/ordererOrganizations/test.com/tlsca/tlsca.test.com-cert.pem
```

显示加入的通道
```showjoined 
peer channel list \
-o orderer.test.com:7050 \
--cafile ./hyperledger_data/crypto-config/ordererOrganizations/test.com/tlsca/tlsca.test.com-cert.pem
```
