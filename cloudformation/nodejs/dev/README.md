# NodeJS Development Stack

## Description
This is a development stack. The key difference being all instances are created on public subnets.

## Create Stack Via AWS CLI
```
aws cloudformation create-stack \
--stack-name node-dev-$(date +%Y%m%d%H%M%S) \
--template-body file://$(pwd | tr -d '\n')/node-cluster-elb-cfn.yaml \
--capabilities CAPABILITY_IAM \
--tags Key=Name,Value=node-dev Key=owner,Value=name@host.com Key=environment,Value=dev Key=project,Value=vz-dbi-node Key=client,Value=verizon \
--parameters file://$(pwd | tr -d '\n')/node-cluster-elb-cfn-params.json
```
