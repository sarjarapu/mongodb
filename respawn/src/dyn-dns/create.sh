

aws iam create-policy --policy-name ddns-lambda-policy --policy-document file://./ddns-policy.json > policy_output.json
policyArn=$(cat policy_output.json | jq .Policy.Arn | sed 's/"//g')

aws iam create-role --role-name ddns-lambda-role --assume-role-policy-document file://./ddns-trust.json > role_output.json
roleArn=$(cat role_output.json | jq .Role.Arn | sed 's/"//g')


aws iam attach-role-policy --role-name ddns-lambda-role --policy-arn $policyArn

# create the lambda function to monitor the events 
aws lambda create-function --function-name ddns_lambda --runtime python2.7 --role $roleArn --handler union.lambda_handler --timeout 30 --zip-file fileb://./union.py.zip > lambda_output.json
functionArn=$(cat lambda_output.json | jq .FunctionArn | sed 's/"//g')

# Create the CloudWatch Events Rule
aws events put-rule --event-pattern "{\"source\":[\"aws.ec2\"],\"detail-type\":[\"EC2 Instance State-change Notification\"],\"detail\":{\"state\":[\"running\",\"shutting-down\",\"stopped\"]}}" --state ENABLED --name ec2_lambda_ddns_rule > rule_output.json
ruleArn=$(cat rule_output.json | jq .RuleArn | sed 's/"//g')

# set the target of the rule to be the Lambda function
aws events put-targets --rule ec2_lambda_ddns_rule --targets Id=id$(date +%Y%m%d%H%M%S),Arn=$functionArn 

# add the permissions required for the CloudWatch Events rule to execute the Lambda function
aws lambda add-permission --function-name ddns_lambda --statement-id $(date +%S) --action lambda:InvokeFunction --principal events.amazonaws.com --source-arn $functionArn > add_permissions.json
