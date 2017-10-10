# Default Container Stack w/ EFS (import vpc version)

## Description
Template to set up a distributed container stack running on EC2 Container Service with EFS for a persistent file system

## Launch via AWS CLI

```
aws cloudformation create-stack \
--stack-name ecs-stack-default \
--template-body file://$(pwd | tr -d '\n')/ecs-cluster-asg-elb-efs-cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--tags Key=Name,Value=stack-default Key=owner,Value=name@host.com Key=environment,Value=dev Key=project,Value=stack-default Key=client,Value=rga \
--parameters file://$(pwd | tr -d '\n')/ecs-cluster-asg-elb-efs-cfn-params.json \
--region us-east-1 \
--profile rga-cw
```

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
