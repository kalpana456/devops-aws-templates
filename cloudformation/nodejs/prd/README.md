# NodeJS Stack

## Description
This is a production stack. The key difference being all instances are created on private subnets and there are additional scheduled triggers available for scaling.

## Kicking off stack via CLI

aws cloudformation create-stack \
--stack-name year-with-uber-dev \
--template-body file:///Users/nauman/Work/REPOS/rga/AWS/templates/cloudformation/nodejs/node-cluster-elb-cfn.yaml \
--capabilities CAPABILITY_IAM \
--tags Key=Name,Value=year-with-uber-dev Key=owner,Value=name@host.com Key=environment,Value=dev Key=project,Value=year-with-uber Key=client,Value=uber \
--parameters file:///Users/nauman/Work/REPOS/rga/AWS/templates/cloudformation/nodejs/node-cluster-elb-cfn-params.json \
--region us-east-1 \
--profile rga-uber


