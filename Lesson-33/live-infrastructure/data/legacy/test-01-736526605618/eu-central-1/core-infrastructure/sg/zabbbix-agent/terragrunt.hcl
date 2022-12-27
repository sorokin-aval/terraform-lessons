include {
  path = "${find_in_parent_folders()}"
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

dependency "vpc" {
  config_path = "../../imported-vpc/"
}

locals {
  # Automatically load common variables from parent hcl
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))

  # Extract out exact variables for reuse
  source_map = local.source_vars.locals
  tags_map   = merge(local.project_vars.locals.project_tags, { Name = "legacy" })
  name       = "${local.tags_map.Name}-${local.tags_map.Environment}-${basename(get_terragrunt_dir())}"
}

inputs = {
  name        = local.name
  description = "Security group for ${basename(get_terragrunt_dir())}"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_cidr_blocks = [
    {
      name        = "zabbix-agent"
      from_port   = 10050
      to_port     = 10050
      protocol    = "tcp"
      cidr_blocks = "10.225.102.0/23"
      description = "Zabbix Agent"
    },
    {
      rule        = "all-icmp"
      cidr_blocks = "10.225.102.0/23"
    }
  ]
  egress_with_cidr_blocks = [
    {
      name        = "zabbix-proxy"
      from_port   = 10051
      to_port     = 10051
      protocol    = "tcp"
      cidr_blocks = "10.225.102.0/23"
      description = "Zabbix Proxy"
    }
  ]
}
