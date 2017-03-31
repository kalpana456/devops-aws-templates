# Add Basic Authentication to an S3 Bucket

## Description
This Cloudformation template allows you to set up Basic Authentication over an S3 Bucket. By default S3 does not support Basic Authentication.

## Detail
It creates a public EC2 instance running Nginx with Basic Auth which serves as a proxy to the private S3 Bucket.

**NOTE** The S3 Bucket's default policy will be overwritten by this template.

## S3 Bucket Requirements
The S3 Bucket should be created ahead of time. It will need to be in the same region as the EC2 instance.

#### AMI  
This template is currently using the default Amazon Linux Distribution.
You can find more details here: https://aws.amazon.com/amazon-linux-ami/

## Parameters  
##### Authentication  
- **BasicAuthUsername**  
The expected Basic Auth Username/Login.  
- **BasicAuthPassword**  
The expected Basic Auth Password.  
  
##### S3 Bucket Settings  
- **S3BucketName**  
The name of the S3 bucket you want to protect - NOTE - the existing bucket policy will be over-written. Also, it should not have any slashes (/).  
- **S3BucketPath**  
The path within the bucket - NOTE - it should start with / and end with path name; ex. /path/env.  
  
##### Instance Settings  
- **OperatorEmail**  
The email where notifications will be sent for Instance updates.  
- **EC2InstanceType**  
The size of EC2 Instance that should be used for the proxy. This should be left as a micro or nano unless requirements call for a larger size.  
- **EC2KeyPair**  
Key Pair that will be used to access EC2 instance - it is recommended that you generate a new key for your Dev instances. You should create a keypair in advance of running this template if you need a new one.  
- **AllowSSHFrom**  
IP address from which SSH will be allowed - the command to SSH will be like: *ssh -i {key-pair.pem} ec2-user@{ec2 instance ip}*  
- **VpcId**  
The VPC that this instance will be created in.  
- **SubnetPublic1**  
The first public subnet that this instance will be created in.  
- **SubnetPublic2**  
The second public subnet that this instance will be created in.  
  
##### Tags  
- **TagName**  
Name Tag used to track the name of the stack.  
- **TagEnvironment**  
Environment Tag used to track the environment version.  
- **TagOwner**  
Owner Tag used to track the creator/owner responsible for this Stack.  
- **TagClient**  
Client Tag used to track which client this instance is being used for.  
- **TagProject**  
Project Tag used to track which project this instance is being used for.  

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
--template-body file://$(pwd | tr -d '\n')/asg-lc-eip_awslinux.yaml \
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

