terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role"
}

dependency "policy" {
  config_path = find_in_parent_folders("policy")

  mock_outputs_allowed_terraform_commands = ["plan"]
  mock_outputs = {
    arn = "plan-arn"
  }
}

dependencies {
  paths = [find_in_parent_folders("policy")]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  domain_vars  = read_terragrunt_config(find_in_parent_folders("domain.hcl"))
  name         = "${basename(find_in_parent_folders("comm-vault"))}-role"
}

inputs = {
  create_role = true

  role_name               = local.name
  role_path               = "/"
  custom_role_policy_arns = [dependency.policy.outputs.arn, "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  trusted_role_services   = ["ec2.amazonaws.com"]
  role_requires_mfa       = false
  create_instance_profile = true

  tags = merge(local.account_vars.locals.tags,
    local.domain_vars.locals.common_tags,
    { map-migrated = "d-server-00sj1xhbfx35r4" })
}
