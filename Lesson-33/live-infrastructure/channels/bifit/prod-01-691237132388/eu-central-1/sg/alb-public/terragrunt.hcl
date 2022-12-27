include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

dependency "sg" {
  config_path = find_in_parent_folders("sg/instance-app")
}

terraform {
  source = local.account_vars.sources_sg
}

locals {
  name         = "SG-RBUA-ALBPublic"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

inputs = {
  name        = local.name
  description = "Security group for public ALB"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_cidr_blocks = [
    {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS from CF"
      cidr_blocks = local.account_vars.cloud_flare_subnets
    },
    {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS from account private subnets"
      cidr_blocks = local.account_vars.account_subnets
    },
  ]
  egress_with_source_security_group_id = [
    {
      name        = "Nginx Port"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "Access to Nginx from ALB"
      source_security_group_id = dependency.sg.outputs.security_group_id
    },
    {
      name        = "Application Port"
      from_port   = 8084
      to_port     = 8084
      protocol    = "tcp"
      description = "Access to applications from ALB"
      source_security_group_id = dependency.sg.outputs.security_group_id
    },
  ]
}
