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

dependency "pte" {
  config_path = find_in_parent_folders("pte/db01.pte")
}

dependency "db01-norkom" {
  config_path = find_in_parent_folders("norkom/db01.norkom")
}

dependency "db02-norkom" {
  config_path = find_in_parent_folders("norkom/db02.norkom")
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

dependency "db01-tm" {
  config_path = find_in_parent_folders("tm/db01.tm")
}

dependency "db02-tm" {
  config_path = find_in_parent_folders("tm/db02.tm")
}

dependency "vpos" {
  config_path = find_in_parent_folders("pte/db01.vpos")
}

dependencies {
  paths = [
    find_in_parent_folders("core-infrastructure/vpc-info"),
    find_in_parent_folders("s3-access-log"),
    find_in_parent_folders("pte/db01.pte"),
    find_in_parent_folders("pte/db01.vpos"),
    find_in_parent_folders("norkom/db01.norkom"),
    find_in_parent_folders("norkom/db02.norkom"),
    find_in_parent_folders("is-card/db01.is-card"),
    find_in_parent_folders("is-card/db02.is-card"),
    find_in_parent_folders("tm/db01.tm"),
    find_in_parent_folders("tm/db02.tm"),
  ]
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git//?ref=v6.8.0"
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
    { # PTE - index 0
      port               = 15200
      protocol           = "TCP"
      target_group_index = 0
    },
    { # PTE - index 1
      port               = 15700
      protocol           = "TCP"
      target_group_index = 1
    },
    { # Norkom - index 2
      port               = 15201
      protocol           = "TCP"
      target_group_index = 2
    },
    { # Norkom - index 3
      port               = 15701
      protocol           = "TCP"
      target_group_index = 3
    },
    { # IS-Card - index 4
      port               = 15202
      protocol           = "TCP"
      target_group_index = 4
    },
    { # IS-Card - index 5
      port               = 15702
      protocol           = "TCP"
      target_group_index = 5
    },
    { # TM - index 6
      port               = 15203
      protocol           = "TCP"
      target_group_index = 6
    },
    { # TM - index 7
      port               = 15703
      protocol           = "TCP"
      target_group_index = 7
    },
    { # VPOS - index 8
      port               = 15204
      protocol           = "TCP"
      target_group_index = 8
    },
    { # VPOS - index 9
      port               = 15704
      protocol           = "TCP"
      target_group_index = 9
    },
    { # ODICARD - index 10
      port               = 20910
      protocol           = "TCP"
      target_group_index = 10
    },
  ]

  target_groups = [
    { # PTE - index 0
      name_prefix      = "pte-"
      backend_protocol = "TCP"
      backend_port     = 1521
      target_type      = "instance"
      targets = [
        { target_id : dependency.pte.outputs.ec2_id, port : 1521 },
      ]
    },
    { # PTE - index 1
      name_prefix      = "pte-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.pte.outputs.ec2_id, port : 1575 },
      ]
    },
    { # Norkom - index 2
      name_prefix      = "nrk-"
      backend_protocol = "TCP"
      backend_port     = 1522
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-norkom.outputs.ec2_id, port : 1522 },
        { target_id : dependency.db02-norkom.outputs.ec2_id, port : 1522 },
      ]
    },
    { # Norkom - index 3
      name_prefix      = "nrk-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-norkom.outputs.ec2_id, port : 1575 },
        { target_id : dependency.db02-norkom.outputs.ec2_id, port : 1575 },
      ]
    },
    { # IS-Card - index 4
      name_prefix      = "isc-"
      backend_protocol = "TCP"
      backend_port     = 1522
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-is-card.outputs.ec2_id, port : 1522 },
        { target_id : dependency.db02-is-card.outputs.ec2_id, port : 1522 },
        { target_id : dependency.db03-is-card.outputs.ec2_id, port : 1522 },
      ]
    },
    { # IS-Card - index 5
      name_prefix      = "isc-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-is-card.outputs.ec2_id, port : 1575 },
        { target_id : dependency.db02-is-card.outputs.ec2_id, port : 1575 },
        { target_id : dependency.db03-is-card.outputs.ec2_id, port : 1575 },
      ]
    },
    { # TM - index 6
      name_prefix      = "tm-"
      backend_protocol = "TCP"
      backend_port     = 1522
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-tm.outputs.ec2_id, port : 1522 },
        { target_id : dependency.db02-tm.outputs.ec2_id, port : 1522 },
      ]
    },
    { # TM - index 7
      name_prefix      = "tm-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-tm.outputs.ec2_id, port : 1575 },
        { target_id : dependency.db02-tm.outputs.ec2_id, port : 1575 },
      ]
    },
    { # VPOS - index 8
      name_prefix      = "vpos-"
      backend_protocol = "TCP"
      backend_port     = 1521
      target_type      = "instance"
      targets = [
        { target_id : dependency.vpos.outputs.ec2_id, port : 1521 },
      ]
    },
    { # VPOS - index 9
      name_prefix      = "vpos-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.vpos.outputs.ec2_id, port : 1575 },
      ]
    },
    { # ODICARD - index 10
      name_prefix      = "odic-"
      backend_protocol = "TCP"
      backend_port     = 20910
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-is-card.outputs.ec2_id, port : 20910 },
        { target_id : dependency.db02-is-card.outputs.ec2_id, port : 20910 },
        { target_id : dependency.db03-is-card.outputs.ec2_id, port : 20910 },
      ]
    },
  ]

  tags = merge(
    local.account_vars.locals.tags,
    local.domain_vars.locals.common_tags,
    { map-migrated = "d-server-01bgl4aumr8kuo" }
  )

}
