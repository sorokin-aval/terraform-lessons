# IT Customers and Account Services Delivery
include {
  path   = find_in_parent_folders()
  expose = true
}

iam_role = local.account_vars.iam_role

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}


terraform {
  source = include.locals.account_vars.locals.sources["host"]
#  source = find_in_parent_folders("../../modules/host")

}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars    = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name        = basename(get_terragrunt_dir())
}

inputs = {
  vpc             = include.locals.account_vars.locals.vpc
  domain          = include.locals.account_vars.locals.domain
  name            = local.name
#  name            = "rinfo-bld"
  #  ami_name        = local.name
#  ami_name        = "nifi-clone"
  ami             = "ami-010634c6bc7cad6fa"
  type            = "t3a.medium"

  #  subnet          = "LZ-RBUA_Payments_*-InternalA"
  subnet          = "*-InternalA"
  zone            = "eu-central-1a"
  ssh-key         = "platformOps"
  #  security_groups = ["ad", "ssh", "${dependency.sg.outputs.security_group_name}", "observable"]
  #  security_groups = ["${dependency.sg.outputs.security_group_name}"]
  #   lifecycle { ignore_changes = [ebs_block_device] }
  iam_instance_profile = "ssm-ec2-role"

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
  #  tags            = merge(local.common_tags.locals, { application_role = local.app_vars.locals.name, map-migrated = "d-server-02ou594b5lcpe5" })
  tags            = merge(local.app_vars.locals.tags, {
    application_role = "HO-BAPP-RINFO-TEST",
    map-migrated = "d-server-01l1t63213j1hx",
    Backup = "Weekly-4Week-Retention"}
  )
  ingress = [
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH-IN" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "HTTPS" },
    { from_port : 8443, to_port : 8443, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "HTTPS2" },
    { from_port : 8080, to_port : 8080, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "HTTPS3" },
  ]
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["10.0.0.0/8"], description : "ALL OUT" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "HTTPS2SSM OUT" },
  ]
}
