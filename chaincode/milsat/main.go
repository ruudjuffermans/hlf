package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric-chaincode-go/shim"
	sc "github.com/hyperledger/fabric-protos-go/peer"
	"github.com/hyperledger/fabric/common/flogging"
)

// SmartContract Define the Smart Contract structure
type SmartContract struct {
}

// Car :  Define the car structure, with 4 properties.  Structure tags are used by encoding/json library
type Car struct {
	Make   string `json:"make"`
	Model  string `json:"model"`
	Colour string `json:"colour"`
	Owner  string `json:"owner"`
}

type SatelliteBus struct {
	BusID            string    `json:"bus_id"`
	PowerSubsystem   string    `json:"power_subsystem"`
	PropulsionSystem string    `json:"propulsion_system"`
	OnboardComputer  string    `json:"onboard_computer"`
	OwnerMSP         string    `json:"owner_msp"`
	Payloads         []Payload `json:"payloads"` // List of payloads associated with the satellite bus
}

type Payload struct {
	PayloadID   string `json:"payload_id"`
	Type        string `json:"type"`
	Description string `json:"description"`
	OwnerMSP    string `json:"owner_msp"`
}

type carPrivateDetails struct {
	Owner string `json:"owner"`
	Price string `json:"price"`
}

// Init ;  Method for initializing smart contract
func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

var logger = flogging.MustGetLogger("fabcar_cc")

// Invoke :  Method for INVOKING smart contract
func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	function, args := APIstub.GetFunctionAndParameters()
	logger.Infof("Function name is:  %d", function)
	logger.Infof("Args length is : %d", len(args))

	switch function {
	case "query":
		return s.queryCar(APIstub, args)
	case "initLedger":
		return s.initLedger(APIstub)
	case "createCar":
		return s.createCar(APIstub, args)
	case "queryAllCars":
		return s.queryAllCars(APIstub)
	default:
		return shim.Error("Invalid Smart Contract function name.")
	}
}

func (s *SmartContract) queryCar(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	carAsBytes, _ := APIstub.GetState(args[0])
	return shim.Success(carAsBytes)
}

func (s *SmartContract) initLedger(APIstub shim.ChaincodeStubInterface) sc.Response {
	// Create an array of Payloads to initialize the ledger with
	payloads := []Payload{
		Payload{PayloadID: "PAY001", Type: "Communication", Description: "High-frequency communication payload", OwnerMSP: "Org1MSP"},
		Payload{PayloadID: "PAY002", Type: "Optical", Description: "High-resolution optical camera", OwnerMSP: "Org2MSP"},
		Payload{PayloadID: "PAY003", Type: "Radar", Description: "Synthetic Aperture Radar (SAR)", OwnerMSP: "Org1MSP"},
		Payload{PayloadID: "PAY004", Type: "ELINT", Description: "Electronic intelligence for radar signal interception", OwnerMSP: "Org2MSP"},
		Payload{PayloadID: "PAY005", Type: "Navigation", Description: "GPS payload for precise positioning", OwnerMSP: "Org1MSP"},
	}

	// Iterate over the payloads array and store each payload in the ledger
	for i, payload := range payloads {
		payloadAsBytes, _ := json.Marshal(payload)                  // Convert the payload struct to bytes
		APIstub.PutState("PAYLOAD"+strconv.Itoa(i), payloadAsBytes) // Store each payload in the ledger
	}

	satelliteBuses := []SatelliteBus{
		SatelliteBus{BusID: "SAT001", PowerSubsystem: "Solar panels and batteries", PropulsionSystem: "Hydrazine thrusters", OnboardComputer: "ARM-based system", OwnerMSP: "Org2MSP"},
		SatelliteBus{BusID: "SAT002", PowerSubsystem: "Nuclear power source", PropulsionSystem: "Ion thrusters", OnboardComputer: "Quantum processing unit", OwnerMSP: "Org2MSP"},
		SatelliteBus{BusID: "SAT003", PowerSubsystem: "Solar panels", PropulsionSystem: "Electric thrusters", OnboardComputer: "FPGA-based system", OwnerMSP: "Org2MSP"},
		SatelliteBus{BusID: "SAT004", PowerSubsystem: "Batteries only", PropulsionSystem: "Chemical propulsion", OnboardComputer: "Single-board computer", OwnerMSP: "Org2MSP"},
		SatelliteBus{BusID: "SAT005", PowerSubsystem: "Hybrid solar and battery", PropulsionSystem: "Cold gas thrusters", OnboardComputer: "Dual-core onboard system", OwnerMSP: "Org2MSP"},
	}

	// Iterate over the satelliteBuses array and store each SatelliteBus in the ledger
	for i, satelliteBus := range satelliteBuses {
		satelliteBusAsBytes, _ := json.Marshal(satelliteBus)            // Convert the SatelliteBus struct to bytes
		APIstub.PutState("SATBUS"+strconv.Itoa(i), satelliteBusAsBytes) // Store each SatelliteBus in the ledger
	}

	return shim.Success(nil)
}

