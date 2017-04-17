# GoCD Agent

## Description
TBD

## Launch via AWS CLI  
The following aws cli command will build the stack as long as the params in the parameters file being passed in are valid. This command must be run from the location of the template and parameters file.  

```
export AWS_REGION=us-east-1 AWS_PROFILE=aws-cw ENV=dev
```

```
aws cloudformation create-stack \
--stack-name gocd-agent-$(date +%Y%m%d%H%M%S) \
--template-body file://$(pwd | tr -d '\n')/gocd-agent-cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--tags Key=Name,Value=gocd-agent Key=owner,Value=nauman.hafiz@rga.com Key=environment,Value=${ENV} Key=project,Value=connectedwork Key=client,Value=rga \
--parameters file://$(pwd | tr -d '\n')/default-params.json \
--region ${AWS_REGION} \
--profile ${AWS_PROFILE}
```  

The --region argument must be passed in if one is not set in your aws profile.
The --profile argument can be left out if you are using the default profile.
