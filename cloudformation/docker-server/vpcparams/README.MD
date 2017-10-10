# Docker Server Hub Instance

## Description

## Generate Keys
Follow the directions here:  
https://docs.docker.com/engine/security/https/

## Create Stack
```
aws cloudformation create-stack \
--stack-name docker-server-dev-$(date +%Y%m%d%H%M%S) \
--template-body file://$(pwd | tr -d '\n')/docker-server-cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--tags Key=Name,Value=docker-server-dev Key=owner,Value=name@host.com Key=environment,Value=dev Key=project,Value=docker-server Key=client,Value=client \
--parameters file://$(pwd | tr -d '\n')/docker-server-cfn-params.json \
--region us-east-1 \
--profile aws-internal
```





