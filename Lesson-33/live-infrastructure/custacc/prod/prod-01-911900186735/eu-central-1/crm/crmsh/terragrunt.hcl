# IT Customers and Account Services Delivery IMPORT
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
  # source = find_in_parent_folders("../../localmodules/ua-tf-aws-payments-host")
  #  source = include.locals.account_vars.locals.sources["host"]
  #   source = find_in_parent_folders("../../modules/host")

}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))

  name = basename(get_terragrunt_dir())
}

inputs = {
  vpc                  = include.locals.account_vars.locals.vpc
  domain               = include.locals.account_vars.locals.domain
  name                 = local.name
  ami                  = "ami-039ce10363c032202"
  type                 = "t3.micro"
  subnet               = "*-InternalA"
  zone                 = "eu-central-1a"
  ssh-key              = "custaccprodadmins"
  iam_instance_profile = "ssm-ec2-role"
  ebs_optimized        = false
  #  root_block_device = [
  #    {
  #      delete_on_termination = false
  #      device_name           = "/dev/sda1"
  #      volume_size = "100"
  #      volume_type = "gp3"
  ##      tags                  = {local.common_tags.locals}
  #    }
  #  ]
  #
  #      ebs_block_device = [ {
  #          delete_on_termination = false
  #          device_name           = "/dev/sdf"
  #          snapshot_id           = "snap-0cc56c53057a3442a"
  ##          volume_id             = "vol-0156c919a9c92987e"
  #          volume_size           = 250
  #          volume_type           = "gp3"
  #
  ##          tags                  = {local.common_tags.locals}
  #        }
  #      , {
  ##          tags                  = {local.common_tags.locals}
  #          delete_on_termination = false
  #          device_name           = "/dev/sdg"
  #          snapshot_id           = "snap-086585d9988c8319b"
  ##          volume_id             = "vol-0de04da32e49be197"
  #          volume_size           = 250
  #          volume_type           = "gp3"
  #        }
  #      , {
  ##          tags                  = {local.common_tags.locals}
  #          delete_on_termination = false
  #          device_name           = "/dev/sdh"
  #          snapshot_id           = "snap-04ce150b25e9ec9c1"
  ##          volume_id             = "vol-05659f15c82508442"
  #          volume_size           = 250
  #          volume_type           = "gp3"
  #        }
  #      , {
  #          delete_on_termination = false
  #          device_name           = "/dev/sdi"
  #          snapshot_id           = "snap-0414fcbf23ded1fc3"
  ##          volume_id             = "vol-096c62606fc16233c"
  #          volume_size           = 250
  #          volume_type           = "gp3"
  ##          tags                  = {local.common_tags.locals}
  #        }
  #]

  #  security_groups = ["zabbix-agent"]
  tags = merge(local.app_vars.locals.tags, {
    map-migrated         = "d-server-02ectegmof5ib6",
    Backup               = "Daily-3day-Retention",
    "Maintenance Window" = "sun2",
    "Patch Group"        = "WinServers",
    "asm-patch"          = "yes"
    }
  )
  ingress = [
    #    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH" },
    { from_port : 3389, to_port : 3389, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "RDP" },
  ]
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["10.0.0.0/8"], description : "ALL OUT" },
  ]
}
