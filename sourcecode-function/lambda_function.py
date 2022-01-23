import requests
import boto3
def lambda_handler(event='', context=''):
    response = requests.get("https://www.test.com/")
    print("hello")
    return response
