include {
  path = find_in_parent_folders()
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

dependency "sg_ataccama_app" {
  config_path = "../../sg/app"
  mock_outputs = {
    mock_outputs_allowed_terraform_commands = ["plan"]
    security_group_id                       = "sg-12345678901234567"
  }
}

#dependency "sg_zabbix" {
#  config_path  = "../../../core-infrastructure/sg/zabbbix-agent/"
#  mock_outputs = {
#    mock_outputs_allowed_terraform_commands = ["plan"]
#    security_group_id                       = "sg-12345678901234567"
#  }
#}

dependency "vpc" {
  config_path = "../../../core-infrastructure/imported-vpc/"
}

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
    Name   = "ataccama-rdm.data.rbua",
    Backup = "Daily-7day-Retention"
    }
  )
  region = local.region_vars.locals.aws_region
  # kms_key = local.project_vars.locals.kms_key_id
  name = "${local.tags_map.Project}-${basename(get_terragrunt_dir())}.${local.tags_map.Domain}.${local.tags_map.Nwu}"
}

inputs = {
  name                         = local.name
  ami                          = "ami-066933f20c0e65bf3"
  instance_type                = "r5n.large"
  ebs_optimized                = false
  subnet_id                    = dependency.vpc.outputs.app_subnets.ids[0]
  availability_zone            = "eu-central-1a"
  key_name                     = "platformOps"
  tags                         = local.tags_map
  issue_certificate            = false
  create_security_group_inline = false
  # dependency.sg_zabbix.outputs.security_group_id,
  vpc_security_group_ids = [
    dependency.sg_ataccama_app.outputs.security_group_id
  ]
  root_block_device = [
    {
      delete_on_termination = true
      encrypted             = true
      volume_type           = "gp3"
      volume_size           = 120
    }
  ]
}
