include {
  path = "${find_in_parent_folders()}"
}
iam_role = local.account_vars.iam_role

include "account" {
  path = find_in_parent_folders("account.hcl")
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  # Extract out exact variables for reuse
  source_map   = local.source_vars.locals
  tags_map     = local.project_vars.locals.project_tags
  project_name = split("${local.tags_map.Domain}-", local.tags_map.Project)[1]
  layer        = "integration"
  s3_prefix    = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.layer}"
}


inputs = {
  name        = "${local.tags_map.Nwu}-${local.tags_map.Tech_domain}-s3"
  path        = "/"
  description = "${basename(get_terragrunt_dir())} policy. Created with Terragrunt. Used by team to store project files"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ProjectBucket",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${local.s3_prefix}-${local.project_name}/*",
                "arn:aws:s3:::${local.s3_prefix}-${local.project_name}"
            ]
        }
    ]
}
EOF

  tags = local.tags_map

}
