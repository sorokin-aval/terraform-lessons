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
  project_vars   = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars    = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  tags_map       = local.project_vars.locals.project_tags
  aws_account_id = local.account_vars.locals.aws_account_id
  layer          = "gdwh"
}


inputs = {
  name        = "${local.project_vars.locals.resource_prefix}-sources"
  path        = "/"
  description = "${local.tags_map.Project}-sources policy. Created with Terragrunt. Used to grant access to sources for project"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "01getsources",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${local.project_vars.locals.resource_prefix}-${local.layer}-exadata/*"
            ]
        },
        {
            "Sid": "02listsources",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${local.project_vars.locals.resource_prefix}-${local.layer}-exadata"
            ]
        }
    ]
}
EOF

  tags = local.tags_map

}
