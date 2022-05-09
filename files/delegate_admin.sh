#!/bin/bash

catch_exception="AccountAlreadyRegisteredException"

if [ -n ${master_account_role_arn} ]; then
  aws sts assume-role --role-arn ${master_account_role_arn} --role-session-name "AWSCLI-Session-Delegate-Admin-Account" 1> /dev/null
fi

cmd="aws organizations register-delegated-administrator --service-principal=${principal} --account-id=${account_id}"
ERROR=$($cmd 2>&1 > /dev/null)

if [ -z "$ERROR" ]; then
    echo "Successfully delegated administrator"
elif [[ "$ERROR" == *"$catch_exception"* ]]; then
  echo "Account ID: ${account_id} is already delegated Admin for service principal: ${principal}"
else
    echo "Unable to handle error:"
    echo "$ERROR"
    exit 1
fi
