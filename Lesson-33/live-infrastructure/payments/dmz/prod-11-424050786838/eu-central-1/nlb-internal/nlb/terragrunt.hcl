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

dependency "db01-fasttack" { config_path = find_in_parent_folders("fasttack/db01.fasttack") }
dependency "db02-fasttack" { config_path = find_in_parent_folders("fasttack/db02.fasttack") }
dependency "db01-mbanking" { config_path = find_in_parent_folders("mbanking/db01.mbanking") }
dependency "db02-mbanking" { config_path = find_in_parent_folders("mbanking/db02.mbanking") }

dependencies {
  paths = [
    find_in_parent_folders("core-infrastructure/vpc-info"),
    find_in_parent_folders("s3-access-log"),
    find_in_parent_folders("fasttack/db01.fasttack"),
    find_in_parent_folders("fasttack/db02.fasttack"),
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
    { # FASTTACK - index 0
      port               = 15200
      protocol           = "TCP"
      target_group_index = 0
    },
    { # FASTTACK - index 1
      port               = 15700
      protocol           = "TCP"
      target_group_index = 1
    },
    { # MBanking - index 2
      port               = 15201
      protocol           = "TCP"
      target_group_index = 2
    },
    { # MBanking - index 3
      port               = 15701
      protocol           = "TCP"
      target_group_index = 3
    },
  ]

  target_groups = [
    { # FASTTACK - index 0
      name_prefix      = "fst-"
      backend_protocol = "TCP"
      backend_port     = 1522
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-fasttack.outputs.ec2_id, port : 1522 },
        { target_id : dependency.db02-fasttack.outputs.ec2_id, port : 1522 },
      ]
    },
    { # FASTTACK - index 1
      name_prefix      = "fst-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-fasttack.outputs.ec2_id, port : 1575 },
        { target_id : dependency.db02-fasttack.outputs.ec2_id, port : 1575 },
      ]
    },
    { # MBanking - index 2
      name_prefix      = "mb-"
      backend_protocol = "TCP"
      backend_port     = 1522
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-mbanking.outputs.ec2_id, port : 1522 },
        { target_id : dependency.db02-mbanking.outputs.ec2_id, port : 1522 },
      ]
    },
    { # MBanking - index 3
      name_prefix      = "mb-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-mbanking.outputs.ec2_id, port : 1575 },
        { target_id : dependency.db02-mbanking.outputs.ec2_id, port : 1575 },
      ]
    },
  ]

  tags = merge(
    local.account_vars.locals.tags,
    local.domain_vars.locals.common_tags,
    { map-migrated = "" }
  )

}
