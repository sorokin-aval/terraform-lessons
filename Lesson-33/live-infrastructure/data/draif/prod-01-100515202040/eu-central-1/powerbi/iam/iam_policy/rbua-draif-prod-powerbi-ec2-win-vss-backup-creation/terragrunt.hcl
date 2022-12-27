include {
  path = "${find_in_parent_folders()}"
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

locals {
  # Automatically load common variables from parent hcl
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  #account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out exact variables for reuse
  resource_prefix = "${local.project_vars.locals.resource_prefix}"

  source_map = local.source_vars.locals
  tags_map   = local.project_vars.locals.project_tags

  #aws_account_id = local.account_vars.locals.aws_account_id
  region = local.region_vars.locals.aws_region

}


inputs = {
  name        = "${local.resource_prefix}-policy"
  path        = "/"
  description = "EC2 VSS for Windows based VM ${local.resource_prefix}-policy policy. Created with Terragrunt"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:CreateTags",
            "Resource": [
                "arn:aws:ec2:*::snapshot/*",
                "arn:aws:ec2:*::image/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeImages",
                "ec2:DescribeInstances",
                "ec2:CreateTags",
                "ec2:CreateSnapshot",
                "ec2:CreateImage"
            ],
            "Resource": "*"
        }
    ]
}
EOF

  tags = local.tags_map

}
