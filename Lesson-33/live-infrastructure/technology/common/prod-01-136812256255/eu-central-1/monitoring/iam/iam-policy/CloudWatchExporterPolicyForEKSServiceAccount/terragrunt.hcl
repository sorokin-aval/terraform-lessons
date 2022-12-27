include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "${local.source_map.source_base_url}//modules/iam-policy?ref=${local.source_map.ref}"
}

iam_role = local.account_vars.iam_role

locals {
  # Automatically load common variables from parent hcl
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))

  # Extract out exact variables for reuse
  source_map = local.source_vars.locals
  tags_map   = local.common_tags.locals
  module_tags = {
    Name             = "${basename(get_terragrunt_dir())}"
    application_role = "IAM Policy"
  }
}

inputs = {
  name        = "${basename(get_terragrunt_dir())}"
  path        = "/"
  description = "${basename(get_terragrunt_dir())} policy. This policy allows to assume roles from other accounts to getting cloudwatch metrics. Created with Terraform"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CloudWatchExporterPolicyForEKSServiceAccount",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::*:role/EKSCloudWatchExporterTA"
        }
    ]
}
EOF
  tags        = merge(local.module_tags, local.tags_map)
}
