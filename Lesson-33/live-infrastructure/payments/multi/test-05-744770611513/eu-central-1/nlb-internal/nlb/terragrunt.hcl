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

dependency "ptele" { config_path = find_in_parent_folders("ptele/db01.ptele") }
dependency "smartclearing" { config_path = find_in_parent_folders("smartclearing/db01.smartclearing") }
dependency "stp" { config_path = find_in_parent_folders("stp/db01.stp") }
dependency "keeper" { config_path = find_in_parent_folders("keeper/db01.keeper") }
dependency "avtokassa" { config_path = find_in_parent_folders("avtokassa/db01.avtokassa") }
dependency "ap01-avtokassa" { config_path = find_in_parent_folders("avtokassa/ap01.avtokassa") }
dependency "ap02-avtokassa" { config_path = find_in_parent_folders("avtokassa/ap02.avtokassa") }
dependency "inex" { config_path = find_in_parent_folders("inex/db01.inex") }
dependency "dd" { config_path = find_in_parent_folders("dd/db01.dd") }
dependency "db01-smartvista" { config_path = find_in_parent_folders("smartvista/db01.smartvista") }

dependencies {
  paths = [
    find_in_parent_folders("core-infrastructure/vpc-info"),
    find_in_parent_folders("s3-access-log"),
    find_in_parent_folders("ptele/db01.ptele"),
    find_in_parent_folders("smartclearing/db01.smartclearing"),
    find_in_parent_folders("stp/db01.stp"),
    find_in_parent_folders("keeper/db01.keeper"),
    find_in_parent_folders("avtokassa/db01.avtokassa"),
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
    { # PTELE - index 0
      port               = 15200
      protocol           = "TCP"
      target_group_index = 0
    },
    { # PTELE - index 1
      port               = 15700
      protocol           = "TCP"
      target_group_index = 1
    },
    { # Smartclearing - index 2
      port               = 15201
      protocol           = "TCP"
      target_group_index = 2
    },
    { # Smartclearing - index 3
      port               = 15701
      protocol           = "TCP"
      target_group_index = 3
    },
    { # STP - index 4
      port               = 15202
      protocol           = "TCP"
      target_group_index = 4
    },
    { # STP - index 5
      port               = 15702
      protocol           = "TCP"
      target_group_index = 5
    },
    { # keeper - index 6
      port               = 1440
      protocol           = "TCP"
      target_group_index = 6
    },
    { # keeper - index 7
      port               = 1434
      protocol           = "UDP"
      target_group_index = 7
    },
    { # avtokassa - index 8
      port               = 15204
      protocol           = "TCP"
      target_group_index = 8
    },
    { # avtokassa - index 9
      port               = 15704
      protocol           = "TCP"
      target_group_index = 9
    },
    { # Avtokassa - index 10
      port               = 9000
      protocol           = "TCP"
      target_group_index = 10
    },
    { # Inex - index 11
      port               = 15205
      protocol           = "TCP"
      target_group_index = 11
    },
    { # Inex - index 12
      port               = 15705
      protocol           = "TCP"
      target_group_index = 12
    },
    { # DD - index 13
      port               = 15206
      protocol           = "TCP"
      target_group_index = 13
    },
    { # DD - index 14
      port               = 15706
      protocol           = "TCP"
      target_group_index = 14
    },
    { # Smartvista - index 15
      port               = 15207
      protocol           = "TCP"
      target_group_index = 15
    },
    { # Smartvista - index 16
      port               = 15707
      protocol           = "TCP"
      target_group_index = 16
    }
  ]

  target_groups = [
    { # PTELE - index 0
      name_prefix      = "ptele-"
      backend_protocol = "TCP"
      backend_port     = 1521
      target_type      = "instance"
      targets = [
        { target_id : dependency.ptele.outputs.ec2_id, port : 1521 },
      ]
    },
    { # PTELE - index 1
      name_prefix      = "ptele-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.ptele.outputs.ec2_id, port : 1575 },
      ]
    },
    { # Smartclearing - index 2
      name_prefix      = "sc-"
      backend_protocol = "TCP"
      backend_port     = 1521
      target_type      = "instance"
      targets = [
        { target_id : dependency.smartclearing.outputs.ec2_id, port : 1521 },
      ]
    },
    { # Smartclearing - index 3
      name_prefix      = "sc-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.smartclearing.outputs.ec2_id, port : 1575 },
      ]
    },
    { # STP - index 4
      name_prefix      = "stp-"
      backend_protocol = "TCP"
      backend_port     = 1521
      target_type      = "instance"
      targets = [
        { target_id : dependency.stp.outputs.ec2_id, port : 1521 },
      ]
    },
    { # STP - index 5
      name_prefix      = "stp-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.stp.outputs.ec2_id, port : 1575 },
      ]
    },
    { # keeper - index 6
      name_prefix      = "keep-"
      backend_protocol = "TCP"
      backend_port     = 1440
      target_type      = "instance"
      targets = [
        { target_id : dependency.keeper.outputs.ec2_id, port : 1440 },
      ]
    },
    { # keeper - index 7
      name_prefix      = "keep-"
      backend_protocol = "UDP"
      backend_port     = 1434
      target_type      = "instance"
      health_check = {
        port     = 1440
        protocol = "TCP"
      }
      targets = [
        { target_id : dependency.keeper.outputs.ec2_id, port : 1434 },
      ]
    },
    { # avtokassa - index 8
      name_prefix      = "ak-"
      backend_protocol = "TCP"
      backend_port     = 1521
      target_type      = "instance"
      targets = [
        { target_id : dependency.avtokassa.outputs.ec2_id, port : 1521 },
      ]
    },
    { # avtokassa - index 9
      name_prefix      = "ak-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.avtokassa.outputs.ec2_id, port : 1575 },
      ]
    },
    { # Avtokassa - index 10
      name_prefix      = "ak-"
      backend_protocol = "TCP"
      backend_port     = 9000
      target_type      = "instance"
      targets = [
        { target_id : dependency.ap01-avtokassa.outputs.ec2_id, port : 9000 },
        { target_id : dependency.ap02-avtokassa.outputs.ec2_id, port : 9000 },
      ]
    },
    { # Inex - index 11
      name_prefix      = "inex-"
      backend_protocol = "TCP"
      backend_port     = 1521
      target_type      = "instance"
      targets = [
        { target_id : dependency.inex.outputs.ec2_id, port : 1521 },
      ]
    },
    { # Inex - index 12
      name_prefix      = "inex-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.inex.outputs.ec2_id, port : 1575 },
      ]
    },
    { # DD - index 13
      name_prefix      = "dd-"
      backend_protocol = "TCP"
      backend_port     = 1521
      target_type      = "instance"
      targets = [
        { target_id : dependency.dd.outputs.ec2_id, port : 1521 },
      ]
    },
    { # DD - index 14
      name_prefix      = "dd-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.dd.outputs.ec2_id, port : 1575 },
      ]
    },
    { # Smartvista - index 15
      name_prefix      = "sv-"
      backend_protocol = "TCP"
      backend_port     = 1521
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-smartvista.outputs.ec2_id, port : 1521 },
      ]
    },
    { # Smartvista - index 16
      name_prefix      = "sv-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-smartvista.outputs.ec2_id, port : 1575 },
      ]
    },
  ]

  tags = merge(
    local.account_vars.locals.tags,
    local.domain_vars.locals.common_tags,
    { map-migrated = "d-server-01bgl4aumr8kuo" }
  )
}
