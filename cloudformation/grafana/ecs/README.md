# Grafana Container Stack

## Description
Template to set up a distributed container stack running on EC2 Container Service

## Launch via AWS CLI
```
export AWS_REGION=us-east-1 AWS_PROFILE=aws-internal
```

```
aws cloudformation create-stack \
--stack-name grafana-$(date +%Y%m%d%H%M%S) \
--template-body file://$(pwd | tr -d '\n')/grafana-ecs-cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--tags Key=Name,Value=grafana Key=owner,Value=name@host.com Key=environment,Value=dev Key=project,Value=project Key=client,Value=rga \
--parameters file://$(pwd | tr -d '\n')/default-params.json \
--region ${AWS_REGION} \
--profile ${AWS_PROFILE}
```

## Additional Grafana Documentation

## Example projects
http://docs.grafana.org/
