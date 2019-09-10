package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	//"github.com/hyperledger/fabric/common/util"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
	"strconv"
	"strings"
)

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

type authorityRequest struct {
	//业务记录id
	BussinessTxId string `json:"BussinessTxId"`
	//授权时间
	AuthTime string `validate:"datetime",json:"AuthTime"`
	//监管机构名（授权经办机构）
	SupervisionInstitutionName string `json:"SupervisionInstitutionName"`
	//授权人姓名
	Athor string `json:"Athor"`
	//授权人身份证
	AthorIDCard string `json:"AthorIDCard"`
	//授权信息签名
	AuthInfoSin string `json:"AuthInfoSin"`
}
type bussinessInAuth struct {
	Txid string `json:"Txid"`
	//记录类型
	RecordType string `json:"RecordType"`
	//业务时间
	BussinessTime string `validate:"datetime",json:"BussinessTime"`
	//业务机构id
	BussinessOrgId string `json:"BussinessOrgId"`
	//业务机构名
	BussinessOrgName string `json:"BussinessOrgName"`
	//授权人信息签名
	AthorSin string `json:"AthorSin"`
	//授权人身份证
	AthorIDCard string `json:"AthorIDCard"`
	//业务类型
	BussinessType string `json:"BussinessType"`
	//结束日期
	BussinessEndTime string `json:"BussinessEndTime"`
}
type MsgInAuth struct {
	Status bool   `json:"Status"`
	Code   int    `json:"Code"`
	Result string `json:"Result"`
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


	/*
	timeLayout := "2006-01-02 15:04:05"
	//go诞生时间

	loc, _ := time.LoadLocation("Local")
	var params string
	//各个具体的参数，以json形式，写在方法后作为args 的"一个"参数？？？
	if len(args) < 2 {
		return shim.Error("错误的参数，至少输入2个参数")
	}
	fmt.Println("参数长度：" + string(len(args)))
	var bussinessChaincodeId string = args[0]
	fmt.Println("业务记录chaincode名为：" + bussinessChaincodeId)

	params = args[1]

	data := []byte(params)
	//输入数据格式不对

	txId := stub.GetTxID()
	//[]byte形式的data，转换为authorityChainCode实体？
	auth_request := new(authorityRequest)

	err1 := json.Unmarshal(data, &auth_request)

	if err1 != nil {
		return shim.Error("转换出错，输入参数是：" + params)
	}

	//Marshal失败时err!=nil
	strIns, err := json.Marshal(auth_request)
	if err != nil {
		fmt.Println("生成json字符串错误")
		return shim.Error("生成json字符串错误")
	}
	if auth_request == nil {
		return shim.Error("输入为空" + params)
	}
	fmt.Println(auth_request)
	if auth_request.AthorIDCard == "" {
		fmt.Println("授权人身份证缺失")
		return pb.Response{
			Status:  10002,
			Message: "授权人身份证缺失",
		}
	}
	if auth_request.Athor == "" {
		fmt.Println("授权人姓名缺失")
		return pb.Response{
			Status:  10001,
			Message: "授权人姓名缺失",
		}
	}

	if auth_request.BussinessTxId == "" {
		fmt.Println("业务记录txid缺失")
		return pb.Response{
			Status:  10008,
			Message: "业务记录txid缺失",
		}
	}
	if auth_request.AuthTime == "" {
		fmt.Println("授权时间缺失")
		return pb.Response{
			Status:  10009,
			Message: "授权时间缺失",
		}
	} else {
		_, err := time.ParseInLocation(timeLayout, auth_request.AuthTime, loc)
		if err != nil {
			return pb.Response{
				Status:  10010,
				Message: "授权时间格式不正确",
			}
		}
	}
	if auth_request.AuthInfoSin == "" {
		fmt.Println("授权信息签名缺失")
		return pb.Response{
			Status:  10011,
			Message: "授权信息签名缺失",
		}
	}
	if auth_request.SupervisionInstitutionName == "" {
		fmt.Println("机构名称缺失")
		return shim.Error("机构名称缺失")
	}
	auth_struct := new(authorityRecord)
	auth_struct.TxId = txId
	//赋值，业务记录类型
	auth_struct.RecordType = "authority"
	bytes, err := stub.GetCreator()
	if err == nil {
		h := hmac.New(sha256.New, bytes)
		h.Write([]byte("cechealth"))
		//得到64为签名
		sha := hex.EncodeToString(h.Sum(nil))
		fmt.Println("添加权限的组织机构id", sha)
		auth_struct.SupervisionInstitutionId = sha
	}
	//todo 国密3加密
	auth_struct.AthorInfoSin = auth_request.AthorIDCard
	auth_struct.BussinessTxId = auth_request.BussinessTxId
	auth_struct.AuthInfoSin = auth_request.AuthInfoSin
	auth_struct.AuthTime = auth_request.AuthTime
	auth_struct.SupervisionInstitutionName = auth_request.SupervisionInstitutionName

	//查看业务记录是否有效
	//有效：如果业务记录是order订单类型的，那看使用记录里是否有使用过
	//     如果业务记录是contract合约类型的，看时间是否还有效
	//查看业务记录的id 对应的授权人信息，是否和传入一致
	//调用业务记录的智能合约，----再看业务类型 ---order，则再次以业务记录id调用使用记录智能合约的查询方法，---contract，则比较时间即可
	checkResponse := t.checkValidByQueryBussiness(stub, bussinessChaincodeId, auth_struct.BussinessTxId, auth_struct.AthorInfoSin)
	if checkResponse.Status != 200 {
		return checkResponse
	}
	////创建复合键
	//indexName := "bussiness_auth_key"
	//authUsageKey, err := stub.CreateCompositeKey(indexName, []string{auth_struct.BussinessTxId, auth_struct.TxId})
	//if err != nil {
	//	return shim.Error(err.Error())
	//}
	//value := []byte{0 * 100}
	////存入复合键
	//stub.PutState(authUsageKey, value)
	//
	*/
	err := stub.PutState(args[1], []byte(string(args[2])))
	if err != nil {
		return shim.Error(err.Error())
	}
	fmt.Println("交易的id是" + args[1])
	return shim.Success([]byte(string(args[1])))
}
func (t *authorityRecord) queryByBussinessTxId(stub shim.ChaincodeStubInterface, bussinessTxId string) (*authorityRecord, error) {
	fmt.Println("开始调用selector")
	queryString := "{\"selector\":{\"BussinessTxId\":" + "\"" + bussinessTxId + "\"" + "}}"
	fmt.Println(queryString)
	resultIterator, err := stub.GetQueryResult(queryString)
	if err != nil {
		return nil, err
	}
	defer resultIterator.Close()
	for resultIterator.HasNext() {
		item, err := resultIterator.Next()
		fmt.Println("selector查得:")
		fmt.Println(item)
		if err != nil {
			return nil, err
		}
		auth_struct := new(authorityRecord)
		err = json.Unmarshal(item.Value, &auth_struct)
		if err != nil {
			return nil, err
		}
		return auth_struct, nil
	}
	return nil, nil
}

