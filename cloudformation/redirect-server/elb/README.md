# HA/FT Redirect Server with ELB and ASG

## Description
tbd

## Launch via AWS CLI
```
export AWS_PROFILE=aws-client AWS_REGION=us-east-1 ENV=prd
```

```
aws cloudformation create-stack \
--stack-name haredirect-${ENV}-$(date +%Y%m%d%H%M%S) \
--template-body file://$(pwd | tr -d '\n')/redirect-cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--tags Key=Name,Value=haredirect-${ENV} Key=owner,Value=name@host.com Key=environment,Value=${ENV} Key=project,Value=project Key=client,Value=client \
--parameters file://$(pwd | tr -d '\n')/params/${ENV}.json \
--region ${AWS_REGION} \
--profile ${AWS_PROFILE}
```
