terraform {
  source = local.account_vars.locals.sources["host"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  domain_vars  = read_terragrunt_config(find_in_parent_folders("domain.hcl"))
  name         = basename(get_terragrunt_dir())
}

inputs = {
  vpc             = local.account_vars.locals.vpc
  domain          = local.account_vars.locals.domain
  name            = local.name
  ami             = "ami-0dcc0ebde7b2e00db"
  type            = try(local.account_vars.locals.ec2_types[local.name], "")
  subnet          = "LZ-RBUA_Payments_*-InternalA"
  zone            = "eu-central-1a"
  ssh-key         = "Payments-SRE"
  security_groups = ["ad", "ssh"]
  ebs_optimized   = false
  tags = merge(
    local.account_vars.locals.tags,
    local.domain_vars.locals.common_tags,
    { map-migrated = "d-server-03ju7pxgzeke53" }
  )
  # Security group rules
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["0.0.0.0/0"], description : "All traffic" },
  ]
  # Target group settings
  tg_entries = {}
}
