#!/bin/bash -e
# name: cloudfront-cache-invalidate.sh
# desc: script to invalidate the cache from a cloudfront distribution
# author: nauman.hafiz@rga.com
# 

COMMAND_LINE_OPTIONS_HELP='
Command line options:
    -d          Distribution Id (required if Stackname not passed) 
    -s          Stackname you want to match (if there are multiple matches, the latest will be chosen - required if Distribution Id not passed)
    -i          Invalidation Path
    -o          Poll Invalidation Status until complete [ optional ]
    -t          Timeout for Polling; defaults to 1200   [ optional ]
    -c          Do not clean up temp invalidation file  [ optional ]
    -v          Verbose mode                            [ optional ]
    -p          AWS Profile                             [ optional ]
    -r          AWS Region                              [ optional ]
    -h          Print this help menu

Examples:
    Clear cache for S3 API Cloudfront Distribution
    ./cf-stack-invalidate.sh -s cw-cf-s3-api-stg -i "/*"

    Clear cache for WWW or API Cloudfront Distribution after Blue/Green deploy and Poll for Invalidate Status
    ./cf-stack-invalidate.sh -s cw-cf-{api|www}-{stg|prod} -i "/*" -p
'

VERBOSE_OUTPUT="";
_PROFILE=""
_REGION=""

while getopts "d:s:i:t:p:r:ocvh" opt; do
  case $opt in
    h)
      echo "$COMMAND_LINE_OPTIONS_HELP"
      exit 0
      ;;
    d)
      DISTRIBUTION_ID=$OPTARG
      VERBOSE_OUTPUT+="\nDISTRIBUTION_ID: ${DISTRIBUTION_ID}"
      ;;
    s)
      STACKMATCH=$OPTARG
      VERBOSE_OUTPUT+="\nSTACKMATCH: ${STACKMATCH}"
      ;;
    i)
      INVALIDATION=$OPTARG
      VERBOSE_OUTPUT+="\nINVALIDATION: ${INVALIDATION} "
      ;;
    t)
      TIMEOUT=$OPTARG
      VERBOSE_OUTPUT+="\nTIMEOUT: ${TIMEOUT}"
      ;;
    o)
      POLLING="true"
      VERBOSE_OUTPUT+="\nPOLLING: ${POLLING}"
      ;;    
    c)
      NOCLEANUP="true"
      VERBOSE_OUTPUT+="\nNOCLEANUP: ${NOCLEANUP}"
      ;;
    v)
      VERBOSE="true"
      ;;
    p)
      _PROFILE=" --profile $OPTARG"
      VERBOSE_OUTPUT+="\n_PROFILE: ${_PROFILE} "
      ;;
    r)
      _REGION=" --region $OPTARG"
      VERBOSE_OUTPUT+="\n_REGION: ${_REGION} "
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

#HELPER FUNCTIONS
func_check_exitcode() {
    if [ $1 == 0 ]; then
        echo OK
    else
        echo "ERROR: cmd ${2} returned an error"
        exit 1
    fi
}

func_return_distributionid() {
  local l_stack=$1
  local query
  query="Stacks[].Outputs[?OutputKey == \`CloudfrontDistributionId\`].OutputValue"
  aws cloudformation describe-stacks                  \
    --stack-name "${l_stack}"                         \
    --query "${query}"                                \
    --output ${output:-"text"}                        \
    $_PROFILE $_REGION
}

func_return_invalidationstatus() {  
  local l_distid=$1
  local l_invalid=$2
  local query
  query="Invalidation.Status"

  aws cloudfront get-invalidation                     \
    --distribution-id "$l_distid"                     \
    --id "$l_invalid"                                 \
    --query "${query}"                                \
    --output ${output:-"text"}                        \
    $_PROFILE $_REGION
}

func_poll_invalidationstatus () {
  local count
  local exitcode
  local status

  local inprogress_status="InProgress"
  local complete_status="Completed"

  until  [ "$exitcode" == "0" -a "$status" == "$complete_status" ]
  do
    # Sleep for one second so timout equals seconds
    sleep 1
    status=$(func_return_invalidationstatus ${CF_DISTRIBUTION_ID} ${INVALIDATION_ID})
    exitcode=$?
    let "count=count+1"
    echo "Invalidation Status: ${status} - count: ${count} - timeout: ${TIMEOUT}"
    if [  "$count" -ge  "$TIMEOUT" ] ; then
      echo "Invalidation failed to reach: $complete_status"
      echo "count=$count timeout=$TIMEOUT"
      exit 1
    fi
    if [ "$VERBOSE" == "true" ]; then
      echo -e "CF_DISTRIBUTION_ID: ${CF_DISTRIBUTION_ID} - INVALIDATION_ID: ${INVALIDATION_ID}\n"
    fi
    if [ ! "$exitcode" == 0 ] ; then
      if [  "$count" -ge  "$TIMEOUT" ] ; then
        echo "Invalidation failed to reach: $complete_status"
        echo "Exited on: $exitcode"
        exit 1
      fi      
    fi    
  done  
}

