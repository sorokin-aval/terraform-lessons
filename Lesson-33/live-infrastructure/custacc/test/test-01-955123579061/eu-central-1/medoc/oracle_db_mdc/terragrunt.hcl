#
include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

terraform {
  #  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//ec2?ref=main"
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-platform-host.git//?ref=v2.1.0"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = "ORACLE_DB_MDC"
}

inputs = {
  ebs_optimized        = true
  create_iam_role_ssm  = false
  iam_instance_profile = "AmazonSSMRoleForInstancesQuickSetup"
  ami                  = "ami-0103ce7ae5846c9b7"
  instance_type        = "r5.large"
  key_name             = "dbre"
  name                 = local.name
  subnet_id            = dependency.vpc.outputs.db_subnets.ids[0]

  #  root_block_device = [
  #    {
  #      delete_on_termination = false
  #      device_name           = "/dev/sda1"
  #      volume_size           = "100"
  #      volume_type           = "gp3"
  #    }
  #  ]
  #
  #  ebs_block_device = [{
  #    delete_on_termination = false
  #    device_name           = "/dev/sdb"
  #    volume_size           = 100
  #    volume_type           = "gp3"
  #    }
  #  ]


  tags        = merge(local.app_vars.locals.tags, { "map-migrated" = "d-server-00ew2xrboipvmt" })
  volume_tags = merge(local.app_vars.locals.tags, { "map-migrated" = "d-server-00ew2xrboipvmt" })


  create_security_group_inline = false
  vpc_security_group_ids = [
    "sg-0c0eea0891f18c939",
    "sg-0a9a27630bc83e82f"
  ]

  sg_ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["10.0.0.0/8"]
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