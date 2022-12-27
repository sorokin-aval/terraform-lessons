dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

dependency "sg" {
  config_path = find_in_parent_folders("sg/instance-sms")
}

terraform {
  source = local.account_vars.sources_sg
}

locals {
  name         = "SG-RBUA-${local.account_vars.environment_letter}-UISVPCEndpointEmailSMTP"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

inputs = {
  name        = local.name
  description = "Security group for the Email SMTP VPC Endpoint"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_source_security_group_id = [
    {
      name        = "SMTP"
      from_port   = 587
      to_port     = 587
      protocol    = "tcp"
      description = "Access from SMS Instance"
      source_security_group_id = dependency.sg.outputs.security_group_id
    },
  ]
}
