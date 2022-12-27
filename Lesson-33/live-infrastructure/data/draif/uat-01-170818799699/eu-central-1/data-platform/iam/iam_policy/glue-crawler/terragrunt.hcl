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
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  # Extract out exact variables for reuse
  source_map   = local.source_vars.locals
  tags_map     = local.project_vars.locals.project_tags
}

inputs = {
  name        = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${basename(get_terragrunt_dir())}"
  path        = "/"
  description = "${basename(get_terragrunt_dir())} policy. Created with Terragrunt. Used by team to store project files"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:AssociateKmsKey"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF

  tags = local.tags_map

}
