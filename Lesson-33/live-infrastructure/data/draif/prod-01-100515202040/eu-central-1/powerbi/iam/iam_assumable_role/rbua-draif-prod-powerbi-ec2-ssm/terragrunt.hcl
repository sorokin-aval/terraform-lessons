include {
  path = "${find_in_parent_folders()}"
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

dependency "vss_policy" {
  config_path  = "../../iam_policy/rbua-draif-prod-powerbi-ec2-win-vss-backup-creation"
  mock_outputs = {
    arn = "arn:aws:iam::${local.aws_account_id}/policy/mock_output"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

locals {
  # Automatically load common variables from parent hcl
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  nwu          = "rbua"

  # Extract out exact variables for reuse
  resource_prefix = "${local.project_vars.locals.resource_prefix}"
  source_map      = local.source_vars.locals
  tags_map        = local.project_vars.locals.project_tags
  aws_account_id  = local.account_vars.locals.aws_account_id
  module_tags     = {
    Role = local.resource_prefix,
    Name = local.resource_prefix
  }
}

inputs = {
  create_role             = true
  create_instance_profile = true
  role_path               = "/role/"
  role_name               = local.resource_prefix
  description             = "Provides AWS Backup permission to create and restore backups on your Windows-based platform VMs"
  tags                    = merge(local.module_tags, local.tags_map)
  role_requires_mfa       = false
  trusted_role_services   = [
    "ec2.amazonaws.com"
  ]
  custom_role_policy_arns = [
    dependency.vss_policy.outputs.arn,
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::${local.aws_account_id}:policy/servicecatalog-customers/CCOE-Mandatory-SSM-SessionPolicy"
  ]
}
