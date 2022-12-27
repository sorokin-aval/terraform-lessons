terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//ec2?ref=main"
}

dependency "vpc" {
  config_path = "../../../core-infrastructure/baseline/"
}

locals {
  common_tags  = read_terragrunt_config("tags.hcl")
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map = local.common_tags.locals
  name = "jboss1-aws-terraform.app.kv.aval"
}

inputs = {
    name  = local.name
    ami           = "ami-0e7686202b614940c" 
    instance_type = "r5.large"
    subnet_id     = dependency.vpc.outputs.app_subnets.ids[0]
    key_name = dependency.vpc.outputs.ssh_key_ids[0]
    tags = local.tags_map
    volume_tags = local.tags_map

    sg_ingress_rules = [
        {
            from_port   = 0
            to_port     = 0
            protocol    = "ICMP"
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
}