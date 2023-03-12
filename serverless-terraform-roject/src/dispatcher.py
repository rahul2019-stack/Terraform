import boto3
import os

def lambda_handler(event, context):
    print(f"Hello from dispatcher")
    client = boto3.client('sns')
    response = client.publish(
        TopicArn=os.environ["sns_topic_arn"],
        Message='Hi from lambda to sns and then to sqs',
        Subject='Message sent'
    )
    print(f"Msg dispatched")
