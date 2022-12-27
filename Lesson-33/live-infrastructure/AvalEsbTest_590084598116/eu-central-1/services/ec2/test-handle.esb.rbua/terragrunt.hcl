include {
  path = find_in_parent_folders()
}

iam_role = "arn:aws:iam::${local.aws_account_id}:role/BootstrapRole"

terraform {
    source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-platform-host.git"
}

dependency "vpc" {
  config_path = "../../../core-infrastructure/baseline/"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  name         = basename(get_terragrunt_dir())
  aws_account_id = local.account_vars.locals.aws_account_id
}

inputs = {
  #Set Image ID for your server here
  ami           = "ami-05b28f6062337076b"

  #Set instance type for your server here
  instance_type = "t3a.nano"

  ebs_optimized = true
  #Rules to allow access to server. In this example allowed access on port 8080 because application open this port

  sg_ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
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
