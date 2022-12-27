include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

dependency "s3" {
  config_path = find_in_parent_folders("s3-access-log")
  mock_outputs = {
    s3_bucket_id = "temporary-id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "fasttack" {
  config_path = find_in_parent_folders("fasttack/db01.fasttack")
}

dependencies {
  paths = [
    find_in_parent_folders("core-infrastructure/vpc-info"),
    find_in_parent_folders("s3-access-log"),
    find_in_parent_folders("fasttack/db01.fasttack"),
  ]
}

terraform {
  source = local.account_vars.locals.sources["aws-alb"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  domain_vars  = read_terragrunt_config(find_in_parent_folders("domain.hcl"))
}

inputs = {
  name = basename(dirname(find_in_parent_folders("nlb")))

  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true

  vpc_id   = dependency.vpc.outputs.vpc_id.id
  subnets  = dependency.vpc.outputs.lb_subnets.ids
  internal = true

  access_logs = {
    bucket = dependency.s3.outputs.s3_bucket_id
  }

  http_tcp_listeners = [
    { # Fasttack - index 0
      port               = 15200
      protocol           = "TCP"
      target_group_index = 0
    },
    { # Fasttack - index 1
      port               = 15700
      protocol           = "TCP"
      target_group_index = 1
    },
  ]

  target_groups = [
    { # Fasttack - index 0
      name_prefix      = "fst-"
      backend_protocol = "TCP"
      backend_port     = 1521
      target_type      = "instance"
      targets = [
        { target_id : dependency.fasttack.outputs.ec2_id, port : 1521 },
      ]
    },
    { # Fasttack - index 1
      name_prefix      = "fst-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.fasttack.outputs.ec2_id, port : 1575 },
      ]
    },
  ]

  tags = merge(
    local.account_vars.locals.tags,
    local.domain_vars.locals.common_tags,
    { map-migrated = "" }
  )
}