func (s *SmartContract) createPayloads(APIstub shim.ChaincodeStubInterface) sc.Response {
	// Create an array of Payloads to initialize the ledger with
	payloads := []Payload{
		Payload{PayloadID: "PAY001", Type: "Communication", Description: "High-frequency communication payload", OwnerMSP: "Org1MSP"},
		Payload{PayloadID: "PAY002", Type: "Optical", Description: "High-resolution optical camera", OwnerMSP: "Org1MSP"},
		Payload{PayloadID: "PAY003", Type: "Radar", Description: "Synthetic Aperture Radar (SAR)", OwnerMSP: "Org1MSP"},
		Payload{PayloadID: "PAY004", Type: "ELINT", Description: "Electronic intelligence for radar signal interception", OwnerMSP: "Org1MSP"},
		Payload{PayloadID: "PAY005", Type: "Navigation", Description: "GPS payload for precise positioning", OwnerMSP: "Org1MSP"},
	}

	for i, payload := range payloads {
		payloadAsBytes, _ := json.Marshal(payload)
		APIstub.PutState("PAYLOAD"+strconv.Itoa(i), payloadAsBytes)
	}

	return shim.Success(nil)
}

func (s *SmartContract) createCar(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 5 {
		return shim.Error("Incorrect number of arguments. Expecting 5")
	}

	var car = Car{Make: args[1], Model: args[2], Colour: args[3], Owner: args[4]}

	carAsBytes, _ := json.Marshal(car)
	APIstub.PutState(args[0], carAsBytes)

	indexName := "owner~key"
	colorNameIndexKey, err := APIstub.CreateCompositeKey(indexName, []string{car.Owner, args[0]})
	if err != nil {
		return shim.Error(err.Error())
	}
	value := []byte{0x00}
	APIstub.PutState(colorNameIndexKey, value)

	return shim.Success(carAsBytes)
}

func (s *SmartContract) queryAllCars(APIstub shim.ChaincodeStubInterface) sc.Response {

	startKey := "CAR0"
	endKey := "CAR999"

	resultsIterator, err := APIstub.GetStateByRange(startKey, endKey)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
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
	buffer.WriteString("]")

	fmt.Printf("- queryAllCars:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}

// func (s *SmartContract) restictedMethod(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

// 	// get an ID for the client which is guaranteed to be unique within the MSP
// 	//id, err := cid.GetID(APIstub) -

// 	// get the MSP ID of the client's identity
// 	//mspid, err := cid.GetMSPID(APIstub) -

// 	// get the value of the attribute
// 	//val, ok, err := cid.GetAttributeValue(APIstub, "attr1") -

// 	// get the X509 certificate of the client, or nil if the client's identity was not based on an X509 certificate
// 	//cert, err := cid.GetX509Certificate(APIstub) -

// 	val, ok, err := cid.GetAttributeValue(APIstub, "role")
// 	if err != nil {
// 		// There was an error trying to retrieve the attribute
// 		shim.Error("Error while retriving attributes")
// 	}
// 	if !ok {
// 		// The client identity does not possess the attribute
// 		shim.Error("Client identity doesnot posses the attribute")
// 	}
// 	// Do something with the value of 'val'
// 	if val != "approver" {
// 		fmt.Println("Attribute role: " + val)
// 		return shim.Error("Only user with role as APPROVER have access this method!")
// 	} else {
// 		if len(args) != 1 {
// 			return shim.Error("Incorrect number of arguments. Expecting 1")
// 		}

// 		carAsBytes, _ := APIstub.GetState(args[0])
// 		return shim.Success(carAsBytes)
// 	}

// }

// The main function is only relevant in unit test mode. Only included here for completeness.
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Error creating new Smart Contract: %s", err)
	}
}
