include "account" {
  path = find_in_parent_folders("account.hcl")
}

dependency "vpc" {
  config_path = "../../../../core-infrastructure/imported-vpc/"
}

dependency "nifi_registry_sg" {
  config_path  = "../"
  mock_outputs = {
    sg_id = "mock"
  }
  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}
dependency "nifi_sg" {
  config_path  = "../../nifi-01/"
  mock_outputs = {
    sg_id = "mock"
  }
  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}
dependency "alb_sg" {
  config_path  = "../../alb/alb-sg/"
  mock_outputs = {
    security_group_id = "mock"
  }
  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}
terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.13.0"
}


locals {
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map     = merge(local.project_vars.locals.project_tags)
  name         = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-nifi-registry"
}

inputs = {
  name              = local.name
  create_sg         = false
  description       = "Security group for ${local.name}"
  vpc_id            = dependency.vpc.outputs.vpc_id.id
  security_group_id = dependency.nifi_registry_sg.outputs.sg_id
  tags              = local.tags_map

  ingress_with_source_security_group_id = [
    {
      from_port                = 9443
      to_port                  = 9443
      protocol                 = "TCP"
      description              = "https for nifi registry"
      source_security_group_id = dependency.alb_sg.outputs.security_group_id
    },
    {
      from_port                = 9443
      to_port                  = 9443
      protocol                 = "TCP"
      description              = "https for nifi"
      source_security_group_id = dependency.nifi_sg.outputs.sg_id
    },
  ]
  egress_with_cidr_blocks = [
    {
      name        = "All"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}
