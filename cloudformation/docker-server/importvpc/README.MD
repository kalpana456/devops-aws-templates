# Docker Server Hub Instance

## Description

## Generate Keys
Follow the directions here:  
https://docs.docker.com/engine/security/https/

## Create Stack
```
export AWS_REGION=us-east-1 AWS_PROFILE=aws-appliedml ENV=dev
```

```
aws cloudformation create-stack \
--stack-name docker-server-${ENV}-$(date +%Y%m%d%H%M%S) \
--template-body file://$(pwd | tr -d '\n')/docker-server-cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--tags Key=Name,Value=docker-server-${ENV} Key=owner,Value=name@host.com Key=environment,Value=${ENV}dev Key=project,Value=docker-server Key=client,Value=aml \
--parameters file://$(pwd | tr -d '\n')/docker-server-cfn-params.json \
--region ${AWS_REGION} \
--profile ${AWS_PROFILE}
```





