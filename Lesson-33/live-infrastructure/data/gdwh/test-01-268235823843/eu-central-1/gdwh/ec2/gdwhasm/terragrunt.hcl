include "account" {
  path = find_in_parent_folders("account.hcl")
}

include "project_vars" {
  path   = find_in_parent_folders("project_vars.hcl")
  expose = true
}
include {
  path = find_in_parent_folders()
}
terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-platform-host.git///?ref=v2.0.3"
}

dependency "vpc" {
  config_path = "../../../core-infrastructure/imported-vpc"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map     = merge(local.project_vars.locals.project_tags, {
    map-migrated = "d-server-00c1rowo3cqxzb"
  })
  name = "${local.project_vars.locals.resource_prefix}-${basename(get_terragrunt_dir())}"

}

inputs = {
  name                         = local.name
  ami                          = "ami-026c21ddf1c985bed"
  instance_type                = "i4i.16xlarge" #"r5b.16xlarge" #"x2iedn.xlarge"
  key_name                     = "rbua-data-gdwh-test"
  availability_zone            = "eu-central-1a"
  ebs_optimized                = true
  subnet_id                    = dependency.vpc.outputs.app_subnets.ids[1]
  description                  = "The EC2 ${local.name} for ${local.tags_map.Project} team"
  create_security_group_inline = false
  monitoring                   = true
  enable_volume_tags           = false
  volume_tags                  = local.tags_map
  metadata_options             = {
    http_tokens                 = "required"
    http_put_response_hop_limit = "1"
  }
  root_block_device = [
    {
      delete_on_termination = false
      encrypted             = true
      volume_type           = "gp3"
      throughput            = 250
      iops                  = 6000
      volume_size           = 100
    }
  ]

  aws_ebs_block_device = {
    redo1 = {
      device_name           = "/dev/xvdb"
      delete_on_termination = false
      volume_size           = 700
      encrypted             = true
      volume_type           = "gp3"
      throughput            = 125
      iops                  = 3000
    },
    data1 = {
      device_name           = "/dev/xvdc"
      delete_on_termination = false
      volume_size           = 3000
      encrypted             = true
      volume_type           = "gp3"
      throughput            = 125
      iops                  = 3000
    },
    data2 = {
      device_name           = "/dev/xvdd"
      delete_on_termination = false
      volume_size           = 3000
      encrypted             = true
      volume_type           = "gp3"
      throughput            = 125
      iops                  = 3000
    },
    data3 = {
      device_name           = "/dev/xvde"
      delete_on_termination = false
      volume_size           = 3000
      encrypted             = true
      volume_type           = "gp3"
      throughput            = 125
      iops                  = 3000
    },
    data4 = {
      device_name           = "/dev/xvdf"
      delete_on_termination = false
      volume_size           = 3000
      encrypted             = true
      volume_type           = "gp3"
      throughput            = 125
      iops                  = 3000
    },
    data5 = {
      device_name           = "/dev/xvdg"
      delete_on_termination = false
      volume_size           = 3000
      encrypted             = true
      volume_type           = "gp3"
      throughput            = 125
      iops                  = 3000
    }
  }
  tags = merge(local.tags_map, { Name = local.name })
}
