#!/bin/bash -e

# ECS Cloudformation Stack Deployment
# script to build the source, push the docker image, and kick off cloudformation update
#
# author: nauman.hafiz@rga.com

##############################
#   PROJECT SPECIFIC PARAMS  #
##############################

# STACKNAME PREFIX
# the name of the cloudformation stack without environment
# ex. for stack-name-dev, stack-name-stg, stack-name-prd; just enter stack-name
_STACKNAME_PREFIX="<stack-name-prefix>"

# CONTAINER NAME
# the name of the container that the app is running on
# ex. nike/gci
_CONTAINER_NAME="<container-name>"

# CONTAINER REPOSITORY URL
# this is the url for the ECR repository
# ex. 958274513332.dkr.ecr.us-west-2.amazonaws.com
_REPO_URL="<container-repo-url>"

# PATH TO THE PARAMETERS FILE
# relative path to stack params file - should include file name and extension
# if this is left blank the params will be pulled from the existing stack
_STACK_PARAMS_FILE=""

###############################

_DEPLOY=0
_PROFILE=""
_PROFILE_ARG=""
_PROFILE_SC=""
_REGION=""
_REGION_ARG=""
_REGION_SC=""
_ENV="dev"
_TAG=""
_STACKSTATUS=""
_SKIPPACKAGE=0
_STACKNAME=""

while getopts 'dhst:n:p:r:e:' flag; do
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
        echo "-e ENV,      specify the environment to deploy to; can be 'dev' 'stg' or 'prd'; defaults to dev"
        echo "-t TAG       specify the tag for the docker container; (required)"
        echo "-s           skip building a new image; (optional)"
        echo "-n           custom stackname prefix; (optional)"
        exit 0
    ;;
    t)
        _TAG="${OPTARG}"
    ;;
    s)
        _SKIPPACKAGE=1
    ;;
    d)
        _DEPLOY=1
    ;;
    p)
        _PROFILE="${OPTARG}"
        _PROFILE_ARG="--profile ${OPTARG}"
        _PROFILE_SC="-p ${OPTARG}"
    ;;
    r)
        _REGION="${OPTARG}"
        _REGION_ARG="--region ${OPTARG}"
        _REGION_SC="-r ${OPTARG}"
    ;;
    e)
        _ENV="${OPTARG}"
    ;;
    n)
        echo "overriding default stackname prefix..."
        _STACKNAME_PREFIX="${OPTARG}"
    ;;
    *)
    echo "invalid arg."
    exit 1
    ;;
  esac
done

echo TAG $_TAG
echo DEPLOY $_DEPLOY
echo PROFILE $_PROFILE
echo REGION $_REGION

if [ -z ${_TAG} ]
then
    echo "ERROR: Tag is a required param."
    echo "usage: ./build.sh -t x.xx"
    exit 1
fi

if [ $_SKIPPACKAGE == 0 ]
then
    echo "building docker image with tag: ${_TAG}"

    echo "re-authenticating docker..."
    DOCKER_LOGIN=$(aws ecr get-login $_PROFILE_ARG $_REGION_ARG)
    eval $DOCKER_LOGIN

    echo "building docker container... "
    docker build -t ${_CONTAINER_NAME}:${_TAG} .
    docker tag ${_CONTAINER_NAME}:${_TAG} ${_REPO_URL}/${_CONTAINER_NAME}:${_TAG}
    docker push ${_REPO_URL}/${_CONTAINER_NAME}:${_TAG}

    echo "docker image has been pushed."
fi

