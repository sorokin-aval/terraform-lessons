# IT Customers and Account Services Delivery
include {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

iam_role = local.account_vars.iam_role

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-host.git//?ref=v1.1.1"
  #  source = find_in_parent_folders("../../localmodules/ua-tf-aws-payments-host")
  #  source = include.locals.account_vars.locals.sources["host"]
  #  source = find_in_parent_folders("../../modules/host")
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = basename(get_terragrunt_dir())
}

inputs = {
  ebs_optimized = false
  vpc           = include.locals.account_vars.locals.vpc
  domain        = include.locals.account_vars.locals.domain
  name          = local.name
  ami           = "ami-0c6e3ed6b1dd28a39"
  type          = "t3a.xlarge"
  #  type            = "r5dn.large"
  subnet               = "*-InternalA"
  zone                 = "eu-central-1a"
  iam_instance_profile = "ssm-ec2-role"
  ssh-key              = "platformOps"
  security_groups      = ["zabbix-agent", "krdweb", "ms-share"]
  tags = merge(local.app_vars.locals.tags, {
    map-migrated  = "d-server-036kxjaaua46c0",
    Backup        = "Daily-3day-Retention",
    "Patch Group" = "WinServers"
    }
  )

  #  root_block_device = [
  #    {
  #      volume_size = "60"
  #      volume_type = "gp3"
  #    }
  #  ]


  #  ebs_block_device = [{
  #    delete_on_termination = false
  #    device_name           = "/dev/sdf"
  #    volume_size           = 100
  #    volume_type           = "gp3"
  #    },
  #    {
  #      delete_on_termination = false
  #      device_name           = "/dev/sdg"
  #      volume_size           = 200
  #      volume_type           = "gp3"
  #    }
  #  ]


  ingress = [
    { from_port : 3389, to_port : 3389, protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "RDP" },
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH" },
  ]
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["0.0.0.0/0"], description : "ALL OUT" },
  ]
}
