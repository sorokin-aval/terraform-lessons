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
  name         = "ssm-ec2-role"
}

inputs = {
  role_description = "Allows EC2 instances to call AWS services on your behalf."
  create_role      = true

  role_name = local.name
  role_path = "/"
  custom_role_policy_arns = [
    "arn:aws:iam::${local.account_vars.locals.aws_account_id}:policy/servicecatalog-customers/CCOE-Mandatory-SSM-SessionPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  ]
  trusted_role_services   = ["ec2.amazonaws.com"]
  role_requires_mfa       = false
  create_instance_profile = true
  tags                    = merge(local.account_vars.locals.tags, { "Name" = local.name })
}

