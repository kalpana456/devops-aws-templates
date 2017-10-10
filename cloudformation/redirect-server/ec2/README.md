# HA/FT Redirect Server with ELB and ASG

## Description
tbd

## Launch via AWS CLI
```
export AWS_PROFILE=aws-mccormick AWS_REGION=us-east-1 ENV=prd
```

```
aws cloudformation create-stack \
--stack-name mck-osinabox-redirect-${ENV}-$(date +%Y%m%d%H%M%S) \
--template-body file://$(pwd | tr -d '\n')/ec2-eip-redirect-prd-cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--tags Key=Name,Value=mck-osinabox-redirect-${ENV} Key=owner,Value=name@host.com Key=environment,Value=${ENV} Key=project,Value=osinabox Key=client,Value=mccormick \
--parameters file://$(pwd | tr -d '\n')/default-params.json \
--region ${AWS_REGION} \
--profile ${AWS_PROFILE}
```
