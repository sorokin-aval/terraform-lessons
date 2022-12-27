include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//ec2?ref=ec2_v0.0.2"
}

dependency "vpc" {
  config_path = "../core-infrastructure/baseline/"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  name         = basename(get_terragrunt_dir())
}

inputs = {
  #Set Image ID for your server here
  ami           = "ami-075a19ab0b7fc6267"

  #Set instance type for your server here
  instance_type = "t3a.medium"

  ebs_optimized = true
  #Rules to allow access to server. In this example allowed access on port 8080 because application open this port
  sg_ingress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "TCP"
      cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
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
  name          = local.name
  subnet_id     = dependency.vpc.outputs.app_subnets.ids[0]
  key_name      = "platformOps"
  tags          = merge(local.common_tags.locals, {
//    custom_tag = "custom value",
//    map-migrated="d-server-03t7qcw7449se4"
  })
}