//通过业务id查得权限记录id,返回string,以字符串隔开
//func (t *authorityRecord) queryByCompositeKey(stub shim.ChaincodeStubInterface, bussinessTxId string) pb.Response {
//	indexName := "bussiness_auth_key"
//	bussinessMarbleResultsIterator, err := stub.GetStateByPartialCompositeKey(indexName, []string{bussinessTxId})
//	if err != nil {
//		return shim.Error(err.Error())
//	} else if bussinessMarbleResultsIterator == nil {
//		return shim.Error("该业务记录在授权记录中无授权记录关联")
//	}
//	var auths string
//	var i int
//	for i = 0; bussinessMarbleResultsIterator.HasNext(); i++ {
//		responseRange, err := bussinessMarbleResultsIterator.Next()
//		if err != nil {
//			return shim.Error(err.Error())
//		}
//		//得到bussiness_auth_key复合键中的业务txid与权限txid的值
//		_, compositekeyParts, err := stub.SplitCompositeKey(responseRange.Key)
//		if err != nil {
//			return shim.Error(err.Error())
//		}
//		//returnedBussiness :=compositekeyParts[0]
//		returnedAuth := compositekeyParts[1]
//		auths = auths + " " + returnedAuth
//	}
//	return shim.Success([]byte(auths))
//}

