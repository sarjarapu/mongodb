--profile ava-us-west-1

aws iam create-policy --policy-name ddns-lambda-policy --policy-document file://./ddns-policy.json --profile ava-us-west-1 
# "Arn": "arn:aws:iam::286221877615:policy/ddns-lambda-policy"

aws iam create-role --role-name ddns-lambda-role --assume-role-policy-document file://./ddns-trust.json --profile ava-us-west-1 
# "Arn": "arn:aws:iam::286221877615:role/ddns-lambda-role"

aws iam attach-role-policy --role-name ddns-lambda-role --policy-arn "arn:aws:iam::286221877615:role/avpc-ddns-lambda-role" --profile ava-us-west-1

# create the lambda function to monitor the events 
aws lambda create-function --function-name ddns_lambda --runtime python2.7 --role "arn:aws:iam::286221877615:role/avpc-ddns-lambda-role" --handler union.lambda_handler --timeout 30 --zip-file fileb://./union.py.zip  --profile ava-us-west-1
# "FunctionArn": "arn:aws:lambda:us-west-1:286221877615:function:ddns_lambda",

# Create the CloudWatch Events Rule
aws events put-rule --event-pattern "{\"source\":[\"aws.ec2\"],\"detail-type\":[\"EC2 Instance State-change Notification\"],\"detail\":{\"state\":[\"running\",\"shutting-down\",\"stopped\"]}}" --state ENABLED --name ec2_lambda_ddns_rule  --profile ava-us-west-1
# "RuleArn": "arn:aws:events:us-west-1:286221877615:rule/ec2_lambda_ddns_rule"

# set the target of the rule to be the Lambda function
aws events put-targets --rule ec2_lambda_ddns_rule --targets Id=id973287328807,Arn="arn:aws:lambda:us-west-1:286221877615:function:ddns_lambda"  --profile ava-us-west-1

# add the permissions required for the CloudWatch Events rule to execute the Lambda function
aws lambda add-permission --function-name ddns_lambda --statement-id 47 --action lambda:InvokeFunction --principal events.amazonaws.com --source-arn "arn:aws:events:us-west-1:286221877615:rule/ec2_lambda_ddns_rule"  --profile ava-us-west-1


# Create the private hosted zone in Route 53
# Create a DHCP options set and associate it with the VPC



aws dynamodb list-tables  --profile ava-us-west-1