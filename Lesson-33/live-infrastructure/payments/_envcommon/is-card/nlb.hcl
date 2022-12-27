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

dependency "db01-is-card" {
  config_path = find_in_parent_folders("is-card/db01.is-card")
}

dependency "db02-is-card" {
  config_path = find_in_parent_folders("is-card/db02.is-card")
}

dependency "db03-is-card" {
  config_path = find_in_parent_folders("is-card/db03.is-card")
}

dependencies {
  paths = [
    find_in_parent_folders("core-infrastructure/vpc-info"),
    find_in_parent_folders("s3-access-log"),
    find_in_parent_folders("is-card/db01.is-card"),
  ]
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git//?ref=v6.8.0"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
}

inputs = {
  name = basename(dirname(find_in_parent_folders("nlb")))

  load_balancer_type = "network"

  vpc_id   = dependency.vpc.outputs.vpc_id.id
  subnets  = dependency.vpc.outputs.lb_subnets.ids
  internal = true

  enable_cross_zone_load_balancing = true

  access_logs = {
    bucket = dependency.s3.outputs.s3_bucket_id
  }

  http_tcp_listeners = [
    { # IS-Card - index 0
      port               = 1521
      protocol           = "TCP"
      target_group_index = 0
    },
    { # IS-Card - index 1
      port               = 1575
      protocol           = "TCP"
      target_group_index = 1
    },
  ]

  target_groups = [
    { # IS-Card - index 6
      name             = "transit-db-is-card-1522"
      backend_protocol = "TCP"
      backend_port     = 1522
      target_type      = "instance"
      targets          = [{ target_id : dependency.db01-is-card.outputs.ec2_id, port : 1522 }, { target_id : dependency.db02-is-card.outputs.ec2_id, port : 1522 }, { target_id : dependency.db03-is-card.outputs.ec2_id, port : 1522 }]
    },
    { # IS-Card - index 7
      name             = "transit-db-is-card-1575"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets          = [{ target_id : dependency.db01-is-card.outputs.ec2_id, port : 1575 }, { target_id : dependency.db02-is-card.outputs.ec2_id, port : 1575 }, { target_id : dependency.db03-is-card.outputs.ec2_id, port : 1575 }]
    },
  ]

  tags = merge(local.app_vars.locals.tags, { map-migrated = "d-server-01bgl4aumr8kuo" })
}
