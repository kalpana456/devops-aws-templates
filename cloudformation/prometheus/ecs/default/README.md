# Prometheus Stack

## Description
TODO

## Launch via AWS CLI

```
aws cloudformation create-stack \
--stack-name prometheus-cw-$(date +%Y%m%d%H%M%S) \
--template-body file://$(pwd | tr -d '\n')/prometheus-ecs-cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--tags Key=Name,Value=prometheus-cw Key=owner,Value=name@host.com Key=environment,Value=dev Key=project,Value=prometheus-cw Key=client,Value=rga \
--parameters file://$(pwd | tr -d '\n')/deployments/aws-rga-VPCconnectedwork.json \
--region us-east-1 \
--profile rga
```

## Configuration
The prometheus template currently uses the prometheus.yml file in the current directory. This file needs to be customized and then a new docker image re-built and deployed.

## Adding Instances to the Monitoring Configuration
Instances can be added or removed from the configuration in the prometheus.yml file. This will get bundled in with the docker image that is built and deployed.
```
...
- job_name:       'example-environment'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 15s

    static_configs:
      - targets: ['10.2.3.4:8000']
        labels:
          group: 'dev'

      - targets: ['10.6.7.8:9000']
        labels:
          group: 'prd'
...
```

## Deployment
To update the version or configuration a new docker image will need to be built and deployed.

### Build a New Image
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
