iam_role = local.account_vars.iam_role

include {
  path = "${find_in_parent_folders()}"
}

terraform {
   source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

locals {
  # Automatically load common variables from parent hcl
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars = read_terragrunt_config(find_in_parent_folders("source.hcl"))

  # Extract out exact variables for reuse
  source_map = local.source_vars.locals
  tags_map = local.common_tags.locals
  aws_account_id = local.account_vars.locals.aws_account_id
  specific_tags = { 
    Name = "${basename(get_terragrunt_dir())}",
    application_role = "SNSTopic"
    }
}

inputs = {

  application_failure_feedback_role_arn = ""
  application_success_feedback_role_arn = ""
  application_success_feedback_sample_rate = 0
  content_based_deduplication = false
  delivery_policy = ""
  display_name = "SES email monitoring topic"
  fifo_topic = false
  firehose_failure_feedback_role_arn = ""
  firehose_success_feedback_role_arn = ""
  firehose_success_feedback_sample_rate = 0
  http_failure_feedback_role_arn = ""
  http_success_feedback_role_arn = ""
  http_success_feedback_sample_rate = 0
  kms_master_key_id = ""
  lambda_failure_feedback_role_arn = ""
  lambda_success_feedback_role_arn = ""
  lambda_success_feedback_sample_rate = 0

  name = "${basename(get_terragrunt_dir())}"

  policy = <<EOF
    {
      "Version": "2008-10-17",
      "Id": "__default_policy_ID",
      "Statement": [
        {
          "Sid": "__default_statement_ID",
          "Effect": "Allow",
          "Principal": {
            "AWS": "*"
          },
          "Action": [
            "SNS:GetTopicAttributes",
            "SNS:SetTopicAttributes",
            "SNS:AddPermission",
            "SNS:RemovePermission",
            "SNS:DeleteTopic",
            "SNS:Subscribe",
            "SNS:ListSubscriptionsByTopic",
            "SNS:Publish"
          ],
          "Resource": "arn:aws:sns:eu-central-1:${local.aws_account_id}:${basename(get_terragrunt_dir())}",
          "Condition": {
            "StringEquals": {
              "AWS:SourceOwner": "${local.aws_account_id}"
            }
          }
        }
      ]
    }
EOF

  sqs_failure_feedback_role_arn = ""
  sqs_success_feedback_role_arn = ""
  sqs_success_feedback_sample_rate = 0
  
  tags = merge(local.tags_map, local.specific_tags)

}
