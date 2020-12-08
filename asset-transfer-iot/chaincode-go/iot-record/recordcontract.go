/*
 * SPDX-License-Identifier: Apache-2.0
 */

package iotrecord

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// Contract chaincode that defines
// the business logic for managing commercial
// record
type Contract struct {
	contractapi.Contract
}

// Instantiate does nothing
func (c *Contract) Instantiate(ctx TransactionContextInterface) {
	fmt.Println("Instantiated")
}

// AddRecord to save record
func (c *Contract) AddRecord(ctx TransactionContextInterface, jsonStr string) error {
	fmt.Println("AddRecord")
	var err error
	if json.Valid([]byte(jsonStr)) {
		record := IoTRecord{}
		err = record.parseJSON(jsonStr)
		if err == nil {
			ctx.GetRecordList().AddRecord(&record)
		}
	} else {
		err = errors.New("Invalid JSON string")
	}
	return err
}

// QueryRecord used to query record from world state
func (c *Contract) QueryRecord(ctx TransactionContextInterface, ID string) (string, error) {
	fmt.Println("QueryRecord")
	payload, err := ctx.GetRecordList().GetRecord(ID)
	if err != nil {
		return "", err
	}
	record := bytes.NewBuffer(payload).String()
	fmt.Println("QueryRecord Result:")

	fmt.Println(record)
	// s := string(payload)
	return record, err
}

// QueryRecordByRange used to query record from world state
func (c *Contract) QueryRecordByRange(ctx TransactionContextInterface, startKey string, endKey string) (string, error) {
	fmt.Println("QueryRecordByRange")
	payload, err := ctx.GetRecordList().GetRecordByRange(startKey, endKey)
	if err != nil {
		return "", err
	}
	record := bytes.NewBuffer(payload).String()
	fmt.Println("QueryRecordByRange Result:")

	fmt.Println(record)
	// s := string(payload)
	return record, err
}

// QueryRecordHistoryByTimeRange query record by time range
func (c *Contract) QueryRecordHistoryByTimeRange(ctx TransactionContextInterface, ID string, start string, end string) (string, error) {
	payload, err := ctx.GetRecordList().GetHistoryForRecordByTimeRange(ID, start, end)
	if err != nil {
		return "", err
	}
	record := bytes.NewBuffer(payload).String()
	fmt.Println("QueryRecordHistoryByTimeRange Result:")

	fmt.Println(record)
	// s := string(payload)
	return record, err
}

// QueryRecordHistory query record by time range
func (c *Contract) QueryRecordHistory(ctx TransactionContextInterface, ID string) (string, error) {
	payload, err := ctx.GetRecordList().GetHistoryForRecord(ID)
	if err != nil {
		return "", err
	}
	record := bytes.NewBuffer(payload).String()
	fmt.Println("QueryRecordHistory Result:")

	fmt.Println(record)
	// s := string(payload)
	return record, err
}
