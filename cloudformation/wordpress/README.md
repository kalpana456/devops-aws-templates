# README.md

# Description
Template for building out a WordPress instance with an ASG and Load Balancer. The mysql server uses RDS.

```
export AWS_REGION=us-east-1 AWS_PROFILE=aws-mercedes ENV=dev
```

```
aws cloudformation create-stack \
--stack-name content-hub-${ENV}-$(date +%Y%m%d%H%M%S) \
--template-body file://$(pwd | tr -d '\n')/content-hub-cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--tags Key=Name,Value=content-hub-${ENV} Key=owner,Value=name@host.com Key=environment,Value=${ENV} Key=project,Value=content-hub Key=client,Value=mercedes \
--parameters file://$(pwd | tr -d '\n')/params/${ENV}.json \
--region $AWS_REGION \
--profile $AWS_PROFILE
```
