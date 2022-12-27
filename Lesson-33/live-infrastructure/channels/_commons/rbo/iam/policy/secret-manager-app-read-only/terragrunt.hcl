terraform {
  source = local.account_vars.sources_iam_policy
}

locals {
  name             = "SecretManagerAppReadOnly"
  app_secrets_path = "app/*"
  tags_map         = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  region           = read_terragrunt_config(find_in_parent_folders("region.hcl")).locals.aws_region
  tags             = local.tags_map
}

iam_role = local.account_vars.iam_role

inputs = {
  name        = local.name
  path        = "/"
  description = "Policy allows read-only access to application secrets"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Resource": "arn:aws:secretsmanager:${local.region}:${local.account_vars.aws_account_id}:secret:${local.app_secrets_path}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:ListSecrets"
      ],
      "Resource": "*"
    }
  ]
}
EOF

  tags = local.tags_map

}
