dependency "ssm-vpc-endpoint" {
  config_path = find_in_parent_folders("core-infrastructure/sg/ssm-vpc-endpoint")
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

dependency "cv-role" {
  config_path = find_in_parent_folders("iam/role")
}

terraform {
  source = local.account_vars.locals.sources["host"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  domain_vars  = read_terragrunt_config(find_in_parent_folders("domain.hcl"))
  name         = "${basename(get_terragrunt_dir())}-${substr(local.account_vars.locals.aws_account_id, -6, -1)}"
}

inputs = {
  vpc                  = local.account_vars.locals.vpc
  domain               = local.account_vars.locals.domain
  name                 = local.name
  ami                  = "ami-09439f09c55136ecf"
  type                 = try(local.account_vars.locals.ec2_types[basename(get_terragrunt_dir())], "")
  subnet               = "*RBUA_Payments_*-InternalB"
  zone                 = "eu-central-1b"
  security_groups      = ["ad", "ssh"]
  iam_instance_profile = dependency.cv-role.outputs.iam_instance_profile_name

  root_block_device = [
    {
      volume_size = "10"
      volume_type = "gp3"
      encrypted   = false
    }
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_size = "50"
      volume_type = "gp3"
    },
    {
      device_name = "/dev/sdg"
      volume_size = "100"
      volume_type = "gp3"
    }
  ]

  tags = merge(local.account_vars.locals.tags,
    local.domain_vars.locals.common_tags,
    { map-migrated = "d-server-00sj1xhbfx35r4" })

  # Security group rules
  ingress = [
    { from_port : 8400, to_port : 8400, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" },
    { from_port : 8403, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.db_subnet_cidr_blocks, description : "db_subnet_cidr_blocks" },
  ]
  egress = [
    { from_port : 443, to_port : 443, protocol : "tcp", security_groups : [dependency.ssm-vpc-endpoint.outputs.security_group_id], description : "ssm-vpc-endpoint" },
    { from_port : 8400, to_port : 8400, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" },
    { from_port : 8403, to_port : 8403, protocol : "tcp", cidr_blocks : local.account_vars.locals.ips["comm-vault"], description : "comm-vault" },
    { from_port : 8400, to_port : 8403, protocol : "tcp", cidr_blocks : dependency.vpc.outputs.db_subnet_cidr_blocks, description : "db_subnet_cidr_blocks" },
    { from_port : 443, to_port : 443, protocol : "tcp", prefix_list_ids : ["pl-6ea54007"], description : "s3-endpoint" },
  ]
}
