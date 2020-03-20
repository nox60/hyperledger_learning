FROM hyperledger/fabric-tools:1.4.3

ENV GO111MODULE on

ENV GOPROXY https://goproxy.baidu.com/

ENV GOCACHE "/root/.cache/go-build"

ADD chain1/mycode.go /opt/gopath/src/mychaincode

WORKDIR /opt/gopath/src

RUN go mod init mychaincode

RUN go mod vendor


