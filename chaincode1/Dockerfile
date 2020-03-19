FROM hyperledger/fabric-tools:1.4.3

ENV GO111MODULE on

ENV GOPROXY https://goproxy.baidu.com/

RUN go mod init

RUN go mod vendor

ADD vendor/ /opt/gopath/src

ADD mycode.go /opt/gopath/src/mychaincode

