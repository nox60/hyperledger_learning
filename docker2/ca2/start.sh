#!/bin/bash

docker rm -f ca.dams.com

docker run -it -d  \
  --name ca.dams.com \
      -p 7054:7054 \
      -e FABRIC_CA_HOME="/opt/serverhome" \
      -v /root/codes/hyperledger_learning/docker2/ca2/ca_server:/opt/serverhome \
      hyperledger/fabric-ca:1.4.3

