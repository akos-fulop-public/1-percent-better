import os
def lambda_handler(event, context):
    print('## EVENT')
    print(event)
    print('## EVENT')
    print(context)
    return {'statusCode':200, 'body':"Hello from Lambda!"}
