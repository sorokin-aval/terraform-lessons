dependency "vpc" { config_path = find_in_parent_folders("vpc-info") }
dependency "sg_adm" { config_path = find_in_parent_folders("sg/instance-adm") }
dependency "sg_front" { config_path = find_in_parent_folders("sg/instance-front") }

terraform { source = local.account_vars.sources_sg }

locals {
  name         = "SG-RBUA-${local.account_vars.environment_letter}-LIAALBInternal"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  app_port     = local.account_vars.default_app_port
}

iam_role = local.account_vars.iam_role

inputs = {
  name        = local.name
  description = "Security group for the Internal ALB"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_cidr_blocks = [
    {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Access from RBUA private IP pool"
      cidr_blocks = local.account_vars.rbua_private_subnets
    },
    {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Access from bank branches private IP pool"
      cidr_blocks = local.account_vars.branches_subnets
    },
    {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Access from Tier2"
      cidr_blocks = local.account_vars.tier2_subnets
    }
  ]
  egress_with_source_security_group_id = [
    {
      name        = "HTTPS ADM"
      from_port   = local.app_port
      to_port     = local.app_port
      protocol    = "tcp"
      description = "HTTPS access to ADM Instances"
      source_security_group_id = dependency.sg_adm.outputs.security_group_id
    },
    {
      name        = "HTTPS Front"
      from_port   = local.app_port
      to_port     = local.app_port
      protocol    = "tcp"
      description = "HTTPS access to Front Instances"
      source_security_group_id = dependency.sg_front.outputs.security_group_id
    },
  ]
}
