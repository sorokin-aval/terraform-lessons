#custacc commvault media agent !!!
include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//commvault-backup-aws?ref=commvault-media-agent_v0.0.1"
}

dependency "vpc" {
  #  config_path = "../../../core-infrastructure/baseline/"
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

locals {
  #  common_tags    = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = basename(get_terragrunt_dir())
}

inputs = {
  s3_bucket_name = "commvault-s3"
  s3_bucket_tags = merge(local.app_vars.locals.tags, { map-migrated = "d-server-00sj1xhbfx35r4" })

  name              = local.name
  availability_zone = "eu-central-1a"
  ami               = "ami-09439f09c55136ecf"
  instance_type     = "c6a.large"
  #  instance_type            = "r5a.large"
  app_subnets_names_filter = "*InternalA"
  subnet_id                = dependency.vpc.outputs.app_subnets.ids[1]
  root_block_device        = [{ volume_size = "8", volume_type = "gp3" }]

  aws_ebs_volumes = { "index_volume" = { "device" = "/dev/xvdb", "size" = "5", "type" = "gp3" },
  "ddb_volume" = { "device" = "/dev/xvdc", "size" = "10", "type" = "gp3" } }
  key_name = "dcre"

  tags        = merge(local.app_vars.locals.tags, { map-migrated = "d-server-01i0y2inoanfl9" })
  volume_tags = merge(local.app_vars.locals.tags, { map-migrated = "d-server-01i0y2inoanfl9" })

  sg_rules = [{ type = "ingress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.191.2.184/32"], description = "CommCell bigpoint.ms.aval" },
    { type = "ingress", from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["10.0.0.0/8"], description = "SSH" },
    { type = "ingress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.227.47.0/26"], description = "LZ-RBUA_custacc_prod_02-InternalA" },
    { type = "ingress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.227.47.64/26"], description = "LZ-RBUA_custacc_prod_02-InternalB" },
    { type = "ingress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.227.47.128/27"], description = "LZ-RBUA_custacc_prod_02-RestrictedA" },
    { type = "ingress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.227.47.160/27"], description = "LZ-RBUA_custacc_prod_02-RestrictedB" },
    { type = "ingress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.227.47.192/27"], description = "LZ-RBUA_custacc_prod_02-TransferA" },
    { type = "ingress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.227.47.224/27"], description = "LZ-RBUA_custacc_prod_02-TransferB" },
    { type = "egress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.227.47.0/26"], description = "LZ-RBUA_custacc_prod_02-InternalA" },
    { type = "egress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.227.47.64/26"], description = "LZ-RBUA_custacc_prod_02-InternalB" },
    { type = "egress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.227.47.128/27"], description = "LZ-RBUA_custacc_prod_02-RestrictedA" },
    { type = "egress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.227.47.160/27"], description = "LZ-RBUA_custacc_prod_02-RestrictedB" },
    { type = "egress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.227.47.192/27"], description = "LZ-RBUA_custacc_prod_02-TransferA" },
    { type = "egress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.227.47.224/27"], description = "LZ-RBUA_custacc_prod_02-TransferB" },
    { type = "egress", from_port = 8400, to_port = 8403, protocol = "tcp", cidr_blocks = ["10.191.2.184/32"], description = "CommCell bigpoint.ms.aval" },
    { type = "egress", from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["10.0.0.0/8"], description = "SSH" },
  { type = "egress", from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["52.219.170.161/32"], description = "Amazon linux update repositories" }]
}