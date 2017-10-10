# Simple Lambda Function

## Description
TBD

## Launch via AWS CLI
The following aws cli command will build the stack as long as the params in the parameters file being passed in are valid. This command must be run from the location of the template and parameters file.

```
aws cloudformation create-stack \
--stack-name name-env-$(date +%Y%m%d%H%M%S) \
--template-body file://$(pwd | tr -d '\n')/lambda-func-cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--tags Key=Name,Value=name-env Key=owner,Value=name@email.com Key=environment,Value=env Key=project,Value=project Key=client,Value=client \
--parameters file://$(pwd | tr -d '\n')/params.json \
--region ${AWS_REGION} \
--profile ${AWS_PROFILE}
```

## Parameters  
