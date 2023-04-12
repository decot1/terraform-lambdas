import logging
import boto3
import json
import os
session = boto3.Session(region_name=os.environ['REGION'])
dynamodb_client = session.client('dynamodb')
def lambda_handler(event, context):
    try:
        print("event ->" + str(event))
        payload = json.loads(event["body"])
        print("payload ->" + str(payload))
        dynamodb_response = dynamodb_client.put_item(
            TableName=os.environ["errors_table"],
            Item={
                "product_id": {
                    "S": payload["errorId"]
                },
                "category": {
                    "S": payload["description"]
                },
                "product_rating": {
                    "S": payload["date"]
                }               
            }
        )
        print(dynamodb_response)
        return {
            'statusCode': 201,
           'body': '{"status":"Error registered"}'
        }
    except Exception as e:
        logging.error(e)
        return {
            'statusCode': 500,
           'body': '{"status":"Server error"}'
        }