# terragrunt.hcl
terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-platform-host.git?ref=v2.0.3"
}

dependency "vpc" {
  config_path = "../../../core-infrastructure/imported-vpc/"
}

dependency "iam_role" {
  config_path  = "../../iam/iam_assumable_role/rbua-draif-prod-powerbi-ec2-ssm"
  mock_outputs = {
    iam_role_name = "test-role"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

include {
  path = find_in_parent_folders()
}

include "account" {
  path = find_in_parent_folders("account.hcl")
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  domain       = "data-draif"
  tags_map     = merge(local.project_vars.locals.project_tags, {
    Backup = "Daily-7day-Retention", Name = local.name, Platform = "Windows"
  })
  name = "${local.project_vars.locals.resource_prefix}-gateway-01"
}

inputs = {
  name                    = local.name
  ami                     = "ami-0590db8a5e457dd22"
  instance_type           = "t3.large"
  ebs_optimized           = true
  create_iam_role_ssm     = false
  disable_api_termination = true
  #TODO hardcode dependency
  iam_instance_profile    = dependency.iam_role.outputs.iam_role_name
  private_ip              = "10.226.132.124"
  subnet_id               = dependency.vpc.outputs.app_subnets.ids[0]
  availability_zone       = "eu-central-1b"
  metadata_options        = {
    http_tokens                 = "required"
    http_put_response_hop_limit = "1"
  }
  root_block_device = [
    {
      delete_on_termination = false
      encrypted             = true
      volume_type           = "gp3"
      throughput            = 200
      volume_size           = 50
    }
  ]

  aws_ebs_block_device = {
    disc_C = {
      device_name           = "/dev/xvdb"
      volume_size           = 50
      encrypted             = true
      volume_type           = "gp3"
      throughput            = 200
      iops                  = 3000
      encrypted             = true
      ebs_availability_zone = "eu-central-1b"
    }
  }
  key_name = "rbua-data-dev-powerbi-ami-image"
  tags     = local.tags_map

  sg_ingress_rules = [
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "TCP"
      cidr_blocks = ["10.191.242.32/28"]
      description = "Allow RDP from CyberArk pool"
    }
  ]

  sg_egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "This rules allows all outbound traffic"
    }
  ]

}
