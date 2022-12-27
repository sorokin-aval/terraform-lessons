include {
  path = find_in_parent_folders()
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

dependency "sg_sota_db" {
  config_path = "../../sg/db"
  mock_outputs = {
    mock_outputs_allowed_terraform_commands = ["plan"]
    security_group_id                       = "sg-12345678901234567"
  }
}

dependency "sg_zabbix" {
  config_path = "../../../core-infrastructure/sg/zabbbix-agent/"
  mock_outputs = {
    mock_outputs_allowed_terraform_commands = ["plan"]
    security_group_id                       = "sg-12345678901234567"
  }
}

dependency "vpc" {
  config_path = "../../../core-infrastructure/imported-vpc/"
}

# dependency "vpc" {
#   config_path = "../../../core-infrastructure/baseline/"
# }

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  # Extract out exact variables for reuse
  source_map = local.source_vars.locals
  tags_map = merge(local.project_vars.locals.project_tags, {
    Name   = "sota-db02.data.rbua",
    Backup = "Daily-3day-Retention"
    }
  )
  region  = local.region_vars.locals.aws_region
  kms_key = local.project_vars.locals.kms_key_id
  name    = "${local.tags_map.Project}-${basename(get_terragrunt_dir())}.${local.tags_map.Domain}.${local.tags_map.Nwu}"
}

inputs = {
  name                         = local.name
  ami                          = "ami-069f895d3881313cb"
  instance_type                = "t3.micro"
  ebs_optimized                = true
  subnet_id                    = dependency.vpc.outputs.db_subnets.ids[1]
  availability_zone            = "eu-central-1b"
  key_name                     = "dbre"
  tags                         = local.tags_map
  issue_certificate            = false
  create_security_group_inline = false
  private_ip                   = "10.226.155.125"
  vpc_security_group_ids = [
    dependency.sg_zabbix.outputs.security_group_id,
    dependency.sg_sota_db.outputs.security_group_id
  ]
  root_block_device = [
    {
      delete_on_termination = false
      encrypted             = true
      volume_type           = "gp3"
      throughput            = 125
      iops                  = 3000
      volume_size           = 19
      snapshot_id           = "snap-03ec30ccfe420d3a7"
      kms_key_id            = local.kms_key
    }
  ]
  aws_ebs_block_device = {
    data1 = {
      device_name           = "/dev/sdf"
      volume_type           = "gp3"
      volume_size           = 24
      throughput            = 125
      iops                  = 3000
      encrypted             = true
      delete_on_termination = false
      kms_key_id            = local.kms_key
    },
    data2 = {
      device_name           = "/dev/sdg"
      volume_type           = "gp3"
      volume_size           = 6
      throughput            = 125
      iops                  = 3000
      encrypted             = true
      delete_on_termination = false
      kms_key_id            = local.kms_key
    }
  }
}
