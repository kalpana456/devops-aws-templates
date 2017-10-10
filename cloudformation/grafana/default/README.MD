# Grafana running on AWS Linux EC2 Instance

## Descriptions  
TBD

## Launch via AWS CLI
```
export AWS_REGION=us-east-1 AWS_PROFILE=aws-internal
```

```
aws cloudformation create-stack \
--stack-name grafana-$(date +%Y%m%d%H%M%S) \
--template-body file://$(pwd | tr -d '\n')/grafana-asg-awslinux-cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--tags Key=Name,Value=grafana Key=owner,Value=name@host.com Key=environment,Value=dev Key=project,Value=grafana Key=client,Value=client \
--parameters file://$(pwd | tr -d '\n')/default-params.json \
--region ${AWS_REGION} \
--profile ${AWS_PROFILE}
```

## Parameters  
TBD
The parameters required by this template are detailed below:  

- **InstanceType**  
    This is the instance size and type. Needs to be in the standard AWS format. Not all the AWS instance types are in the AllowedValues, so that should be updated per requirements.
- **KeyName**  
    The Key Pair that will be used to allow SSH into this instance. This Key will need to be created before running this template.
- **OperatorEmail**  
    This email will be used as the default subscription for the SNS Topic, notifying the user of updates/errors for the instance. Additional subscribers can be added post creation.
- **VPCID**  
    This is the VPC that the instance will be deployed inside.
- **SubnetPublic1**  
    This is the first public subnet should that be part of the VPC listed above.
- **SubnetPublic2**  
    This is the second public subnet should that be part of the VPC listed above.
- **SSHLocation**  
    The IP Range that will be whitelisted on port 22 to allow SSH to the EC2 instances. Set this as your external IP. WARNING - make sure this is a secure IP Range.
- **UserDataScript**  
    You can append additional scripting to the UserData which will run on boot. Make sure that commands are seperated by ; or && 
- **TagName**  
    Tag used for tracking purposes.
- **TagOwner**  
    Tag used for tracking purposes.
- **TagClient**  
    Tag used for tracking purposes.
- **TagProject**  
    Tag used for tracking purposes.
- **TagEnvironment**  
    Tag used for tracking purposes.
  
  