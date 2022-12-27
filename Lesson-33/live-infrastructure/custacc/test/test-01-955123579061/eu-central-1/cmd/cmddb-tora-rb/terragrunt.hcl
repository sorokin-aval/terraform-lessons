# 
include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-platform-host.git//?ref=v2.1.0"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = "ORACLE_DB_CMD_4LAZUTIN_TEST"
}

inputs = {
  ebs_optimized        = true
  create_iam_role_ssm  = false
  iam_instance_profile = "AmazonSSMRoleForInstancesQuickSetup"
  ami                  = "ami-0d056145308d2d110"
  instance_type        = "c5.9xlarge"
  key_name             = "cutass"
  name                 = local.name
  subnet_id            = dependency.vpc.outputs.app_subnets.ids[0]

  tags        = merge(local.app_vars.locals.tags, { "map-migrated" = "d-server-01qk53073ldk8w" })
  volume_tags = merge(local.app_vars.locals.tags, { "map-migrated" = "d-server-01qk53073ldk8w" })


  create_security_group_inline = false
  vpc_security_group_ids = [
    "sg-0a87a2d0ea87c8da6",
    "sg-0d503fcccfa42b530",
    "sg-0ff6ad4b93fda5753"
  ]

  sg_ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = ["10.0.0.0/8"]
    },
    {
      from_port   = 1521
      to_port     = 1521
      protocol    = "TCP"
      cidr_blocks = ["10.197.28.21/32"]
    }
  ]
  sg_egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}