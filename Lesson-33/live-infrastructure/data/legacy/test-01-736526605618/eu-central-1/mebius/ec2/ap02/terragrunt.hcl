## terragrunt.hcl
terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

dependency "vpc" {
  config_path = "../../../core-infrastructure/imported-vpc/"
}

include {
  path = find_in_parent_folders()
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  tags_map       = merge(local.project_vars.locals.project_tags, { Backup = "Weekly-4Week-Retention" }, { Name = "mebius-ap02.test.data.rbua" })
  aws_account_id = local.account_vars.locals.aws_account_id
  name           = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-${local.tags_map.Project}-${basename(get_terragrunt_dir())}"
}

inputs = {
  name          = local.name
  ami           = "ami-0b75e08b7174d4b36"
  instance_type = "t3.medium"
  ebs_optimized = true
  subnet_id     = dependency.vpc.outputs.app_subnets.ids[0]
  key_name      = "rbua-data-test-mebius-key"
  metadata_options = {
    http_tokens                 = "required"
    http_put_response_hop_limit = "1"
  }
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 35
    },
  ]
  attach_ebs            = true
  ebs_availability_zone = "eu-central-1b"
  ebs_type              = "gp3"
  ebs_size_gb           = 80
  tags                  = local.tags_map

  sg_ingress_rules = [
    {
      from_port   = 6001
      to_port     = 6001
      protocol    = "TCP"
      cidr_blocks = ["10.226.154.128/25"]
    },
    {
      from_port   = 6002
      to_port     = 6002
      protocol    = "TCP"
      cidr_blocks = ["10.226.154.128/25"]
    },
    {
      from_port   = 6003
      to_port     = 6003
      protocol    = "TCP"
      cidr_blocks = ["10.226.154.128/25"]
    },
    {
      from_port   = 6004
      to_port     = 6004
      protocol    = "TCP"
      cidr_blocks = ["10.226.154.128/25"]
    },
    {
      from_port   = 6005
      to_port     = 6005
      protocol    = "TCP"
      cidr_blocks = ["10.226.154.128/25"]
    },
    {
      from_port   = 15000
      to_port     = 15000
      protocol    = "TCP"
      cidr_blocks = ["10.226.154.128/25"]
    },
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "TCP"
      cidr_blocks = ["10.191.242.32/28"]
    },
    {
      name        = "zabbix-agent"
      from_port   = 10050
      to_port     = 10050
      protocol    = "tcp"
      cidr_blocks = ["10.225.102.0/23"]
      description = "Zabbix Agent"
    },
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["10.225.102.0/23"]
    }
  ]
  sg_egress_rules = [
    {
      name        = "zabbix-proxy"
      from_port   = 10051
      to_port     = 10051
      protocol    = "tcp"
      cidr_blocks = ["10.225.102.0/23"]
      description = "Zabbix Proxy"
    },
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
