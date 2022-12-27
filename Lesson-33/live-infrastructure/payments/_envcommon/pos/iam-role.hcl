terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
}

inputs = {
  create_role             = true
  role_name               = "rds-directoryservice-kerberos-access-role"
  role_path               = "/"
  custom_role_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonRDSDirectoryServiceAccess"]
  trusted_role_services   = ["directoryservice.rds.amazonaws.com", "rds.amazonaws.com"]
  role_requires_mfa       = false
  # Requires manual attachment. Fix module host
  tags = local.app_vars.locals.tags
}
