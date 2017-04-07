# countApplicationVersions.py
# ebsSnapshot.py
These scripts require AWS Python CLI: https://aws.amazon.com/sdk-for-python/
Also, AWS CLI tools must be installed and configured: http://aws.amazon.com/cli/
  - If you have multiple AWS accounts, use profiles to switch between them. You can set up a profile with `aws configure --profile PROFILE_NAME`. If running this from a script, you'll want to set the environment variable: `export AWS_DEFAULT_PROFILE=myProfileName`
  - Elastic Beanstalk scripts also require you to have an elastic beanstalk app initiated locally. This doesn't have to be attached to the codebase, but doesn't hurt. Initiate with `aws eb init`.

#setupJettyService.sh
This script downloads and installs jetty as a service