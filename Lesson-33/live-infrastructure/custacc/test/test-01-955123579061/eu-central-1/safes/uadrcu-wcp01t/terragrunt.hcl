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
  name         = basename(get_terragrunt_dir())
  #  name = "uadrcu-wcp01t"
}

inputs = {
  ebs_optimized        = false
  create_iam_role_ssm  = false
  iam_instance_profile = "AmazonSSMRoleForInstancesQuickSetup"
  ami                  = "ami-069b530cb44de4bc3"
  instance_type        = "t2.medium"
  key_name             = "custaccadmins"
  name                 = local.name
  subnet_id            = dependency.vpc.outputs.app_subnets.ids[1]

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


  tags = merge(local.app_vars.locals.tags, {
    "map-migrated"       = "d-server-02f28zdzlpcm5d"
    "Maintenance Window" = "sun2",
    "Patch Group"        = "WinServers",
    "asm-patch"          = "yes",
    #    Backup = "Daily-3day-Retention" 
    }
  )
  volume_tags = merge(local.app_vars.locals.tags, { "map-migrated" = "d-server-02f28zdzlpcm5d" })


  create_security_group_inline = false
  vpc_security_group_ids = [
    "sg-0dcf7add9097598c3",
    "sg-03e74f03ae95f471e"
  ]

  sg_ingress_rules = [
    {
      from_port   = 3389
      to_port     = 3389
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