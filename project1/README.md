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
```installchain
peer chaincode install \
-p sacc \
-l golang \
-n sacc \
-v 0 \
-o orderer.test.com:7050 \
--cafile ./hyperledger_data/crypto-config/ordererOrganizations/test.com/tlsca/tlsca.test.com-cert.pem
```

实例化智能合约
```installchain
peer chaincode instantiate  \
-C mychannel \
-l golang \
-n sacc \
-v 0 \
-o orderer.test.com:7050 \
--cafile ./hyperledger_data/crypto-config/ordererOrganizations/test.com/tlsca/tlsca.test.com-cert.pem \
-c '{"Args":["a","10"]}' \
-P "OR ('Org1MSP.admin')"
```

peer chaincode instantiate \
-o  orderer.dams.com:7050  \
-C ca \
-n insurencebussiness \
-v 1.0 -c '{"Args":[]}' \
-P "OR ('Ia3MSP.member')"  \
--tls true \
--cafile tlsca.dams.com-cert.pem



列出已经安装的智能合约
```installchain
peer chaincode list  \
-p sacc \
-l golang \
-n sacc \
-v 0 \
-o orderer.test.com:7050 \
--cafile ./hyperledger_data/crypto-config/ordererOrganizations/test.com/tlsca/tlsca.test.com-cert.pem
```


















/---------------------




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

