dependency "vpc" { config_path = find_in_parent_folders("vpc-info") }
dependency "sg-cmsfront"  { config_path = find_in_parent_folders("sg/instance-cmsfront") }
dependency "sg-nginx"  { config_path = find_in_parent_folders("sg/instance-maintenance-nginx") }
dependency "sg-webpromo"  { config_path = find_in_parent_folders("webpromo/sg/instance-webpromo") }

terraform { source = local.account_vars.sources_sg }

locals {
  name         = "SG-RBUA-${local.account_vars.environment_letter}-ALBPublic"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
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
      description = "Access from CloudFlare"
      cidr_blocks = local.account_vars.cloud_flare_subnets
    },
    {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Access from RBUA public subnets"
      cidr_blocks = local.account_vars.rbua_public_subnets
    },
  ]
  egress_with_source_security_group_id = [
    {
      name        = "HTTPS CMSFront"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS access to CMSFront Instances"
      source_security_group_id = dependency.sg-cmsfront.outputs.security_group_id
    },
    {
      name        = "App CMSFront"
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      description = "Access to CMSFront Instances by 8443"
      source_security_group_id = dependency.sg-cmsfront.outputs.security_group_id
    },
    {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow access to the maintenance page server by Nginx on the temporary instance"
      source_security_group_id = dependency.sg-nginx.outputs.security_group_id
    },
    {
      name        = "WebPromo"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow access to the site on WebPromo instances via internal URL"
      source_security_group_id = dependency.sg-webpromo.outputs.security_group_id
    },
  ]
}
