include {
  path = "${find_in_parent_folders()}"
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

dependencies {
  paths = ["../../iam_policy/ssm-connect/", "../../iam_policy/ec2/"]
}

locals {
  # Automatically load common variables from parent hcl
  project_vars   = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars    = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  region_vars    = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  tags_map       = local.project_vars.locals.project_tags
  aws_account_id = local.account_vars.locals.aws_account_id
  region         = local.region_vars.locals.aws_region
  nwu            = "rbua"
  module_tags    = {
    Role = local.role_name,
    Name = local.role_name
  }
  role_name = "${basename(get_terragrunt_dir())}"
}
terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

inputs = {
  create_role          = true
  role_name            = local.role_name
  max_session_duration = 43200
  description          = "This role provides full access to RDS service"
  tags                 = merge(local.module_tags, local.tags_map)
  provider_id          = "arn:aws:iam::${local.aws_account_id}:saml-provider/RBI-PingFederate"
  role_policy_arns     = [
    "arn:aws:iam::${local.aws_account_id}:policy/${local.project_vars.locals.resource_prefix}-ec2",
    "arn:aws:iam::aws:policy/service-role/AmazonRDSDirectoryServiceAccess",
    "arn:aws:iam::${local.aws_account_id}:policy/${local.project_vars.locals.resource_prefix}-ssm"
  ]

}
