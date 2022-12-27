terraform {
  source = local.account_vars.sources_iam_assumable_role
}

dependency "ec2_policy" {
  config_path = find_in_parent_folders("policy/ec2-describe")
}

dependency "s3_policy" {
  config_path = find_in_parent_folders("policy/s3-exchange")
}

iam_role = local.account_vars.iam_role

locals {
  name         = "EC2Role"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

inputs = {
  role_name               = local.name
  create_role             = true
  create_instance_profile = true
  role_requires_mfa       = false

  trusted_role_services   = [ "ec2.amazonaws.com" ]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation",
    "${dependency.ec2_policy.outputs.arn}",
    "${dependency.s3_policy.outputs.arn}",
    "${local.account_vars.ccoe_ssm_iam_policy}"
  ]
  number_of_custom_role_policy_arns = 5

  tags = merge(local.tags_map, { Name = local.name })
}