#GLOBAL
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VERBOSE_OUTPUT+="\nDIR: ${DIR}"
DATE=$(date +%Y%m%d%H%M%S)
VERBOSE_OUTPUT+="\nDATE: ${DATE}"

#ensure that cloudfront is enabled in aws cli
aws configure set preview.cloudfront true

#error checking
if [ -z $STACKMATCH ] && [ -z $DISTRIBUTION_ID ]; then
    echo "ERROR Stack match OR Distribution Id is required" >&2
    echo "$COMMAND_LINE_OPTIONS_HELP"
    exit 1
fi

if [ ! -z $STACKMATCH ] && [ ! -x $DISTRIBUTION_ID ]; then 
  echo "ERROR Stack match OR Distribution Id is required. Cannot Pass Both." >&2
  echo "$COMMAND_LINE_OPTIONS_HELP"
  exit 1
fi

if [ -z "$INVALIDATION" ]; then
    echo "ERROR Invalidation is required" >&2
    echo "$COMMAND_LINE_OPTIONS_HELP"
    exit 1
fi

#set default timeout
if [ -z "$TIMEOUT" ]; then
  TIMEOUT=1200
fi

if [ -z $DISTRIBUTION_ID ]; then
  #attempt to determine full Stack Name
  STACKNAME=$(${DIR}/aws-get-stack.sh -s ${STACKMATCH} -l 1 -e)
  VERBOSE_OUTPUT+="\nSTACKNAME: ${STACKNAME}"
  func_check_exitcode $? "aws-get-stack.sh"

  #figure out Cloudfront Distribution Id
  CF_DISTRIBUTION_ID=$(func_return_distributionid $STACKNAME)
  VERBOSE_OUTPUT+="\nCF_DISTRIBUTION_ID: ${CF_DISTRIBUTION_ID}"
else
  CF_DISTRIBUTION_ID=$DISTRIBUTION_ID
  VERBOSE_OUTPUT+="\nCF_DISTRIBUTION_ID: ${CF_DISTRIBUTION_ID}"
fi

CF_DISTRIBUTION_STATUS=$(aws cloudfront get-distribution --id ${CF_DISTRIBUTION_ID} --query "Distribution.Status" $_PROFILE $_REGION)

#error checking
if [ "$(echo $?)" -gt "0" ]; then
    echo "No Cloudfront Distributions found. Exiting..."
    exit 1
fi

if [ -z $CF_DISTRIBUTION_ID ]; then
    echo "No Cloudfront Distributions found in Stack. Exiting..."
    exit 1
fi

#create invalidation file
echo '{"Paths": {"Quantity": 1,"Items": ["'${INVALIDATION}'"]},"CallerReference": "script-invalidation-'${DATE}'"}' > ${DIR}/invalidate_${DATE}.json

INVALIDATE_CONTENTS=$(cat ${DIR}/invalidate_${DATE}.json)

#verbose output
if [ "$VERBOSE" == "true" ]; then
    echo -e "${VERBOSE_OUTPUT}\n"
    echo -e "invalidate_${DATE}.json contents:\n"
    echo -e "${INVALIDATE_CONTENTS}\n"

    echo "waiting for 5 seconds..."
    sleep 5
fi

#create invalidation and collect response
IN_RESPONSE=$(aws cloudfront create-invalidation --distribution-id ${CF_DISTRIBUTION_ID} --invalidation-batch file://${DIR}/invalidate_${DATE}.json $_PROFILE $_REGION)
echo -e "${IN_RESPONSE}"

#do not remove the invalidation file -c arg is passed in
if [ -z "$NOCLEANUP" ]; then
    echo "cleaning up..."
    rm ${DIR}/invalidate_${DATE}.json    
  else
    echo "skipping cleanup..."
fi

#determine invalidation id from response
INVALIDATION_ID=$(echo -e "${IN_RESPONSE}" | grep Id | cut -d \" -f4)

if [ "$POLLING" == "true" ]; then
  #verbose output
  if [ "$VERBOSE" == "true" ]; then
      echo -e "INVALIDATION_ID: ${INVALIDATION_ID}\n"
  fi
  func_poll_invalidationstatus
  echo "Invalidation Completed."
fi

echo "SUCCESS"
exit 0 