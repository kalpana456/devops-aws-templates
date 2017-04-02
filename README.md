![R/GA](./rga_logo.png?raw=true "R/GA")

# DevOps AWS Templates

This repository contains a list of templates, scripts, and sample code for building and managing infrastructure on Amazon Web Services.  

- [Cloudformation](#cloudformation)
  - [Container Service](#container-service)    
  - [Basic Authentication Over S3](#basic-auth-over-s3)
  - [Default](#default)
  - [Cloudfront](#cloudfront)  
- [Authors](#authors)

## Cloudformation  
  
These Clouformation templates are a good starting point for setting up and running web applications on AWS.  
  
### Container Service  
  
These templates allow you to run a cluster of Docker containers under various configurations. Very simple to set up, supporting faster deployment and rollback, and extremely scalable - they are built for development all the way up to production.  
  
The production templates also allow for integration with Prometheus for monitoring via the cAdvisor exporter.  
  
[Link](https://github.com/RGADigital/devops-aws-templates/tree/master/cloudformation/container-service)  
  
### Basic Authentication Over S3  
  
Templates for setting up Basic Authentication on top of an S3 Bucket. AWS does not provide any out of the box solution for this functionality, but this template runs a micro EC Instance and proxy's requests to the S3 Bucket - along with adding Basic Authentication.  
  
Recommended for protecting your development and staging sites, and scalable to production with the addition of Cloudfront.  
  
[Link](https://github.com/RGADigital/devops-aws-templates/tree/master/cloudformation/basic-auth-over-s3)  
  
### Default
  
Templates for running single instances with HA/FT via an Auto Scaling Group with desired capacity set to 1. This ensures that the instance is brought back in case of failure or accidental termination.  
  
These are good templates to start with for testing out new applications, building development servers, and running jump boxes.  
  
[Link](https://github.com/RGADigital/devops-aws-templates/tree/master/cloudformation/_default)  
  
### Cloudfront  
  
This template builds a Cloudfront distribution. This allows you to store your cloudfront configuration in source control and easily spin up new distributions with the same config as needed for additional environments.  
  
[Link](https://github.com/RGADigital/devops-aws-templates/tree/master/cloudformation/cloudfront)  
  
# Authors  
  
- [Nauman Hafiz](https://github.com/canisvulgaris)  
- [Keith O'Brien](https://github.com/fugit)  
  