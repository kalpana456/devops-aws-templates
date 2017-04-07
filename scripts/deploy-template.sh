#!/bin/bash -xe
# script to package up source code, deploy it to the s3 bucket, and kick off cloudformation update
#
# author: nauman.hafiz@rga.com

_NAME=""
_DEPLOY=0
_PROFILE=""
_PROFILE_SC=""
_REGION=""
_REGION_SC=""
_ENV="dev"
_STACKSTATUS=""
_SKIPPACKAGE=0
_STACKNAME=""
_STACKNAME_PREFIX="project-name"
_DEPLOY_S3BUCKET="project-name"

while getopts 'dhsn:p:r:e:' flag; do
  case "${flag}" in
    h)
      echo "package source and deploy to s3"
      echo " "
      echo "$deploy.sh [options]"
      echo " "
      echo "options:"
      echo "-h,          show brief help"
      echo "-d,          toggle update stack; defaults to OFF"
      echo "-p PROFILE,  specify AWS local profile to use; will use default if blank"
      echo "-r REGION,   speciy AWS region to use; will use default if blank"
      echo "-n NAME,     specify the name of the package"
      echo "-e ENV,      specify the environment to deploy to; can be 'dev' 'stg' or 'prd'"
      echo "-s,          skip packaging up source and use -n NAME package; -n required"
      exit 0
  ;;
    n)
      _NAME="${OPTARG}.tgz"
  ;;
    d)
      _DEPLOY=1
  ;;
  p)
      _PROFILE="--profile ${OPTARG}"
      _PROFILE_SC="-p ${OPTARG}"
  ;;
  r)
      _REGION="--region ${OPTARG}"
      _REGION_SC="-r ${OPTARG}"
  ;;
    e)
      _ENV="${OPTARG}"
  ;;
    s)
      _SKIPPACKAGE=1
  ;;
    *)
    echo "invalid arg."
    exit 1
    ;;
  esac
done

echo NAME $_NAME
echo DEPLOY $_DEPLOY
echo PROFILE $_PROFILE
echo REGION $_REGION

if [ $_SKIPPACKAGE == 1 ]
then
  if [ -z $_NAME ]
    then
      echo "A package name -n must be provided for -s to work"
      exit 1
  fi
fi


if [ -z $_NAME ]
then
  _NAME=$(date +%Y%m%d%H%M%S).tgz
fi

if [ $_ENV == "dev" ] || [ $_ENV == "stg" ] || [ $_ENV == "prd" ]
then
  echo environment param is ok.
  _STACKNAME=$_STACKNAME_PREFIX"-"$_ENV
else
  echo environment param not valid - $_ENV
  exit 1
fi

