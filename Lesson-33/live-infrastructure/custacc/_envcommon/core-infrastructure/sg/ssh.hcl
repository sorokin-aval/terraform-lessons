terraform {
  source = local.account_vars.locals.sources["sg"]
}

iam_role = "arn:aws:iam::${local.account_vars.locals.aws_account_id}:role/terraform-role"

dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

locals {
  account_vars            = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map                = read_terragrunt_config(find_in_parent_folders("domain.hcl"))
}

inputs = {
  name                    = "Common: ${basename(get_terragrunt_dir())}"
  use_name_prefix         = false
  description             = "Common security group for SSH"
  vpc_id                  = dependency.vpc.outputs.vpc_id.id
  tags                    = local.tags_map.locals.tags

  ingress_cidr_blocks     = local.account_vars.locals.ips["cyberark"]
  ingress_rules           = ["ssh-tcp"]
}