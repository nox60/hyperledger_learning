FROM hyperledger/fabric-tools:1.4.3

ENV GO111MODULE on

ENV GOPROXY https://goproxy.baidu.com/

ENV GOCACHE "/root/.cache/go-build"

ADD /root/codes/hyperledger_learning/chaincode1/chain1/mycode.go /opt/gopath/src/mychaincode

WORKDIR /opt/gopath/src

RUN go mod init mychaincode

RUN go mod vendor


