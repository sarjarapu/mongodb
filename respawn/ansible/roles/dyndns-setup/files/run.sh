#!/bin/sh

# NOTE: added some delay purpose fully to avoid below error 
# An error occurred (InvalidParameterValueException) when calling the 
# CreateFunction operation: The role defined for the function cannot be assumed by Lambda.\n\nParameter validation failed:\nInvalid length for parameter Targets[0].Arn

files_dir=./roles/dyndns-setup/files
output_dir=/tmp

aws iam create-policy --policy-name ddns-lambda-policy --policy-document file://$files_dir/ddns-policy.json > $output_dir/policy_output.json
sleep 2
policyArn=$(cat $output_dir/policy_output.json | jq .Policy.Arn | sed 's/"//g')

aws iam create-role --role-name ddns-lambda-role --assume-role-policy-document file://$files_dir/ddns-trust.json > $output_dir/role_output.json
sleep 2
roleArn=$(cat $output_dir/role_output.json | jq .Role.Arn | sed 's/"//g')

aws iam attach-role-policy --role-name ddns-lambda-role --policy-arn $policyArn
sleep 2

cd roles/dyndns-setup/files
rm -f union.py.zip
zip union.py.zip union.py
cd ../../..

sleep 10

# create the lambda function to monitor the events 
aws lambda create-function --function-name ddns_lambda --runtime python2.7 --role $roleArn --handler union.lambda_handler --timeout 30 --zip-file fileb://$files_dir/union.py.zip > $output_dir/lambda_output.json
sleep 2
functionArn=$(cat $output_dir/lambda_output.json | jq .FunctionArn | sed 's/"//g')

# Create the CloudWatch Events Rule
aws events put-rule --event-pattern "{\"source\":[\"aws.ec2\"],\"detail-type\":[\"EC2 Instance State-change Notification\"],\"detail\":{\"state\":[\"running\",\"shutting-down\",\"stopped\"]}}" --state ENABLED --name ec2_lambda_ddns_rule > $output_dir/rule_output.json
ruleArn=$(cat $output_dir/rule_output.json | jq .RuleArn | sed 's/"//g')

# set the target of the rule to be the Lambda function
aws events put-targets --rule ec2_lambda_ddns_rule --targets Id=id$(date +%Y%m%d%H%M%S),Arn=$functionArn 

# add the permissions required for the CloudWatch Events rule to execute the Lambda function
aws lambda add-permission --function-name ddns_lambda --statement-id $(date +%S) --action lambda:InvokeFunction --principal events.amazonaws.com --source-arn $functionArn > $output_dir/add_permissions.json
