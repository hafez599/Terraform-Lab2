import boto3
import os

def lambda_handler(event, context):
    ses = boto3.client('ses')
    sender = os.environ['SENDER_EMAIL']
    
    # Extract details from the S3 event
    try:
        record = event['Records'][0]
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        
        subject = f"Infrastructure Alert: {os.environ['ENV'].upper()} State Updated"
        body_text = (f"Hello,\n\n"
                     f"A change has been detected in your Terraform state file.\n"
                     f"Bucket: {bucket}\n"
                     f"File: {key}\n"
                     f"Environment: {os.environ['ENV']}\n\n"
                     f"This is an automated notification.")

        ses.send_email(
            Source=sender,
            Destination={'ToAddresses': [sender]},
            Message={
                'Subject': {'Data': subject},
                'Body': {'Text': {'Data': body_text}}
            }
        )
        print("Notification sent successfully.")
    except Exception as e:
        print(f"Error sending email: {str(e)}")
        
    return {"status": "Process Complete"}
