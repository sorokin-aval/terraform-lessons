#!/usr/bin/env bash
#export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
#  $(aws sts assume-role \
#  --role-arn arn:aws:iam::136812256255:role/terraform \
#  --role-session-name terraform \
#  --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
#  --output text))

STOP_VALUE=10
COUNTER=0

export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
  $(aws sts assume-role \
  --role-arn arn:aws:iam::${1}:role/BootstrapRole \
  --role-session-name BootstrapRole \
  --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
  --output text))

POLICY_ATTACHED=$(aws iam list-attached-role-policies --role-name BootstrapRole |jq '.AttachedPolicies[] | select(.PolicyName=="AdministratorAccess")'|wc -l|xargs)
if [[ "${POLICY_ATTACHED}" -eq 0 ]]; then
  echo "Attach policy"
  aws iam attach-role-policy --role-name BootstrapRole --policy-arn "arn:aws:iam::aws:policy/AdministratorAccess"
  while [[ "$(aws iam list-attached-role-policies --role-name BootstrapRole |jq '.AttachedPolicies[] | select(.PolicyName=="AdministratorAccess")'|wc -l|xargs)" -eq 0 ]]; do
      echo "Check policy"
      echo "Sleep 2 sec"
      sleep 2
      COUNTER=$((COUNTER+1))
      if [[ "${COUNTER}" -eq ${STOP_VALUE} ]]; then
        echo "Admin policy has not been attached in 20 sec. Exit with error level 1"
        exit 1
      fi
  done
fi
echo Attached
