## 源码

```solidity
pragma solidity >=0.4.22 <0.7.0;
contract HelloWorld {

    string saySomething;

    constructor() public  {
        saySomething = "Hello World!";
    }

    function speak() public view returns(string memory) {
        return saySomething;
    }

    function saySomethingElse(string memory newSaying) public  returns(bool success) {
        saySomething = newSaying;
        return true;
    }

}
```

## 编译
```shell
docker run  --rm -it \
-v /root/eth/contracts:/opt/contracts ethereum/solc:0.6.6 \
-o /opt/contracts \
--abi --bin /opt/contracts/hello.sol 
```

## 加载


## 参考文档

https://medium.com/datawallet-blog/how-to-deploy-a-local-private-ethereum-blockchain-c2b497f068f4

https://www.cnblogs.com/beyang/p/8469311.html