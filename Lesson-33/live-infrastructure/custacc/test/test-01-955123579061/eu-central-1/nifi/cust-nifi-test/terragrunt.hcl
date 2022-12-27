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
}

locals {
#  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars    = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name        = basename(get_terragrunt_dir())
}

inputs = {
  vpc             = include.locals.account_vars.locals.vpc
  domain          = include.locals.account_vars.locals.domain
  name            = local.name
#  ami_name        = local.name
#  ami_name        = "rin-web-c"
  ami             = "ami-05e8103edbe6be9c6"
  type            = "t3a.medium"
  iam_instance_profile = "nifi_ec2_to_S3"

  subnet          = "*-InternalA"
  zone            = "eu-central-1a"
#  security_groups = ["ad", "ssh", "${dependency.sg.outputs.security_group_name}", "observable"]
  ebs_optimize = false
  root_block_device = [
    {
      volume_size = "24"
      volume_type = "gp3"
      tags        = merge(local.app_vars.locals.tags, {map-migrated = "d-server-029p4vwnjv70w1", Backup = "Daily-7day-Retention"})
    }
  ]

      ebs_block_device = [ {
          delete_on_termination = true
          device_name           = "/dev/sdf"
          encrypted             = false
          iops                  = 3000
          snapshot_id           = "snap-0bf37e209e11ab23b"
#          tags                  = {local.common_tags.locals}
          throughput            = 125
          volume_id             = "vol-04df1ca851abf1996"
          volume_size           = 250
          volume_type           = "gp3"
        }
      , {
          delete_on_termination = true
          device_name           = "/dev/sdg"
          encrypted             = false
          iops                  = 3000
          snapshot_id           = "snap-0ef4ba8c8ad51d75e"
#          tags                  = {local.common_tags.locals}
          throughput            = 125
          volume_id             = "vol-0aee83e3336af1c87"
          volume_size           = 250
          volume_type           = "gp3"
        }
      , {
          delete_on_termination = true
          device_name           = "/dev/sdh"
          encrypted             = false
          iops                  = 3000
          snapshot_id           = "snap-086c11eb1c4c269a5"
#          tags                  = {local.common_tags.locals}
          throughput            = 125
          volume_id             = "vol-0d0c987455f41e726"
          volume_size           = 250
          volume_type           = "gp3"
        }
      , {
          delete_on_termination = true
          device_name           = "/dev/sdi"
          encrypted             = false
          iops                  = 3000
          snapshot_id           = "snap-011266317a5f5a2d4"
#          tags                  = {local.common_tags.locals}
          throughput            = 125
          volume_id             = "vol-0d0a58293b90cb2e7"
          volume_size           = 250
          volume_type           = "gp3"
        }
] 

#  security_groups = ["zabbix-agent"]
#  tags            = merge(local.common_tags.locals, { application_role = local.app_vars.locals.name, map-migrated = "d-server-02ou594b5lcpe5" })
  tags            = merge(local.app_vars.locals.tags, {map-migrated = "d-server-029p4vwnjv70w1", Backup = "Daily-3day-Retention"})

  ingress = [
    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH" },
    { from_port : 9443, to_port : 9443, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "NiFi" },
  ]
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["10.0.0.0/8"], description : "ALL OUT" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "HTTPS2SSM OUT" },
  ]
}
