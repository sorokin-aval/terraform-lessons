# Custacc 
include "root" {
  path   = find_in_parent_folders()
  expose = true
}

iam_role = local.account_vars.iam_role

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = "SessionManagerRole"
}

inputs = {
  create_role = true

  role_name = local.name
  role_path = "/"
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::${local.account_vars.locals.aws_account_id}:policy/servicecatalog-customers/CCOE-Mandatory-SSM-SessionPolicy"
  ]
  trusted_role_services   = ["ec2.amazonaws.com"]
  role_requires_mfa       = false
  create_instance_profile = true
  tags                    = local.app_vars.locals.tags
}

