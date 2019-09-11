package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	//"github.com/hyperledger/fabric/common/util"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
)

type MsgInAuth struct {
	Status bool   `json:"Status"`
	Code   int    `json:"Code"`
	Result string `json:"Result"`
}


//authorityChainCode   结构体
type authorityRecord struct {
	//授权记录的transaction id
	TxId string `json:"TxId"`
	//记录类型
	RecordType string `json:"RecordType"`
	//业务记录id
	BussinessTxId string `json:"BussinessTxId"`
	//授权时间
	AuthTime string `validate:"datetime",json:"AuthTime"`
	//监管机构id（授权经办机构）
	SupervisionInstitutionId string `json:"SupervisionInstitutionId"`
	//监管机构名（授权经办机构）
	SupervisionInstitutionName string `json:"SupervisionInstitutionName"`
	//授权人信息签名（智能合约生成）=授权人姓名+身份证的签名
	AthorInfoSin string `json:"AthorSin"`
	//授权信息签名
	AuthInfoSin string `json:"AuthInfoSin"`
}

func (t *authorityRecord) Init(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println("初始化授权记录的智能合约")
	return shim.Success(nil)
}
func (t *authorityRecord) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println("进入授权记录的智能合约")
	function, args := stub.GetFunctionAndParameters()

	fmt.Println("function："+function)
	fmt.Println("args[0] : "+args[0])
	//fmt.Println("args[1] : "+args[1])

	if function == "add" {
		// Make payment of X units from A to B
		return t.add(stub, args)
	} else if function == "delete" {
		// Deletes an entity from its state
		return t.delete(stub, args)
	} else if function == "query" {
		// the old "Query" is now implemtned in invoke
		return t.query(stub, args)
	} else if function == "getRecordPageByBookMark" {
		// the old "Query" is now implemtned in invoke
		return t.getRecordPageByBookMark(stub, args)
	} else if function == "getDataByDay" {
		// the old "Query" is now implemtned in invoke
		return t.getDataByDay(stub, args)
	}

	return shim.Error( "function: "+ function + " || Invalid invoke function name. Expecting \"invoke\" \"delete\" \"query\" \"getServiceRecord\"")
	//return shim.Error( "function：" + function )
}

//添加记录

func (t *authorityRecord) add(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	err := stub.PutState(args[1], []byte(string(args[2])))
	if err != nil {
		return shim.Error(err.Error())
	}
	fmt.Println("交易的id是" + args[1])
	return shim.Success([]byte(string(args[1])))
}

func (t *authorityRecord) delete(stub shim.ChaincodeStubInterface, args []string) pb.Response {
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

func (t *authorityRecord) query(stub shim.ChaincodeStubInterface, args []string) pb.Response {
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
	err := shim.Start(new(authorityRecord))
	if err != nil {
		fmt.Printf("Error starting Simple chaincode: %s", err)
	}

}

