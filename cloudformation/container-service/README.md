# EC2 Container Service Cluster Running Docker Container Images
  
## Description
These templates allow you to run a cluster of Ec2 Instances, each running Docker containers with exposed services that hook into an Application Load Balanacer.  
  
The two types of templates here are:  
  
### Default  
Running instances with the default EC2 Container Service configuration  
  
### EFS Mount  
Running instances that hook into an Elastic File System mount so all the docker containers have a shared filesystem  