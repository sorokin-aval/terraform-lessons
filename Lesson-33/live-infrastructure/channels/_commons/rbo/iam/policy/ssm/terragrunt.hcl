terraform {
  source = local.account_vars.sources_iam_policy
}

locals {
  name         = "${basename(get_terragrunt_dir())}"
  description  = "Policy to grant limited SSM access"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

iam_role = local.account_vars.iam_role

inputs = {
  name        = local.name
  path        = "/"
  description = local.description

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ssm:StartSession"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:TerminateSession",
        "ssm:ResumeSession",
        "ssm:DescribeSessions",
        "ssm:GetConnectionStatus"
      ],
      "Condition": {
        "StringLike" : { "ssm:resourceTag/aws:ssmmessages:session-id" : "&{aws:userid}" }
      },
      "Resource": ["*"]
    }
  ]
}
EOF

  tags = local.tags_map
}
