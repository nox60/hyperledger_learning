加入通道
```joinchanneannel
peer channel join \
-b ./hyperledger_data/mychannel.block \
-o orderer.test.com:7050 \
--cafile ./hyperledger_data/crypto-config/ordererOrganizations/test.com/tlsca/tlsca.test.com-cert.pem
```

显示加入的通道
```showjoined 
peer channel list \
-o orderer.test.com:7050 \
--cafile ./hyperledger_data/crypto-config/ordererOrganizations/test.com/tlsca/tlsca.test.com-cert.pem
```

安装智能合约

实例化智能合约