func (t *authorityRecord) ToChaincodeArgs(args ...string) [][]byte {
	bargs := make([][]byte, len(args))
	for i, arg := range args {
		bargs[i] = []byte(arg)
	}
	return bargs
}

//检查是否有效
func (t *authorityRecord) checkValidByQueryBussiness(stub shim.ChaincodeStubInterface, bussinessChaincodeId string, bussinessTxId string, athorInfoSin string) pb.Response {
	args := []string{"query", bussinessTxId}
	if bussinessChaincodeId == "" {
		return shim.Error("bussinessChaincode id 缺失")
	}
	fmt.Println("开始调用业务记录chaincode")
	response := stub.InvokeChaincode(bussinessChaincodeId, t.ToChaincodeArgs(args...), "")
	fmt.Println("调用业务记录chaincode结果为:" + "  msg:" + string(response.Message) + "  payload:" + string(response.Payload))
	//调用成功但是没有查得的话，返回值示例如下：
	//status:500  msg:{"Error":"Nil amount for 036fceea0fd31aff82b7b88a82f73958a193e3f8705c92d96264071439f5"}  payload:
	if response.Status == 500 && response.Message == "" {
		return shim.Error(string(response.Payload))
	}
	if response.Status != 200 {
		return pb.Response{
			Status:  2000,
			Message: "业务记录不存在",
		}
	}
	data := response.Payload
	bussiness_struct := new(bussinessInAuth)
	err1 := json.Unmarshal(data, &bussiness_struct)

	if err1 != nil {
		return shim.Error("转换出错，权限返回参数是：" + string(data))
	}
	if bussiness_struct.AthorIDCard != athorInfoSin {
		return pb.Response{
			Status:  20003,
			Message: "业务记录与授权人信息不一致",
		}
	}

	authRecord, err := t.queryByBussinessTxId(stub, bussiness_struct.Txid)
	if err != nil {
		return shim.Error(err.Error())
	} else {
		if authRecord != nil {
			return pb.Response{
				Status:  20002,
				Message: "业务记录无效",
			}
		}
		return shim.Success([]byte("业务记录有效"))
	}
	//return shim.Success([]byte("业务记录有效"))
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

//todo 查询记录本身，及其关联的使用记录
//func (t *authorityRecord) queryWithUsage(stub shim.ChaincodeStubInterface, args []string) pb.Response {
//	if len(args) != 1 {
//		return shim.Error("Incorrect number of arguments. Expecting 1")
//	}
//	var key string
//	key = args[0]
//
//	// Delete the key from the state in ledger
//	Avalbytes, err := stub.GetState(key)
//	if err != nil {
//		return shim.Error("Failed to query state")
//	}
//	if Avalbytes == nil {
//		jsonResp := "{\"Error\":\"Nil amount for " + key + "\"}"
//		return shim.Error(jsonResp)
//	}
//
//
//	jsonResp := string(Avalbytes)
//	fmt.Printf("Query Response:%s\n", jsonResp)
//	return shim.Success(Avalbytes)
//}
// 查询
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

//分页
func (cc *authorityRecord) getRecordPageByBookMark(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 3 {
		return shim.Error("Incorrect number of arguments. Expecting 3")
	}
	queryString := args[0]
	pageSize, err := strconv.ParseInt(args[1], 10, 32)
	fmt.Println(queryString)
	fmt.Println(pageSize)
	if err != nil {
		message := "数据查询失败! 参数错误!"
		msg := &MsgInAuth{Status: false, Code: 0, Result: message}
		rev, _ := json.Marshal(msg)
		return shim.Success(rev)
	}
	bookmark := args[2]

	queryResults, err := getAuthQueryResultForQueryStringWithPagination(stub, queryString, int32(pageSize), bookmark)
	if err != nil {
		message := "查询失败! " + err.Error()
		msg := &MsgInAuth{Status: false, Code: 0, Result: message}
		rev, _ := json.Marshal(msg)
		return shim.Success(rev)
	}
	msg := &MsgInAuth{Status: true, Code: 0, Result: string(queryResults)}
	rev, _ := json.Marshal(msg)
	return shim.Success(rev)

}

func getAuthQueryResultForQueryStringWithPagination(stub shim.ChaincodeStubInterface, queryString string, pageSize int32, bookmark string) ([]byte, error) {

	fmt.Printf("- getQueryResultForQueryString queryString:\n%s\n", queryString)
	/**
	分页查询
	*/
	resultsIterator, responseMetadata, err := stub.GetQueryResultWithPagination(queryString, pageSize, bookmark)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	buffer, err := constructAuthQueryResponseFromIterator(resultsIterator, responseMetadata)
	if err != nil {
		return nil, err
	}

	//bufferWithPaginationInfo := addPaginationMetadataToQueryResults(buffer, responseMetadata)

	fmt.Printf("- getQueryResultForQueryString queryResult:\n%s\n", buffer.String())

	return buffer.Bytes(), nil
}

/**
迭代构建
*/
func constructAuthQueryResponseFromIterator(resultsIterator shim.StateQueryIteratorInterface, responseMetadata *pb.QueryResponseMetadata) (*bytes.Buffer, error) {
	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer

	buffer.WriteString("{\"RecordsCount\":")
	buffer.WriteString("\"")
	buffer.WriteString(fmt.Sprintf("%v", responseMetadata.FetchedRecordsCount))
	buffer.WriteString("\"")
	buffer.WriteString(", \"Bookmark\":")
	buffer.WriteString("\"")
	buffer.WriteString(responseMetadata.Bookmark)
	buffer.WriteString("\"")
	buffer.WriteString(", \"data\":")
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]}")
	return &buffer, nil
}

