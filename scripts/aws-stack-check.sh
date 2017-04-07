#!/bin/bash

# Script to poll stack until status reached.
# Need to set a timeout
# most of the code was pulled from bash-my-aws
# https://github.com/realestate-com-au/bash-my-aws

COMMAND_LINE_OPTIONS_HELP='
Command line options:
    -s          StackName
    -t          Set Time Interger
    -p          Set AWS profile (optional)
    -r          Set AWS region (optional)
    -h          Print this help menu


Examples:
    Stack to check the status on.
        '`basename $0`' -s some-aws-stack

    The timeout value in seconds. 300 is the default.
        '`basename $0`' -t 300

'

while getopts ":t:s:r:p:h" opt; do
  case $opt in
    h)
      echo "$COMMAND_LINE_OPTIONS_HELP"
      exit 0
      ;;
    s)
      STACKNAME=$OPTARG
      ;;
    t)
      TIMEOUT=$OPTARG
      ;;
    r)
      REGION="--region $OPTARG"
      ;;
    p)
      PROFILE="--profile $OPTARG"
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

if [ -z $STACKNAME ]; then
  STACKNAME=$1
fi

if [ -z $STACKNAME ]; then
  echo "ERROR stackname is required" >&2
  echo "$COMMAND_LINE_OPTIONS_HELP"
  exit 1
fi

stack-status() {
  #get status of stack.
  local query='Stacks[].StackStatus[]'

  aws cloudformation describe-stacks  \
    --stack-name $STACKNAME           \
    --query $query                    \
    --output text $PROFILE $REGION
}

stack-events() {
  # type: detail
  # return the events a stack has experienced
  local stack=$STACKNAME

  local query='
    sort_by(StackEvents, &Timestamp)[].[
      Timestamp,
      LogicalResourceId,
      ResourceType,
      ResourceStatus
    ]
  '
  if output=$(aws cloudformation describe-stack-events \
    --stack-name ${stack}                              \
    --query "${query}"                                 \
    --output "table" --max-items 1 ${PROFILE} ${REGION}); then
    echo "$output" | uniq -u
  else
    return $?
  fi
}

stack-tail() {
  # type: detail
  # follow the events occuring for a stack
  local stack=$STACKNAME
#  [[ -z ${stack} ]] && __bma_usage "stack" && return 1

  local current
  local final_line
  local output
  local previous
  until echo "$output" | tail -1 | egrep -q ".*_(COMPLETE|FAILED)"
  do
    if ! output=$(stack-status); then
      # Something went wrong with stack-events (like stack not known)
      return 1
    fi
    if [ -z "$output" ]; then sleep 1; continue; fi

    current=$(echo "$output")
    final_line=$(echo "$output" | tail -1)
    if [ -z "$previous" ]; then
      echo "$current"
    elif [ "$current" != "$previous" ]; then
      comm -13 <(echo "$previous") <(echo "$current")
    fi
    previous="$current"
    sleep 5
  done
  echo $final_line
}

#MAIN
stack-tail

finalstatus=$(stack-status)

# FAILED IS BAD
$(echo $finalstatus | grep -q "FAILED")
if [ "$?" -eq "0" ]; then
    echo "Status: FAILED"
    echo $finalstatus
    exit 1
fi

# IF ROLLBACK IS BAD
$(echo $finalstatus | grep -q "ROLLBACK")
if [ "$?" -eq "0" ]; then
    echo "Status: ROLLBACK"
    echo $finalstatus
    exit 1
fi

echo $finalstatus | grep -q "COMPLETE"
if [ "$?" -eq "0" ]; then
    echo "Status: SUCCESS"
    echo $finalstatus
    exit 0
fi

#CATCHALL
echo "Status: UNKNOWN"
echo $finalstatus
exit 1
