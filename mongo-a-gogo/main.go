package main

import (
	"log"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"

	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
)

type Experiment struct {
	ExperimentId string
	content      string
}

func main() {
	creds := credentials.NewEnvCredentials()
	cfg := &aws.Config{Region: aws.String("us-west-2")}
	cfg.WithCredentials(creds)
	sess := session.New(cfg)

	svc := dynamodb.New(sess)

	log.Println("Looking for tables...")

	result, err := svc.ListTables(&dynamodb.ListTablesInput{})

	log.Println("returned")

	if err != nil {
		log.Println(err)
		return
	}

	for _, table := range result.TableNames {
		log.Println(*table)
	}

	putParams := generatePutItemParams("123456", "{\"string\":\"val\"}", "php_experiment_config")
	resp, err := svc.PutItem(putParams)

	getParams := generateGetItemParams("123456", "{\"string\":\"val\"}", "php_experiment_config")
	resp, err := svc.GetItem(getParams)

	if err != nil {
		log.Println(err.Error())
		return
	}

	log.Println(resp)
}

func generateGetItemParams(experimentId string, body string, table string) *dynamodb.GetItemInput {
	params := &dynamodb.GetItemInput{
		Key: map[string]*dynamodb.AttributeValue{ // Required
			"ExperimentId": { // Required
				S: &experimentId,
			},
		},
		TableName: aws.String(table), // Required
		AttributesToGet: []*string{
			aws.String("content"), // Required
		},
		ConsistentRead: aws.Bool(true),
	}

	return params
}

func generatePutItemParams(experimentId string, body string, table string) *dynamodb.PutItemInput {
	params := &dynamodb.PutItemInput{
		Item: map[string]*dynamodb.AttributeValue{ // Required
			"ExperimentId": { // Required
				S: &experimentId,
			},
			"content": {
				S: &body,
			},
		},
		TableName:              aws.String(table), // Required
		ReturnConsumedCapacity: aws.String("TOTAL"),
	}

	return params
}