/**
统计数据
*/
func (cc *authorityRecord) getDataByDay(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}
	queryString := args[0]
	day := args[1]
	fmt.Println(queryString)
	fmt.Println(day)
	days := strings.Split(day, "@")
	var buffer bytes.Buffer
	bArrayMemberAlreadyWritten := false
	buffer.WriteString("[")
	for _, value := range days {
		qs := fmt.Sprintf(queryString, value)
		resultIterator, err := stub.GetQueryResult(qs)
		if err != nil {
			message := "数据查询失败! 参数错误!"
			msg := &MsgInAuth{Status: false, Code: 0, Result: message}
			rev, _ := json.Marshal(msg)
			return shim.Success(rev)
		}
		defer resultIterator.Close()
		var count int = 0
		for resultIterator.HasNext() {
			_, err := resultIterator.Next()
			if err != nil {
				fmt.Println(err)
				message := "数据查询失败! 参数错误!"
				msg := &MsgInAuth{Status: false, Code: 0, Result: message}
				rev, _ := json.Marshal(msg)
				return shim.Success(rev)
			}
			fmt.Println("count=", count)
			count = count + 1
		}
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"")
		buffer.WriteString(value)
		buffer.WriteString("\":")
		buffer.WriteString("\"")
		buffer.WriteString(strconv.Itoa(count))
		buffer.WriteString("\"")
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	fmt.Println("查询完成")
	buffer.WriteString("]")
	msg := &MsgInAuth{Status: true, Code: 0, Result: string(buffer.Bytes())}
	rev, _ := json.Marshal(msg)
	return shim.Success(rev)
}

func main() {
	//fmt.Println("hello world")
	err := shim.Start(new(authorityRecord))
	if err != nil {
		fmt.Printf("Error starting Simple chaincode: %s", err)
	}

}

