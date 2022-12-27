include {
  path = find_in_parent_folders()
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//commvault-backup-aws?ref=commvault-media-agent_v0.0.1"
}

dependency "vpc" {
  config_path = "../../core-infrastructure/imported-vpc/"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  name         = basename(get_terragrunt_dir())
}

inputs = {
  s3_bucket_name = "commvault-s3"
  s3_bucket_tags = merge(local.common_tags.locals, { map-migrated = "d-server-00sj1xhbfx35r4" })

  name                     = local.name
  availability_zone        = "eu-central-1a"
  ami                      = "ami-09439f09c55136ecf"
  instance_type            = "r5a.large"
  app_subnets_names_filter = "*InternalA"
  subnet_id                = dependency.vpc.outputs.app_subnets.ids[0]
  root_block_device        = [{ volume_size = "8", volume_type = "gp3" }]

  aws_ebs_volumes = { "index_volume" = { "device" = "/dev/xvdb", "size" = "5", "type" = "gp3" },
  "ddb_volume" = { "device" = "/dev/xvdc", "size" = "10", "type" = "gp3" } }
  key_name = "dcre"

  tags        = merge(local.common_tags.locals, { map-migrated = "d-server-01i0y2inoanfl9" }, { Name = "commvault-agent" })
  volume_tags = merge(local.common_tags.locals, { map-migrated = "d-server-01i0y2inoanfl9" })


  sg_rules = [{ type = "ingress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.191.2.184/32"], description = "CommCell bigpoint.ms.aval" },
    { type = "ingress", from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["10.0.0.0/8"], description = "SSH" },
    { type = "ingress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.226.155.0/27"], description = "RBUA_Legacy_Prod_01-InternalA" },
    { type = "ingress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.226.155.32/27"], description = "RBUA_Legacy_Prod_01-InternalB" },
    { type = "ingress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.226.155.64/27"], description = "RBUA_Legacy_Prod_01-RestrictedA" },
    { type = "ingress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.226.155.96/27"], description = "RBUA_Legacy_Prod_01-RestrictedB" },
    { type = "egress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.226.155.0/27"], description = "RBUA_Legacy_Prod_01-InternalA" },
    { type = "egress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.226.155.32/27"], description = "RBUA_Legacy_Prod_01-InternalB" },
    { type = "egress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.226.155.64/27"], description = "RBUA_Legacy_Prod_01-RestrictedA" },
    { type = "egress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.226.155.96/27"], description = "RBUA_Legacy_Prod_01-RestrictedB" },
    { type = "egress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], description = "CommCell bigpoint.ms.aval" },
    { type = "egress", from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["10.0.0.0/8"], description = "SSH" },
  { type = "egress", from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["52.219.170.161/32"], description = "Amazon linux update repositories" }]
}
