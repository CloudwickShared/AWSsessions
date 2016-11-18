# Log analytics with Elasticsearch

This is an automation of [this tutorial from Amazon](https://d0.awsstatic.com/Projects/P4113850/aws-projects_build-log-analytics-solution-on-aws.pdf), which you can look at for additional context.  One thing to bear in mind - this isn't purely copy paste.  My amazon account number is 749..... and that is hardcoded in some of these files.  For your automated deployment, you should of course use your own. To find that from the command line, `aws iam get-user` and you will see you UserID.

## Step 1

The setup script has already installed the fake apache log generator and AWS Kinesis agent on your EC2 instance. We will use `/home/ec2-user/logs/tutorial*` as the prefix for our log files.

## Step 2

### Create a bucket to catch the logs:

`aws s3 mb s3://cloudwick-tutorial-log-bucket`

### Create a role for Firehose with permission to write to that bucket:

Put the following into fire.json:
```
{
                "Version": "2012-10-17", 
                "Statement": [
                    {
                        "Action": "sts:AssumeRole", 
                        "Principal": {
                            "Service": "firehose.amazonaws.com"
                        }, 
                        "Effect": "Allow", 
                        "Condition": {
                            "StringEquals": {
                                "sts:ExternalId": "749147323776"
                            }
                        }, 
                        "Sid": ""
                    }
                ]
}
```

and run `aws iam create-role --role-name fire-role --assume-role-policy-document file://fire.json`


Then put the following into `newpolicy.json`:
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::cloudwick-tutorial-log-bucket",
        "arn:aws:s3:::cloudwick-tutorial-log-bucket/*"
      ]
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:eu-west-1:749147323776:log-group:/aws/kinesisfirehose/web-log-ingestion-stream:log-stream:*"
      ]
    }
  ]
}
```

And run `aws iam create-policy --policy-name fire-access --policy-document file://newpolicy.json`


Finally you need to attach the policy with:

```
aws iam attach-role-policy --role-name fire-role --policy-arn arn:aws:iam::749147323776:policy/fire-access
```


### Create a bucket

Put the following configuration into firehose.json:

```
{
            "RoleARN": "arn:aws:iam::749147323776:role/fire-role",
            "BucketARN": "arn:aws:s3:::cloudwick-tutorial-log-bucket",
            "Prefix": "logs",
            "CompressionFormat": "UNCOMPRESSED",
            "EncryptionConfiguration": {
              "NoEncryptionConfig": "NoEncryption"
            },
            "CloudWatchLoggingOptions": {
              "Enabled": false
            }
}
```
Then run `aws firehose create-delivery-stream --delivery-stream-name web-log-ingestion-stream --s3-destination-configuration file://firehose.json`.

Now you have a configured firehose delivering to S3.

### Sending logs to the firehose





```
{
 "cloudwatch.endpoint": "monitoring.us-east-1.amazonaws.com",
 "cloudwatch.emitMetrics": true,
 "firehose.endpoint": "firehose.us-east-1.amazonaws.com",
 "flows": [
 {
 "filePattern": "/home/ec2-user/logs/tutorial*",
 "deliveryStream": "cloudwick-tutorial-stream",
 "dataProcessingOptions": [
 {
 "initialPostion": "START_OF_FILE",
 "maxBufferAgeMillis":"2000",
 "optionName": "LOGTOJSON",
 "logFormat": "COMBINEDAPACHELOG"
 }]
 }
 ]
}
```