if [ "$_DEPLOY" = 1 ]
then

  if [ $_ENV == "dev" ] || [ $_ENV == "stg" ] || [ $_ENV == "prd" ]
  then
      echo environment param is ok.

      _STACKNAME=$(aws cloudformation list-stacks --stack-status-filter "CREATE_COMPLETE" "ROLLBACK_COMPLETE" "UPDATE_COMPLETE" "UPDATE_ROLLBACK_COMPLETE" \
      --query "sort_by(StackSummaries[?contains(StackName, \`${_STACKNAME_PREFIX}-${_ENV}-\`) == \`true\`].{name:StackName,time:CreationTime}, &time)[].name" --output text $_PROFILE_ARG $_REGION_ARG)
      _STACKNAME=$(echo $_STACKNAME  | sed -e 's:.*\('${_STACKNAME_PREFIX}'-'${_ENV}'-[0-9]*\):\1:g')

      if [[ ! $_STACKNAME == "${_STACKNAME_PREFIX}-${_ENV}-"* ]]
      then
          echo "ERROR: could not parse out Stack Name"
          exit 1
      fi
  else
    echo ERROR: environment param not valid - $_ENV
    exit 1
  fi

  echo "updating instance cluster..."
  echo "checking status of cloudformation stack..."
  _STACKSTATUS=$(aws cloudformation describe-stacks --stack-name ${_STACKNAME} --query "Stacks[0].StackStatus" $_PROFILE_ARG $_REGION_ARG)
  echo "cloudformation ${_STACKNAME} stack status: ${_STACKSTATUS}"

  if [ "$_STACKSTATUS" = '"CREATE_COMPLETE"' ] || [ "$_STACKSTATUS" = '"ROLLBACK_COMPLETE"' ] || [ "$_STACKSTATUS" = '"UPDATE_COMPLETE"' ] || [ "$_STACKSTATUS" = '"UPDATE_ROLLBACK_COMPLETE"' ]
  then
    BUILD_DATE=$(date +%Y%m%d%H%M%S)
    PARAMS_FILE=params_${_REGION}_${BUILD_DATE}.json

    #use stack params from file if it exists
    if [ ! -z ${_STACK_PARAMS_FILE} ]
    then
      cp ${_STACK_PARAMS_FILE} ${PARAMS_FILE}
    else
      # get latest params from stack
      echo ${PARAMS_FILE}
      aws cloudformation describe-stacks --stack-name ${_STACKNAME} --query "Stacks[].Parameters[]" $_PROFILE_ARG $_REGION_ARG > ${PARAMS_FILE}
    fi

    echo "updating ${_ENV} cloudformation stack... ${BUILDVERSION}"

    echo "Setting up parameters ..."
    # add the parameters you want replaced here. the rest will use their existing values
    ParamKeys[0]="ContainerImage"
    ParamVals[0]="${_REPO_URL}/${_CONTAINER_NAME}:${_TAG}"

    ParamKeys[1]="BuildVersion"
    ParamVals[1]="${_TAG}"

    ParamKeys[2]="BuildDate"
    ParamVals[2]="${BUILD_DATE}"

    # ParamKeys[3]="InstanceType"
    # ParamVals[3]="t2.small"

    #add any environment specific commands and params you want updated here
    if [ "$_ENV" = "dev" ]
    then
      echo "..."
    elif [ "$_ENV" = "stg" ]
    then
      echo "..."
    elif [ "$_ENV" = "prd" ]
    then
      # ASG_NAME=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?contains(AutoScalingGroupName, \`${_STACKNAME_PREFIX}-${_ENV}\`) == \`true\`].AutoScalingGroupName" $_PROFILE_ARG $_REGION_ARG --output text)
      # echo "suspend scheduled autoscaling... $ASG_NAME"
      # aws autoscaling suspend-processes --scaling-processes "ScheduledActions" --auto-scaling-group-name $ASG_NAME $_PROFILE_ARG $_REGION_ARG
      echo "..."
      # ParamKeys[3]="InstanceType"
      # ParamVals[3]="t2.medium"

      # ParamKeys[4]="ClusterDesiredSize"
      # ParamVals[4]="2"

      # ParamKeys[5]="ClusterMinSize"
      # ParamVals[5]="2"

      # ParamKeys[6]="ClusterMaxSize"
      # ParamVals[6]="5"

      # ParamKeys[7]="ContainerDesiredCount"
      # ParamVals[7]="4"

      # ParamKeys[8]="ContainerMinCount"
      # ParamVals[8]="4"

      # ParamKeys[9]="ContainerMaxCount"
      # ParamVals[9]="10"

    else
      echo Something went wrong. Environment not found.
      exit 1
    fi

    echo "Parsing existing parameters and updating params file ..."
    iter=0
    for i in "${ParamKeys[@]}"
    do
       echo setting $i to ${ParamVals[iter]}
       OUTPUT=$(cat ${PARAMS_FILE} | jq 'map(if .ParameterKey == "'$i'" then .ParameterValue = "'${ParamVals[iter]}'" else . end)')
       echo $OUTPUT > ${PARAMS_FILE}
       iter=$((iter+1))
       sleep 1
    done

    echo "Running stack update ..."
    STACKID=$(aws cloudformation update-stack --capabilities CAPABILITY_NAMED_IAM \
    --stack-name $_STACKNAME --use-previous-template $_PROFILE_ARG $_REGION_ARG \
    --parameters file://$(pwd | tr -d '\n')/${PARAMS_FILE})

  else
    echo "ERROR: cloudformation stack is currently being updated..."
    exit 1
  fi

  # clean up the params file
  rm ${PARAMS_FILE}

  #wait for stack to update
  STACKID=$(echo ${STACKID} | sed -n 's/{ "StackId": "\(.*\)" }/\1/p')
  echo STACKID: ${STACKID}

  #looking for aws-stack-check.sh script
  cd ops/scripts/
  echo "waiting for instance cluser to complete..."
  ./aws-stack-check.sh -s ${STACKID} ${_REGION_SC} ${_PROFILE_SC}
  cd ../../

  # if [ ! -z $ASG_NAME ]
  #   then
  #     echo "resume scheduled autoscaling... $ASG_NAME"
  #     aws autoscaling resume-processes --scaling-processes "ScheduledActions" --auto-scaling-group-name $ASG_NAME $_PROFILE_ARG $_REGION_ARG
  # fi
fi

echo done
exit 0