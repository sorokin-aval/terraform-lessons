dependency "vpc" { config_path = find_in_parent_folders("vpc-info") }
dependency "sg"  { config_path = find_in_parent_folders("sg/instance-cmsfront") }
dependency "sg-webpromo"  { config_path = find_in_parent_folders("webpromo/sg/instance-webpromo") }

terraform { source = local.account_vars.sources_sg }

locals {
  name         = "SG-RBUA-${local.account_vars.environment_letter}-RaifSiteInternalALB"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

inputs = {
  name        = local.name
  description = "Security group for the RaifSite Internal ALB"
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
      description = "Access from account Tier1 subnets"
      cidr_blocks = local.account_vars.tier1_subnets
    },
    {
      name        = "HTTPS"
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      description = "Access from RBUA private IP pool"
      cidr_blocks = local.account_vars.rbua_private_subnets
    },
    {
      name        = "HTTPS"
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      description = "Access from account Tier1 subnets"
      cidr_blocks = local.account_vars.tier1_subnets
    },
  ]
  egress_with_source_security_group_id = [
    {
      name        = "CMS"
      from_port   = 4343
      to_port     = 4343
      protocol    = "tcp"
      description = "Allow access to admins area of CMSFront Instance"
      source_security_group_id = dependency.sg.outputs.security_group_id
    },
    {
      name        = "Site"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow access to the site on CMSFront instances via internal URL"
      source_security_group_id = dependency.sg.outputs.security_group_id
    },
    {
      name        = "WebPromo"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow access to the site on WebPromo instances via internal URL"
      source_security_group_id = dependency.sg-webpromo.outputs.security_group_id
    },
    {
      name        = "WebPromo"
      from_port   = 8443
      to_port     = 8443
      protocol    = "tcp"
      description = "Allow access to the admin part on WebPromo instances via internal URL"
      source_security_group_id = dependency.sg-webpromo.outputs.security_group_id
    },
  ]
}
