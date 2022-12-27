dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.locals.sources["sg"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  name            = basename(get_terragrunt_dir())
  use_name_prefix = false
  description     = "Security group for ssm-vpc-endpoints"
  vpc_id          = dependency.vpc.outputs.vpc_id.id
  tags            = local.account_vars.locals.tags

  ingress_cidr_blocks = concat(
    dependency.vpc.outputs.app_subnet_cidr_blocks,
    dependency.vpc.outputs.db_subnet_cidr_blocks,
  )
  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "SSM"
    },
  ]
}
