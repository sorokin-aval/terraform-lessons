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
  #source = find_in_parent_folders("../../localmodules/ua-tf-aws-payments-host")
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  name         = basename(get_terragrunt_dir())
}

inputs = {
  vpc    = include.locals.account_vars.locals.vpc
  domain = include.locals.account_vars.locals.domain
  name   = local.name
  # old ami-069b530cb44de4bc3
  #   ami             = "ami-00c330be91f634e9a"
  # with ssm
  #  ami             = "ami-06ade20139490589d"
  # first from GND
  ami  = "ami-0d030edc442a8c188"
  type = "t3a.medium"

  block_device_encrypted = false
  ebs_optimized          = false

  subnet               = "*-InternalA"
  zone                 = "eu-central-1a"
  ssh-key              = "platformOps"
  iam_instance_profile = "ssm-ec2-role"

  ###  security_groups = ["zabbix-agent", "safes"]
  tags = merge(local.app_vars.locals.tags, {
    map-migrated = "d-server-02f28zdzlpcm5d",
    Backup = "Daily-3day-Retention" }
  )

  root_block_device = [
    {
      volume_size = "50"
      volume_type = "gp3"
    }
  ]


  ebs_block_device = [{
    delete_on_termination = false
    device_name           = "/dev/sdf"
    volume_size           = 50
    volume_type           = "gp3"
    },
    {
      delete_on_termination = false
      device_name           = "/dev/sdg"
      volume_size           = 50
      volume_type           = "gp3"
    }
  ]




  ingress = [
    #    { from_port : 22, to_port : 22, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "SSH" },
    { from_port : 3389, to_port : 3389, protocol : "tcp", cidr_blocks : ["10.0.0.0/8"], description : "RDP" },
    { from_port : 0, to_port : 65535, protocol : "tcp", cidr_blocks : ["10.226.129.37/32"], description : "uadrcu-wcp01t" },


  ]
  egress = [
    { from_port : 0, to_port : 0, protocol : "-1", cidr_blocks : ["10.0.0.0/8"], description : "ALL OUT" },
    { from_port : 443, to_port : 443, protocol : "tcp", cidr_blocks : ["0.0.0.0/0"], description : "HTTPS OUT" },
  ]
}
