terraform {
  source = local.account_vars.sources_iam_assumable_role
}

locals {
  name         = "SSM"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

iam_role = local.account_vars.iam_role

inputs = {
  role_name               = local.name
  create_role             = true
  create_instance_profile = true
  role_requires_mfa       = false

  trusted_role_services   = [ "ec2.amazonaws.com" ]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation",
  ]
  number_of_custom_role_policy_arns = 2

  tags = merge(local.tags_map, { Name = local.name })
}
