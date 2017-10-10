## Launch via AWS CLI  
The following aws cli command will build the stack as long as the params in the parameters file being passed in are valid. This command must be run from the location of the template and parameters file.  

```
aws cloudformation create-stack \
--stack-name name-env-$(date +%Y%m%d%H%M%S) \
--template-body file://$(pwd | tr -d '\n')/java-elb-asg-cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--tags Key=Name,Value=name-env Key=owner,Value=name@email.com Key=environment,Value=env Key=project,Value=project-name Key=client,Value=client-name \
--parameters file://$(pwd | tr -d '\n')/params.json \
--region ${AWS_REGION} \
--profile ${AWS_PROFILE}
```

The --region argument must be passed in if one is not set in your aws profile.
The --profile argument can be left out if you are using the default profile.

# SAMPLE

## Set Environment Vars  
```
export AWS_REGION=us-east-1 AWS_PROFILE=aws-internal
```

## Create Stack
aws cloudformation create-stack \
--stack-name name-dev-$(date +%Y%m%d%H%M%S) \
--template-body file://$(pwd | tr -d '\n')/java-elb-asg-cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--tags Key=Name,Value=name-dev Key=owner,Value=name@host.com Key=environment,Value=dev Key=project,Value=vrsr Key=client,Value=client \
--parameters file://$(pwd | tr -d '\n')/default-params.json \
--region ${AWS_REGION} \
--profile ${AWS_PROFILE}

## Update Stack
aws cloudformation update-stack --capabilities CAPABILITY_NAMED_IAM --stack-name vrsr-dev22-20170831235801 --template-body file://$(pwd | tr -d '\n')/java-elb-asg-cfn.yaml  --parameters file://$(pwd | tr -d '\n')/default-params.json
