# EC2 Container Service Stack (Standalone Edition)  
  
## Description  
This Cloudformation template sets up a distributed EC2 Container Service (ECS) stack. This includes an auto scaling group, security groups, and an application load balancer.  

## Launch via AWS CLI  
The following aws cli command will build the stack as long as the params in the parameters file being passed in are valid. This command must be run from the location of the template and parameters file.  

```
export AWS_REGION=us-east-1 AWS_PROFILE=aws-internal ENV=dev
```

```
aws cloudformation create-stack \
--stack-name dap-repl-ap-us-${ENV}-$(date +%Y%m%d%H%M%S) \
--template-body file://$(pwd | tr -d '\n')/dynamo-replica-cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--tags Key=Name,Value=dap-repl-ap-us-${ENV} Key=owner,Value=name@host.com Key=environment,Value=${ENV} Key=project,Value=dap Key=client,Value=jnj \
--parameters file://$(pwd | tr -d '\n')/default-params.json \
--region ${AWS_REGION} \
--profile ${AWS_PROFILE}
```    

The --region argument must be passed in if one is not set in your aws profile.  
The --profile argument can be left out if you are using the default profile.  

## Parameters
#### Default  
- **InstanceType**  
     This is the instance size and type. Needs to be in the standard AWS format. Not all the AWS instance types are in the AllowedValues, so that should be updated per requirements.  
- **KeyName**  
    The Key Pair that will be used to allow SSH into this instance. This Key will need to be created before running this template.
- **OperatorEmail**  
    This email will be used as the default subscription for the SNS Topic, notifying the user of updates/errors for the instance. Additional subscribers can be added post creation.  
#### Networking  
- **VPCID**  
    This is the VPC that the instance will be deployed inside.
- **SubnetPublic1**  
    This is the first public subnet should that be part of the VPC listed above.
- **SubnetPublic2**  
    This is the first public subnet should that be part of the VPC listed above.
- SubnetPrivate1 (COMMENTED OUT)  
    This is the first private subnet should that be part of the VPC listed above. You can use this as an option if you want extra security around the container cluster.
- SubnetPrivate2 (COMMENTED OUT)  
    This is the second private subnet should that be part of the VPC listed above. You can use this as an option if you want extra security around the container cluster.
- **AllowIP**  
    The IP Range that will be whitelisted on port 22 to allow SSH to the EC2 instances. Set this as your external IP. WARNING - make sure this is a secure IP Range.  
- **BastionSecurityGroup** (COMMENTED OUT)  
    The security group that the bastion host instance uses - this is needed if you are using Private Subnets and need to SSH into the instance.  
#### Docker Container  
- **ContainerImage**  
    The Docker Container Image that will run on this cluster. This should include the tag. When running an Update Stack, you can just update the tag version for this image to deploy the next build.  
- **BuildVersion**  
    This param should match the Docker Container Image "Tag" and can be passed into the application as an environment variable.  
- **BuildDate**  
    This param should match the date and can be passed into the application as an environment variable.  
- **ContainerDesiredCount**  
    The number of Container Services that should be running.  
- **ContainerPortIn**  
    The port into the Docker Container  
- **ContainerPortOut**  
    The port that is mapped from the outside of the Docker Container  
- **ContainerHealthCheckPath**  
    The Healthcheck path that the Load Balancer will use to confirm instance status. For the root this can be set to \
- **ContainerTargetPathPattern**  
    The path that the load balancer will route requests to - this should be set to /* for everything
- **TaskMemory**  
#### Cluster Settings
    The amount of memory that should be available to each task
- **LoadBalancerListenPort**  
    The port that the load balancer should be accessed at
- **ClusterMaxSize**  
    The max number of instances the cluster can scale up to
- **ClusterMinSize**  
    The min number of instances the cluster can scale down to
- **ClusterDesiredSize**  
    The desired number of instances the cluster should be set at
- **ScheduledMaxInstanceCount**  (COMMENTED OUT)
    An optional parameter that can be set to set scheduled scaling attributes. This is the max number of instances.
- **ScheduledMinInstanceCount**  
    An optional parameter that can be set to set scheduled scaling attributes. This is the min number of instances.
- **ScheduledUpRecurrence**  
    An optional parameter that can be set to set scheduled scaling attributes. This allows the cluster to scale up at specific times.
- **ScheduledDownRecurrence**
    An optional parameter that can be set to set scheduled scaling attributes. This allows the cluster to scale down at specific times.  
- **SSLCertificateId**  
    The SSL certificate that will be added to port 443 on the Application Load Balancer
#### Tags  
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
    