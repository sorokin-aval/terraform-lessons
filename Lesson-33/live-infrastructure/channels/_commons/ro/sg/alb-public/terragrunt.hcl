dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

dependency "sg-clientendpoint" {
  config_path = find_in_parent_folders("sg/instance-clientendpoint")
}

dependency "sg-ibank" {
  config_path = find_in_parent_folders("sg/instance-ibank")
}

dependency "sg-oauth" {
  config_path = find_in_parent_folders("sg/instance-oauth")
}

terraform {
  source = local.account_vars.sources_sg
}

locals {
  name         = "SG-RBUA-${local.account_vars.environment_letter}-LIAALBPublic"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  app_port     = local.account_vars.default_app_port
}

inputs = {
  name        = local.name
  description = "Security group for the public ALB"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_cidr_blocks = [
    {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Access from RBUA public IP pool"
      cidr_blocks = local.account_vars.rbua_public_subnets
    },
    {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Access from CloudFlair"
      cidr_blocks = local.account_vars.cloud_flare_subnets
    }
  ]
  egress_with_source_security_group_id = [
    {
      name        = "HTTPS ClientEndpoint"
      from_port   = local.app_port
      to_port     = local.app_port
      protocol    = "tcp"
      description = "HTTPS access to ClientEndpoint Instance"
      source_security_group_id = dependency.sg-clientendpoint.outputs.security_group_id
    },
    {
      name        = "HTTPS iBank"
      from_port   = local.app_port
      to_port     = local.app_port
      protocol    = "tcp"
      description = "HTTPS access to iBank Instance"
      source_security_group_id = dependency.sg-ibank.outputs.security_group_id
    },
    {
      name        = "HTTPS oAuth"
      from_port   = local.app_port
      to_port     = local.app_port
      protocol    = "tcp"
      description = "HTTPS access to oAuth Instance"
      source_security_group_id = dependency.sg-oauth.outputs.security_group_id
    },
  ]
}
