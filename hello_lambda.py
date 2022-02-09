#!/usr/bin/env python3
import sys
import boto3
import json
from pprint import pprint
# aws_mag_con=boto3.session.Session()


client = boto3.client('secretsmanager',region_name="us-east-1")
# client =aws_mag_con.client(service_name='secretsmanager',region_name="us-east-1")

def lambda_handler(event='', context=''):
    try:
        list_se =  client.list_secrets()
        for arn in list_se['SecretList']:
            # print(arn.get('ARN'), 
            # arn.get('SecretVersionsToStages'))
            response = client.get_secret_value(SecretId=arn.get('ARN'))
            database_secrets = json.loads(response['SecretString'])
            print(database_secrets['password'], database_secrets['username']) 
    except Exception as e:
        print(e) 
