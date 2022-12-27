dependency "sg" {
  config_path = find_in_parent_folders("sg")
}

dependency "ssm-vpc-endpoint" {
  config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint")
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

dependencies {
  paths = [
    find_in_parent_folders("sg"),
    find_in_parent_folders("core-infrastructure/sg/ssh"),
  ]
}

terraform {
  source = local.account_vars.locals.sources["host"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = basename(get_terragrunt_dir())
}

inputs = {
  vpc             = dependency.vpc.outputs.vpc_id.id
  domain          = local.account_vars.locals.domain
  name            = local.name
  ami_name        = local.name
  type            = try(local.account_vars.locals.ec2_types[local.name], "")
  hosted_zone     = "${local.app_vars.locals.name}.${local.account_vars.locals.domain}"
  ebs_optimized   = false
  security_groups = ["ad", "ssh", "${dependency.sg.outputs.security_group_name}", "observable"]

  root_block_device = [
    {
      volume_size = "15"
      volume_type = "gp3"
    }
  ]
  block_device_encrypted = false

  tags = merge(local.app_vars.locals.tags, { map-migrated = "d-server-02qoz1oy4dcqq2" })

  # Security group rules
  ingress = [
    { from_port : 8441, to_port : 8443, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.public_subnet_cidr_blocks, description : "public_subnet_cidr_blocks" },
    { from_port : 8441, to_port : 8443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["cloudflare-ips"], description : "cloudflare-ips" },
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 80, to_port : 80, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["cloudflare-ips"], description : "cloudflare-ips" },
    { from_port : 9041, to_port : 9041, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["upc"], description : "upc" },    
    { from_port : 5008, to_port : 5008, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["upc"], description : "upc" },    
  ]
  # Target group settings
  tg_entries = {}
}
