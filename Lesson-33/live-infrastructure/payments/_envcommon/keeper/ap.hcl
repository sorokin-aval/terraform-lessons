dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }
dependency "sg" { config_path = find_in_parent_folders("sg") }
dependency "alb-sg" { config_path = find_in_parent_folders("alb-internal/sg") }
dependency "tg-alb" { config_path = find_in_parent_folders("tg-alb") }
dependency "smtp-vpc-endpoint" { config_path = find_in_parent_folders("core-infrastructure/sg/smtp-vpc-endpoint") }
dependency "cv-ma01" { config_path = find_in_parent_folders("core-infrastructure/comm-vault/cv-ma01") }

dependencies {
  paths = [
    find_in_parent_folders("sg"),
    find_in_parent_folders("tg-alb"),
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
  vpc             = local.account_vars.locals.vpc
  domain          = local.account_vars.locals.domain
  name            = local.name
  ami_name        = "${local.name}"
  type            = try(local.account_vars.locals.ec2_types[local.name], "")
  hosted_zone     = "${local.app_vars.locals.name}.${local.account_vars.locals.domain}"
  security_groups = ["ad", "rdp", "${dependency.sg.outputs.security_group_name}", "observable"]
  ebs_optimized   = false
  tags            = merge(local.app_vars.locals.tags, { map-migrated = "d-server-03arg78j8sl36i" })
  # Security group rules
  ingress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.alb-sg.outputs.security_group_id], description : "alb-internal" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" }, # hardcode vpc, only prod
  ]
  egress = [
    { from_port : 465, to_port : 465, protocol : "tcp", security_groups : [dependency.smtp-vpc-endpoint.outputs.security_group_id], description : "smtp-vpc-endpoint" },
    { from_port : 587, to_port : 587, protocol : "tcp", security_groups : [dependency.smtp-vpc-endpoint.outputs.security_group_id], description : "smtp-vpc-endpoint" },
    { from_port : 1415, to_port : 1415, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["swiftz"], description : "swiftz" },
    { from_port : 80, to_port : 80, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["backup-dev-xn83-internal"], description : "backup-dev-xn83-internal" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["backup-dev-xn83-internal"], description : "backup-dev-xn83-internal" },
    { from_port : 4443, to_port : 4443, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["backup-dev-xn83-internal"], description : "backup-dev-xn83-internal" },
    { from_port : 5671, to_port : 5672, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["backup-dev-xn83-internal"], description : "backup-dev-xn83-internal" },
    { from_port : 14442, to_port : 14443, protocol : "tcp", cidr_blocks : local.account_vars.locals.aws_accounts["backup-dev-xn83-internal"], description : "backup-dev-xn83-internal" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["nexus.test.kv.aval"], description : "nexus.test.kv.aval" },
    { from_port : 1440, to_port : 1440, protocol : "tcp", security_groups : [dependency.sg.outputs.security_group_id], description : "keeper-sg" },
    { from_port : 1434, to_port : 1434, protocol : "udp", security_groups : [dependency.sg.outputs.security_group_id], description : "keeper-sg" },
    { from_port : 5671, to_port : 5672, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["ndu"], description : "ndu" },
    { from_port : 80, to_port : 80, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["nbu-http"], description : "nbu-http" },
    { from_port : 14442, to_port : 14443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["nbu-https"], description : "nbu-https" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["nbu-https"], description : "nbu-https" },
    { from_port : 4443, to_port : 4443, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["nbu-https"], description : "nbu-https" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "all-https" },
    { from_port : 80, to_port : 80, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["cert-authority"], description : "certificate authority" },
    { from_port : 135, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wfile"], description : "uadho-wfile" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["uadho-wfile"], description : "uadho-wfile" },
    { from_port : 137, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["uadho-wfile"], description : "uadho-wfile" },
    { from_port : 135, to_port : 139, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["dfs-wfile"], description : "dfs-wfile" },
    { from_port : 445, to_port : 445, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["dfs-wfile"], description : "dfs-wfile" },
    { from_port : 137, to_port : 138, protocol : "udp", cidr_blocks : local.account_vars.locals.ips["dfs-wfile"], description : "dfs-wfile" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" }, # hardcode vpc, only prod
    { from_port : 8400, to_port : 8403, protocol : "tcp", security_groups: [dependency.cv-ma01.outputs.security_group_id], description : dependency.cv-ma01.outputs.name },
  ]
  # Target group settings
  tg_entries = {
    "443" = {
      target_port  = 443
      target_group = dependency.tg-alb.outputs.target_groups["443"].arn
    },
  },
}
