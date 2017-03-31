# Default AWS Linux EC2 Instance for High Availability / Fault Tolerance

## Descriptions  
Launch one (1) AWS Linux EC2 instance within an ASG to maintain HA/FT for a single instance. There is no ELB set up for this template, but an Elastic IP can be added to ensure that the instance has a static ip.  

This instance will be set up with a Security Group, SNS Topic, Role and Access Policy. The SNS Topic is also used for notifications when CPU is maxing out.

The AMI's for this template as well as the regions are not all up to date. You can find more details here:
https://aws.amazon.com/amazon-linux-ami/

## Parameters  
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

## Parameters File

The default-params.json file is a sample parameters file with stub values. You should replace these values and run the aws cli to trigger the building of your stack.

## Launch Cloudformation Stack via AWS CLI

The following aws cli command will build the stack using the params listed in the parameters file. This command must be run from the location of the template and parameters file.  

Set up these variables which will determine the stack name and tags:
```
export AWS_REGION=us-east-1     \
AWS_PROFILE={profile_name}      \
STACK_NAME={stack_name}         \
OWNER_EMAIL={email_address}     \
ENV={environment}               \
PROJECT_NAME={project_name}     \
CLIENT_NAME={client_name}    
```

Run the aws cli create-stack command to trigger building your stack:
```
aws cloudformation create-stack                     \
--stack-name ${STACK_NAME}-$(date +%Y%m%d%H%M%S)    \
--template-body file://$(pwd | tr -d '\n')/asg-lc-sns_awslinux.yaml \
--capabilities CAPABILITY_NAMED_IAM                 \
--tags Key=Name,Value=${STACK_NAME}                 \
Key=owner,Value=${OWNER_EMAIL}                      \
Key=environment,Value=${ENV}                        \
Key=project,Value=${PROJECT_NAME}                   \
Key=client,Value=${CLIENT_NAME}                     \
--parameters file://$(pwd | tr -d '\n')/default-params.json \
--region ${AWS_REGION}      \
--profile ${AWS_PROFILE}
```

The --region argument must be passed in if one is not set in your aws profile.
The --profile argument can be left out if you are using the default profile.

