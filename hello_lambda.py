import os


# def lambda_handler(event, context):
#     return "{} from Lambda!".format(os.environ['greeting'])

response = client.describe_images(
    ExecutableUsers=[
        'string',
    ],
    Filters=[
        {
            'Name': 'string',
            'Values': [
                'string',
            ]
        },
    ],
    ImageIds=[
        'string',
    ],
    Owners=[
        'string',
    ],
    IncludeDeprecated=True|False,
    DryRun=True|False
)