if [ $_SKIPPACKAGE == 0 ]
then
  #make package dir
  mkdir -p pkg

  #cleanup
  rm -rf pkg/*.tgz

  #package up
  echo "packaging up source..."
  if [ -f "/usr/bin/gnutar" ]
  then
      /usr/bin/gnutar -cvf package.tgz * --exclude='node_modules*' --exclude='.git' --exclude='ops*' --exclude='pkg*'
  else
      tar -cvf package.tgz * --exclude='node_modules*' --exclude='.git' --exclude='ops*' --exclude='pkg*'
  fi

  mv package.tgz pkg/$_NAME
  cd pkg/
  echo "uploading package to s3... $_NAME"
  aws s3 cp ${_NAME} s3://${_DEPLOY_S3BUCKET}/${_ENV}/package/ $_PROFILE $_REGION
  cd ..
  echo "package has been uploaded."
fi

if [ "$_DEPLOY" = 1 ]
then

  #confirm that package exists
  CONFIRM_PKG=$(aws s3 ls s3://${_DEPLOY_S3BUCKET}/${_ENV}/package/${_NAME} $_PROFILE $_REGION | sed 's|.* ||')

  if [ -z $CONFIRM_PKG ]
  then
    echo "ERROR: package not found in S3 BUCKET..."
    exit 1
  fi

  echo "updating instance cluster..."
  echo "checking status of cloudformation stack..."
  _STACKSTATUS=$(aws cloudformation describe-stacks --stack-name ${_STACKNAME} --query "Stacks[0].StackStatus" $_PROFILE $_REGION)
  echo "cloudformation ${_STACKNAME} stack status: ${_STACKSTATUS}"

  if [ "$_STACKSTATUS" = '"CREATE_COMPLETE"' ] || [ "$_STACKSTATUS" = '"ROLLBACK_COMPLETE"' ] || [ "$_STACKSTATUS" = '"UPDATE_COMPLETE"' ] || [ "$_STACKSTATUS" = '"UPDATE_ROLLBACK_COMPLETE"' ]
  then
    BUILDVERSION="pkg-${_NAME}-hash-$(git rev-parse HEAD)"

    if [ "$_ENV" = "dev" ]
    then
      echo "updating dev cloudformation stack... ${BUILDVERSION}"
      STACKID=$(aws cloudformation update-stack --capabilities CAPABILITY_IAM --stack-name $_STACKNAME --use-previous-template $_PROFILE $_REGION --parameters \
      ParameterKey=DeployPackage,ParameterValue=${_NAME} \
      ParameterKey=BuildVersion,ParameterValue=${BUILDVERSION} \
      ParameterKey=BuildBucket,ParameterValue=${_DEPLOY_S3BUCKET}/${_ENV}/package \
      ParameterKey=ConfigBucket,ParameterValue=${_DEPLOY_S3BUCKET}/${_ENV}/config \
      ParameterKey=DesiredInstanceCount,ParameterValue=1 \
      ParameterKey=InstanceType,ParameterValue=t2.small \
      ParameterKey=MaxInstanceCount,ParameterValue=3 \
      ParameterKey=MinInstanceCount,ParameterValue=1 \
      ParameterKey=NodeVersion,ParameterValue=6.7.0 \
      ParameterKey=AZPrivate1,UsePreviousValue=true \
      ParameterKey=AZPrivate2,UsePreviousValue=true \
      ParameterKey=AZPublic1,UsePreviousValue=true \
      ParameterKey=AZPublic2,UsePreviousValue=true \
      ParameterKey=EnvVars,UsePreviousValue=true \
      ParameterKey=HealthCheckPath,UsePreviousValue=true \
      ParameterKey=HealthCheckPort,UsePreviousValue=true \
      ParameterKey=KeyName,UsePreviousValue=true \
      ParameterKey=NewRelicKey,UsePreviousValue=true \
      ParameterKey=NodeScriptArgs,UsePreviousValue=true \
      ParameterKey=NodeScriptName,UsePreviousValue=true \
      ParameterKey=OperatorEmail,UsePreviousValue=true \
      ParameterKey=SSHLocation,UsePreviousValue=true \
      ParameterKey=SSLCertificateId,UsePreviousValue=true \
      ParameterKey=SubnetPrivate1,UsePreviousValue=true \
      ParameterKey=SubnetPrivate2,UsePreviousValue=true \
      ParameterKey=SubnetPublic1,UsePreviousValue=true \
      ParameterKey=SubnetPublic2,UsePreviousValue=true \
      ParameterKey=UserDataScript,UsePreviousValue=true \
      ParameterKey=VPCID,UsePreviousValue=true \
      ParameterKey=TagClient,UsePreviousValue=true \
      ParameterKey=TagOwner,UsePreviousValue=true \
      ParameterKey=TagEnvironment,ParameterValue=${_ENV} \
      ParameterKey=TagName,ParameterValue=${_STACKNAME_PREFIX}-${_ENV} \
      ParameterKey=TagProject,ParameterValue=${_STACKNAME_PREFIX})
    elif [ "$_ENV" = "stg" ]
    then
      # ASG_NAME=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?contains(AutoScalingGroupName, \`${_STACKNAME_PREFIX}-${_ENV}\`) == \`true\`].AutoScalingGroupName" $_PROFILE $_REGION --output text)
      # echo "suspend scheduled autoscaling... $ASG_NAME"
      # aws autoscaling suspend-processes --scaling-processes "ScheduledActions" --auto-scaling-group-name $ASG_NAME $_PROFILE $_REGION

      echo "updating stg cloudformation stack... ${BUILDVERSION}"
      STACKID=$(aws cloudformation update-stack --capabilities CAPABILITY_IAM --stack-name $_STACKNAME --use-previous-template $_PROFILE $_REGION --parameters \
      ParameterKey=DeployPackage,ParameterValue=${_NAME} \
      ParameterKey=BuildVersion,ParameterValue=${BUILDVERSION} \
      ParameterKey=BuildBucket,ParameterValue=${_DEPLOY_S3BUCKET}/${_ENV}/package \
      ParameterKey=ConfigBucket,ParameterValue=${_DEPLOY_S3BUCKET}/${_ENV}/config \
      ParameterKey=DesiredInstanceCount,ParameterValue=2 \
      ParameterKey=InstanceType,ParameterValue=t2.small \
      ParameterKey=MaxInstanceCount,ParameterValue=4 \
      ParameterKey=MinInstanceCount,ParameterValue=2 \
      ParameterKey=ScheduledMaxInstanceCount,UsePreviousValue=true \
      ParameterKey=ScheduledMinInstanceCount,UsePreviousValue=true \
      ParameterKey=ScheduledUpRecurrence,UsePreviousValue=true \
      ParameterKey=ScheduledDownRecurrence,UsePreviousValue=true \
      ParameterKey=NodeVersion,ParameterValue=6.7.0 \
      ParameterKey=AZPrivate1,UsePreviousValue=true \
      ParameterKey=AZPrivate2,UsePreviousValue=true \
      ParameterKey=AZPublic1,UsePreviousValue=true \
      ParameterKey=AZPublic2,UsePreviousValue=true \
      ParameterKey=EnvVars,UsePreviousValue=true \
      ParameterKey=HealthCheckPath,UsePreviousValue=true \
      ParameterKey=HealthCheckPort,UsePreviousValue=true \
      ParameterKey=KeyName,UsePreviousValue=true \
      ParameterKey=NewRelicKey,UsePreviousValue=true \
      ParameterKey=NodeScriptArgs,UsePreviousValue=true \
      ParameterKey=NodeScriptName,UsePreviousValue=true \
      ParameterKey=OperatorEmail,UsePreviousValue=true \
      ParameterKey=SSHLocation,UsePreviousValue=true \
      ParameterKey=BastionSecurityGroup,UsePreviousValue=true \
      ParameterKey=SSLCertificateId,UsePreviousValue=true \
      ParameterKey=SubnetPrivate1,UsePreviousValue=true \
      ParameterKey=SubnetPrivate2,UsePreviousValue=true \
      ParameterKey=SubnetPublic1,UsePreviousValue=true \
      ParameterKey=SubnetPublic2,UsePreviousValue=true \
      ParameterKey=UserDataScript,UsePreviousValue=true \
      ParameterKey=VPCID,UsePreviousValue=true \
      ParameterKey=TagClient,UsePreviousValue=true \
      ParameterKey=TagOwner,UsePreviousValue=true \
      ParameterKey=TagEnvironment,ParameterValue=${_ENV} \
      ParameterKey=TagName,ParameterValue=${_STACKNAME_PREFIX}-${_ENV} \
      ParameterKey=TagProject,ParameterValue=${_STACKNAME_PREFIX})
    elif [ "$_ENV" = "prd" ]
    then
      # ASG_NAME=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?contains(AutoScalingGroupName, \`${_STACKNAME_PREFIX}-${_ENV}\`) == \`true\`].AutoScalingGroupName" $_PROFILE $_REGION --output text)
      # echo "suspend scheduled autoscaling... $ASG_NAME"
      # aws autoscaling suspend-processes --scaling-processes "ScheduledActions" --auto-scaling-group-name $ASG_NAME $_PROFILE $_REGION

      echo "updating prd cloudformation stack... ${BUILDVERSION}"
      STACKID=$(aws cloudformation update-stack --capabilities CAPABILITY_IAM --stack-name $_STACKNAME --use-previous-template $_PROFILE $_REGION --parameters \
      ParameterKey=DeployPackage,ParameterValue=${_NAME} \
      ParameterKey=BuildVersion,ParameterValue=${BUILDVERSION} \
      ParameterKey=BuildBucket,ParameterValue=${_DEPLOY_S3BUCKET}/${_ENV}/package \
      ParameterKey=ConfigBucket,ParameterValue=${_DEPLOY_S3BUCKET}/${_ENV}/config \
      ParameterKey=DesiredInstanceCount,ParameterValue=5 \
      ParameterKey=InstanceType,ParameterValue=t2.large \
      ParameterKey=MaxInstanceCount,ParameterValue=30 \
      ParameterKey=MinInstanceCount,ParameterValue=5 \
      ParameterKey=ScheduledMaxInstanceCount,UsePreviousValue=true \
      ParameterKey=ScheduledMinInstanceCount,UsePreviousValue=true \
      ParameterKey=ScheduledUpRecurrence,UsePreviousValue=true \
      ParameterKey=ScheduledDownRecurrence,UsePreviousValue=true \
      ParameterKey=NodeVersion,ParameterValue=6.7.0 \
      ParameterKey=AZPrivate1,UsePreviousValue=true \
      ParameterKey=AZPrivate2,UsePreviousValue=true \
      ParameterKey=AZPublic1,UsePreviousValue=true \
      ParameterKey=AZPublic2,UsePreviousValue=true \
      ParameterKey=EnvVars,UsePreviousValue=true \
      ParameterKey=HealthCheckPath,UsePreviousValue=true \
      ParameterKey=HealthCheckPort,UsePreviousValue=true \
      ParameterKey=KeyName,UsePreviousValue=true \
      ParameterKey=NewRelicKey,UsePreviousValue=true \
      ParameterKey=NodeScriptArgs,UsePreviousValue=true \
      ParameterKey=NodeScriptName,UsePreviousValue=true \
      ParameterKey=OperatorEmail,UsePreviousValue=true \
      ParameterKey=SSHLocation,UsePreviousValue=true \
      ParameterKey=BastionSecurityGroup,UsePreviousValue=true \
      ParameterKey=SSLCertificateId,UsePreviousValue=true \
      ParameterKey=SubnetPrivate1,UsePreviousValue=true \
      ParameterKey=SubnetPrivate2,UsePreviousValue=true \
      ParameterKey=SubnetPublic1,UsePreviousValue=true \
      ParameterKey=SubnetPublic2,UsePreviousValue=true \
      ParameterKey=UserDataScript,UsePreviousValue=true \
      ParameterKey=VPCID,UsePreviousValue=true \
      ParameterKey=TagClient,UsePreviousValue=true \
      ParameterKey=TagOwner,UsePreviousValue=true \
      ParameterKey=TagEnvironment,ParameterValue=${_ENV} \
      ParameterKey=TagName,ParameterValue=${_STACKNAME_PREFIX}-${_ENV} \
      ParameterKey=TagProject,ParameterValue=${_STACKNAME_PREFIX})
    else
      echo Something went wrong. Environment not found.
      exit 1
    fi
  else
    echo "ERROR: cloudformation stack is currently being updated..."
    exit 1
  fi

  #wait for stack to update
  STACKID=$(echo ${STACKID} | sed -n 's/{ "StackId": "\(.*\)" }/\1/p')
  echo STACKID: ${STACKID}

  #looking for aws-stack-check.sh script
  cd ../scripts/
  echo "waiting for instance cluser to complete..."
  ./aws-stack-check.sh -s ${STACKID} ${_REGION_SC} ${_PROFILE_SC}
  cd ../server/

  # if [ ! -z $ASG_NAME ]
  #   then
  #     echo "resume scheduled autoscaling... $ASG_NAME"
  #     aws autoscaling resume-processes --scaling-processes "ScheduledActions" --auto-scaling-group-name $ASG_NAME $_PROFILE $_REGION
  # fi
fi

echo done
exit 0
