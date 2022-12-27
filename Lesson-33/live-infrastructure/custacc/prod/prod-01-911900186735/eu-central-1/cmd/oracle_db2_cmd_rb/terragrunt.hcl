#custacc
include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-platform-host.git//?ref=v2.1.0"
  # source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//ec2?ref=ec2_v0.0.3"
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = "ORACLE_DB2_CMD_RB"
}

inputs = {
  name = local.name
  ami  = "ami-04d9b11d0590aa21c"
  tags = merge(local.app_vars.locals.tags, {
    #    application_role = "HO-BAPP-CMD",
    map-migrated = "d-server-01wfdcn2jk11g1",
    #		Backup = "Daily-3day-Retention"
  })
  volume_tags = merge(local.app_vars.locals.tags, {
    application_role = "HO-BAPP-CMD",
    map-migrated     = "d-server-01wfdcn2jk11g1",
  })

  instance_type = "r5b.4xlarge"
  subnet_id     = dependency.vpc.outputs.db_subnets.ids[0]

  #    security_groups = ["Oracle DB","zabbix-agent","commvault-agent"]
  create_security_group_inline = false
  vpc_security_group_ids = [
    "sg-0c73602d1f759f353",
    "sg-033037f78375add37",
    "sg-0710daabd75697270",
    "sg-0fe0c149c769efe34"
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