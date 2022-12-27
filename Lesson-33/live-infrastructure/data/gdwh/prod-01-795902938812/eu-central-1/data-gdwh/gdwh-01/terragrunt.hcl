## terragrunt.hcl
include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/global.hcl"
  expose = true
}
include {
  path = find_in_parent_folders()
}

include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true
}

terraform {
  #source = "/Users/IUADE0H5/PycharmProjects/ua-tf-aws-platform-host//"
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-platform-host.git///?ref=v2.0.3"
}


locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map     = merge(local.common_tags.locals.common_tags, { map-migrated = "d-server-024arwiimzcpcn" })
  name         = "gdwh-01.ec2.data.rbua"
  kms_key_arn  = "arn:aws:kms:eu-central-1:795902938812:key/338a01e4-c3f3-499b-bdf9-806f4cfcf6b9"
}

inputs = {
  name                    = local.name
  create                  = true
  ami                     = "ami-04d9b11d0590aa21c"
  instance_type           = "c5n.large" # "r6i.24xlarge" for load
  ebs_optimized           = true
  # subnet id will be retrieved from subnets_names_filter&availability_zone
  subnets_names_filter    = "*Internal*"
  availability_zone       = "eu-central-1b"
  #subnet_id                 = "subnet-0bb4710850b3b71eb"
  disable_api_termination = true
  key_name                = "Data_Ops_Prod"
  tags                    = local.tags_map
  volume_tags             = local.tags_map
  create_iam_role_ssm     = true
  # if hosted_zone & dns_record are set route53 record will be created
  #hosted_zone               = "test.data.rbua"
  #dns_record                = "test-instance-01.ec2"
  issue_certificate       = false
  root_block_device       = [
    {
      delete_on_termination = false
      encrypted             = true
      volume_type           = "gp3"
      throughput            = 500
      iops                  = 6000
      volume_size           = 100
    }
  ]
  aws_ebs_block_device = {
    data1 = {
      device_name = "/dev/xvdb"
      volume_type = "st1"
      iops        = null
      throughput  = null
      volume_size = 1 #10240
      encrypted   = true
      kms_key_id  = local.kms_key_arn
    }
    data2 = {
      device_name = "/dev/xvdc"
      volume_type = "st1"
      iops        = null
      throughput  = null
      volume_size = 10240
      encrypted   = true
      kms_key_id  = local.kms_key_arn
    }
    data3 = {
      device_name = "/dev/xvdd"
      volume_type = "st1"
      iops        = null
      throughput  = null
      volume_size = 10240
      encrypted   = true
      kms_key_id  = local.kms_key_arn
    }
    data4 = {
      device_name = "/dev/xvde"
      volume_type = "st1"
      iops        = null
      throughput  = null
      volume_size = 10240
      encrypted   = true
      kms_key_id  = local.kms_key_arn
    }
    data5 = {
      device_name = "/dev/xvdf"
      volume_type = "st1"
      iops        = null
      throughput  = null
      volume_size = 10240
      encrypted   = true
      kms_key_id  = local.kms_key_arn
    },
    data6 = {
      device_name = "/dev/xvdg"
      volume_type = "st1"
      iops        = null
      throughput  = null
      volume_size = 10240
      encrypted   = true
      kms_key_id  = local.kms_key_arn
    },
    data7 = {
      device_name = "/dev/xvdh"
      volume_type = "st1"
      iops        = null
      throughput  = null
      volume_size = 10240
      encrypted   = true
      kms_key_id  = local.kms_key_arn
    }
    data8 = {
      device_name = "/dev/xvdj"
      volume_type = "st1"
      iops        = null
      throughput  = null
      volume_size = 10240
      encrypted   = true
      kms_key_id  = local.kms_key_arn
    }
    redo_group_1 = {
      device_name = "/dev/xvds"
      volume_type = "gp3"
      iops        = 10000
      throughput  = 1000
      volume_size = 300
      encrypted   = true
      kms_key_id  = local.kms_key_arn
    }
    redo_group_2 = {
      device_name = "/dev/xvdt"
      volume_type = "gp3"
      iops        = 10000
      throughput  = 1000
      volume_size = 300
      encrypted   = true
      kms_key_id  = local.kms_key_arn
    }
    archive_logs_1 = {
      device_name = "/dev/xvdu"
      volume_type = "gp3"
      iops        = 6000
      throughput  = 250
      volume_size = 2000
      encrypted   = true
      kms_key_id  = local.kms_key_arn
    }
    user_share_1 = {
      device_name = "/dev/xvdv"
      volume_type = "gp3"
      iops        = 3000
      throughput  = 125
      volume_size = 250
      encrypted   = true
      kms_key_id  = local.kms_key_arn
    }
    temp = {
      device_name = "/dev/xvdw"
      volume_type = "gp3"
      iops        = 16000
      throughput  = 500
      volume_size = 200
      encrypted   = true
      kms_key_id  = local.kms_key_arn
    }
    undo = {
      device_name = "/dev/xvdx"
      volume_type = "gp3"
      iops        = 3000
      throughput  = 250
      volume_size = 500
      encrypted   = true
      kms_key_id  = local.kms_key_arn
    }
  }

  sg_ingress_rules = [
    {
      from_port   = 1521
      to_port     = 1526
      protocol    = "TCP"
      cidr_blocks = ["10.0.0.0/8"]
      description = "This rules allows oracle from hole private network. Bad practice. TBD on migration"
    },
    {
      from_port   = 1575
      to_port     = 1575
      protocol    = "TCP"
      cidr_blocks = ["10.0.0.0/8"]
      description = "This rules allows oracle from hole private network. Bad practice. TBD on migration"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      description = "SSH access from CyberArk"
      cidr_blocks = ["10.191.242.32/28"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      description = "SSH access from Linux Admins server"
      cidr_blocks = ["10.225.112.126/32"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      description = "SSH access from HO-POOL-DBA"
      cidr_blocks = ["10.190.62.128/26"]
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
