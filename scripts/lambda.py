import os
import boto3
from datetime import datetime

def lambda_handler(event, context):
    print('## EVENT')
    print(event)
    print('## EVENT')
    print(context)
    db_client = boto3.client("dynamodb")
    db_client.put_item(TableName="example",Item={"TestTableHashKey": {"S": datetime.now().strftime("%x %X")}})
    return {'statusCode':200, 'body':"Hello from Lambda!"}
