FROM hyperledger/fabric-tools:1.4.3

ENV GO111MODULE on

ENV GOPROXY https://goproxy.baidu.com/

ENV GOCACHE "/root/.cache/go-build"

ADD chain1/mycode.go /opt/gopath/src/chain1/mychaincode/mycode.go

WORKDIR /opt/gopath/src/chain1

RUN go mod init mychaincode

WORKDIR /opt/gopath/src/chain1/mychaincode

RUN go build

WORKDIR /opt/gopath/src/chain1

RUN go mod vendor


