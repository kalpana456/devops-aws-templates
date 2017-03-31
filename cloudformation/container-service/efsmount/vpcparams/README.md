# Default Container Stack w/ EFS

## Description
Template to set up a distributed container stack running on EC2 Container Service with EFS for a persistent file system

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
--template-body file://$(pwd | tr -d '\n')/ecs-svc-tasks-asg-elb-efs-cfn.yaml \
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
  
## Deployment
To update the version or configuration a new docker image will need to be built and deployed.

### From Public Repo
Just run an Update Stack with the new version of the docker container (ex. grafana/grafana:latest)

### Or Build a New Image
This command will build a new version of the docker image, pulling in the local prometheus.yml configuration file.
```
docker build -t prometheus-cfg:version .
```

### Test Locally
You can run the new docker image locally to confirm that it is working.
```
docker run -p 9090:9090 prometheus-cfg:version
```
It will now be accessible at localhost:9090

### Tagging the Image
Before the image is pushed up, it must be tagged with the repository name.
```
docker tag prometheus-cfg:latest repo.us-east-1.amazonaws.com/prometheus-cfg:version
```

### Push to Repo
Once tagged, you can push the image up to the repository
```
docker push repo.dkr.ecr.us-east-1.amazonaws.com/prometheus-cfg:version
```

## Additional Prometheus Documentation

## Example projects
https://github.com/awslabs/ecs-refarch-cloudformation
