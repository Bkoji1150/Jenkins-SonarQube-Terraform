import os


def lambda_handler(event, context):
    print()
    return "{} from Lambda!".format(os.environ['greeting'])
