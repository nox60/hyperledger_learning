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
-c '{"Args":["init","a","100","b","200"]}' \
-P "AND ('Org1MSP.peer','Org2MSP.peer')"
```


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




