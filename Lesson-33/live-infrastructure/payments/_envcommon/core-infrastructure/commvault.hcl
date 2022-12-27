dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

terraform {
  source = local.account_vars.locals.sources["commvault"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  domain_vars  = read_terragrunt_config(find_in_parent_folders("domain.hcl"))
  name         = "cv-ma01-${substr(local.account_vars.locals.aws_account_id, -6, -1)}"
}

inputs = {
  s3_bucket_name_client = ["backup-commvault-${local.account_vars.locals.aws_account_id}", "backup-commvault-worm-${local.account_vars.locals.aws_account_id}", "backup-commvault-worm-02-${local.account_vars.locals.aws_account_id}"]
  s3_bucket_tags        = merge(local.account_vars.locals.tags, local.domain_vars.locals.common_tags, { map-migrated = "" })

  name            = local.name
  instance_type   = "r5a.large"
  aws_ebs_volumes = {
    "index_volume" = { "device" = "/dev/xvdb", "size" = "5", "type" = "gp3" },
    "ddb_volume"   = { "device" = "/dev/xvdc", "size" = "20", "type" = "gp3" }
  }

  tags        = merge(local.account_vars.locals.tags, local.domain_vars.locals.common_tags, { map-migrated = "" })
  volume_tags = merge(local.account_vars.locals.tags, local.domain_vars.locals.common_tags, { map-migrated = "" })

  sg_rules = [
    { type : "ingress", from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH" },
    { type : "ingress", from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "CommCell bigpoint.ms.aval" },
    { type : "ingress", from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.db_subnet_cidr_blocks, description : "db_subnet_cidr_blocks" },

    { type : "egress", from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.db_subnet_cidr_blocks, description : "db_subnet_cidr_blocks" },
    { type : "egress", from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "CommCell bigpoint.ms.aval" },
    { type : "egress", from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault-ro"], description : "comm-vault-ro" },
    { type : "egress", from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH" },
  ]
}

