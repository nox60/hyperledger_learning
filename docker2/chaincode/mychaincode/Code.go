package main

import (
	"encoding/json"
	"fmt"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

type User struct {
	id   string `json:"id"`
	name string `json:"name"`
}

//authorityChainCode   结构体
type SmartContract struct {
}

func (t *SmartContract) Init(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println("初始化授权记录的智能合约")
	return shim.Success(nil)
}

func (t *SmartContract) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println("进入授权记录的智能合约")
	function, args := stub.GetFunctionAndParameters()

	fmt.Println("function：" + function)
	fmt.Println("args[0] : " + args[0])

	if len(args) > 2 {
		fmt.Println("args[1] : " + args[1])
	}

	if function == "add" {
		// Make payment of X units from A to B
		return t.add(stub, args)
	} else if function == "delete" {
		// Deletes an entity from its state
		return t.delete(stub, args)
	} else if function == "query" {
		// the old "Query" is now implemtned in invoke
		return t.query(stub, args)
	}

	return shim.Error("function: " + function + " || Invalid invoke function name. Expecting \"invoke\" \"delete\" \"query\" \"getServiceRecord\"")
	//return shim.Error( "function：" + function )
}

//添加记录
func (t *SmartContract) add(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	var user = User{id: args[0], name: args[1]}

	userAsBytes, _ := json.Marshal(user)
	fmt.Println("======")

	fmt.Println(userAsBytes)
	fmt.Println("======")

	err := stub.PutState(args[0], userAsBytes)

	if err != nil {
		return shim.Error(err.Error())
	}

	fmt.Println("插入的id是" + args[0])

	return shim.Success([]byte(string(args[0])))
}

func (t *SmartContract) delete(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	A := args[0]

	// Delete the key from the state in ledger
	err := stub.DelState(A)
	if err != nil {
		return shim.Error("Failed to delete state")
	}

	return shim.Success(nil)
}

func (t *SmartContract) query(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}
	var A string
	A = args[0]

	// Delete the key from the state in ledger
	Avalbytes, err := stub.GetState(A)
	if err != nil {
		return shim.Error("Failed to query state")
	}
	if Avalbytes == nil {
		jsonResp := "{\"Error\":\"Nil amount for " + A + "\"}"
		return shim.Error(jsonResp)
	}

	jsonResp := string(Avalbytes)
	fmt.Printf("Query Response:%s\n", jsonResp)
	return shim.Success(Avalbytes)
}

func main() {
	//fmt.Println("hello world")
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error starting Simple chaincode: %s", err)
	}
}
