include {
  path = "${find_in_parent_folders()}"
}
include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

locals {
  # Automatically load common variables from parent hcl
  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars = read_terragrunt_config(find_in_parent_folders("source.hcl"))

  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  project_vars   = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map       = local.project_vars.locals.project_tags
  aws_account_id = local.account.locals.aws_account_id
}


inputs = {
  name        = "${basename(get_terragrunt_dir())}"
  path        = "/"
  description = "${basename(get_terragrunt_dir())} policy. Created with Terragrunt"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ],
      "Resource": ["arn:aws:kms:eu-central-1:100515202040:key/b8974795-2020-4a77-8935-11cdfac72a68"],
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": ["arn:aws:kms:eu-central-1:100515202040:key/b8974795-2020-4a77-8935-11cdfac72a68"]
    }
  ]
}
EOF

  tags = local.tags_map

}
