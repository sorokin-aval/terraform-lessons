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

dependency "db01-ptele" { config_path = find_in_parent_folders("ptele/db01.ptele") }
dependency "db02-ptele" { config_path = find_in_parent_folders("ptele/db02.ptele") }
dependency "db01-smartclearing" { config_path = find_in_parent_folders("smartclearing/db01.smartclearing") }
dependency "db02-smartclearing" { config_path = find_in_parent_folders("smartclearing/db02.smartclearing") }
dependency "db01-stp" { config_path = find_in_parent_folders("stp/db01.stp") }
dependency "db02-stp" { config_path = find_in_parent_folders("stp/db02.stp") }
dependency "db01-keeper" { config_path = find_in_parent_folders("keeper/db01.keeper") }
dependency "db02-keeper" { config_path = find_in_parent_folders("keeper/db02.keeper") }
dependency "db01-alfa" { config_path = find_in_parent_folders("alfa/db01.alfa") }
dependency "db02-alfa" { config_path = find_in_parent_folders("alfa/db02.alfa") }
dependency "db01-avtokassa" { config_path = find_in_parent_folders("avtokassa/db01.avtokassa") }
dependency "db02-avtokassa" { config_path = find_in_parent_folders("avtokassa/db02.avtokassa") }
dependency "db01-inex" { config_path = find_in_parent_folders("inex/db01.inex") }
dependency "db02-inex" { config_path = find_in_parent_folders("inex/db02.inex") }
dependency "ap01-avtokassa" { config_path = find_in_parent_folders("avtokassa/ap01.avtokassa") }
dependency "ap02-avtokassa" { config_path = find_in_parent_folders("avtokassa/ap02.avtokassa") }
dependency "db01-dd" { config_path = find_in_parent_folders("dd/db01.dd") }
dependency "db02-dd" { config_path = find_in_parent_folders("dd/db02.dd") }
dependency "db01-smartvista" { config_path = find_in_parent_folders("smartvista/db01.smartvista") }
dependency "db02-smartvista" { config_path = find_in_parent_folders("smartvista/db02.smartvista") }
dependency "db01-mpcs" { config_path = find_in_parent_folders("mpcs/db01.mpcs") }
dependency "db02-mpcs" { config_path = find_in_parent_folders("mpcs/db02.mpcs") }

dependencies {
  paths = [
    find_in_parent_folders("core-infrastructure/vpc-info"),
    find_in_parent_folders("s3-access-log"),
    find_in_parent_folders("ptele/db01.ptele"),
    find_in_parent_folders("smartclearing/db01.smartclearing"),
    find_in_parent_folders("stp/db01.stp"),
    find_in_parent_folders("keeper/db01.keeper"),
    find_in_parent_folders("keeper/db02.keeper"),
    find_in_parent_folders("alfa/db01.alfa"),
    find_in_parent_folders("alfa/db02.alfa"),
    find_in_parent_folders("avtokassa/db01.avtokassa"),
    find_in_parent_folders("avtokassa/db02.avtokassa"),
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
    { # Keeper - index 6
      port               = 1440
      protocol           = "TCP"
      target_group_index = 6
    },
    { # Keeper - index 7
      port               = 1434
      protocol           = "UDP"
      target_group_index = 7
    },
    { # Alfa - index 8
      port               = 15203
      protocol           = "TCP"
      target_group_index = 8
    },
    { # Alfa - index 9
      port               = 15703
      protocol           = "TCP"
      target_group_index = 9
    },
    { # Avtokassa - index 10
      port               = 15204
      protocol           = "TCP"
      target_group_index = 10
    },
    { # Avtokassa - index 11
      port               = 15704
      protocol           = "TCP"
      target_group_index = 11
    },
    { # Inex - index 12
      port               = 15205
      protocol           = "TCP"
      target_group_index = 12
    },
    { # Inex - index 13
      port               = 15705
      protocol           = "TCP"
      target_group_index = 13
    },
    { # Avtokassa - index 14
      port               = 9000
      protocol           = "TCP"
      target_group_index = 14
    },
    { # DD - index 15
      port               = 15206
      protocol           = "TCP"
      target_group_index = 15
    },
    { # DD - index 16
      port               = 15706
      protocol           = "TCP"
      target_group_index = 16
    },
    { # Smartvista - index 17
      port               = 15207
      protocol           = "TCP"
      target_group_index = 17
    },
    { # Smartvista - index 18
      port               = 15707
      protocol           = "TCP"
      target_group_index = 18
    },
    { # MPСS - index 19
      port               = 15208
      protocol           = "TCP"
      target_group_index = 19
    },
    { # MPСS - index 20
      port               = 15708
      protocol           = "TCP"
      target_group_index = 20
    },
  ]

  target_groups = [
    { # PTELE - index 0
      name_prefix      = "ptele-"
      backend_protocol = "TCP"
      backend_port     = 1522
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-ptele.outputs.ec2_id, port : 1522 },
        { target_id : dependency.db02-ptele.outputs.ec2_id, port : 1522 },
      ]
    },
    { # PTELE - index 1
      name_prefix      = "ptele-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-ptele.outputs.ec2_id, port : 1575 },
        { target_id : dependency.db02-ptele.outputs.ec2_id, port : 1575 },
      ]
    },
    { # Smartclearing - index 2
      name_prefix      = "sc-"
      backend_protocol = "TCP"
      backend_port     = 1522
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-smartclearing.outputs.ec2_id, port : 1522 },
        { target_id : dependency.db02-smartclearing.outputs.ec2_id, port : 1522 },
      ]
    },
    { # Smartclearing - index 3
      name_prefix      = "sc-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-smartclearing.outputs.ec2_id, port : 1575 },
        { target_id : dependency.db02-smartclearing.outputs.ec2_id, port : 1575 },
      ]
    },
    { # STP - index 4
      name_prefix      = "stp-"
      backend_protocol = "TCP"
      backend_port     = 1522
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-stp.outputs.ec2_id, port : 1522 },
        { target_id : dependency.db02-stp.outputs.ec2_id, port : 1522 },
      ]
    },
    { # STP - index 5
      name_prefix      = "stp-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-stp.outputs.ec2_id, port : 1575 },
        { target_id : dependency.db02-stp.outputs.ec2_id, port : 1575 },
      ]
    },
    { # Keeper - index 6
      name_prefix      = "keep-"
      backend_protocol = "TCP"
      backend_port     = 1440
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-keeper.outputs.ec2_id, port : 1440 },
        #        { target_id : dependency.db02-keeper.outputs.ec2_id, port : 1440 },
      ]
    },
    { # Keeper - index 7
      name_prefix      = "keep-"
      backend_protocol = "UDP"
      backend_port     = 1434
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-keeper.outputs.ec2_id, port : 1434 },
        #        { target_id : dependency.db02-keeper.outputs.ec2_id, port : 1434 },
      ]
    },
    { # Alfa - index 8
      name_prefix      = "alfa-"
      backend_protocol = "TCP"
      backend_port     = 1522
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-alfa.outputs.ec2_id, port : 1522 },
        { target_id : dependency.db02-alfa.outputs.ec2_id, port : 1522 },
      ]
    },
    { # Alfa - index 9
      name_prefix      = "alfa-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-alfa.outputs.ec2_id, port : 1575 },
        { target_id : dependency.db02-alfa.outputs.ec2_id, port : 1575 },
      ]
    },
    { # Avtokassa - index 10
      name_prefix      = "ak-"
      backend_protocol = "TCP"
      backend_port     = 1522
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-avtokassa.outputs.ec2_id, port : 1522 },
        { target_id : dependency.db02-avtokassa.outputs.ec2_id, port : 1522 },
      ]
    },
    { # Avtokassa - index 11
      name_prefix      = "ak-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-avtokassa.outputs.ec2_id, port : 1575 },
        { target_id : dependency.db02-avtokassa.outputs.ec2_id, port : 1575 },
      ]
    },
    { # Inex - index 12
      name_prefix      = "ix-"
      backend_protocol = "TCP"
      backend_port     = 1522
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-inex.outputs.ec2_id, port : 1522 },
        { target_id : dependency.db02-inex.outputs.ec2_id, port : 1522 },
      ]
    },
    { # Inex - index 13
      name_prefix      = "ix-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-inex.outputs.ec2_id, port : 1575 },
        { target_id : dependency.db02-inex.outputs.ec2_id, port : 1575 },
      ]
    },
    { # Avtokassa - index 14
      name_prefix      = "ak-"
      backend_protocol = "TCP"
      backend_port     = 9000
      target_type      = "instance"
      targets = [
        { target_id : dependency.ap01-avtokassa.outputs.ec2_id, port : 9000 },
        { target_id : dependency.ap02-avtokassa.outputs.ec2_id, port : 9000 },
      ]
    },
    { # DD - index 15
      name_prefix      = "dd-"
      backend_protocol = "TCP"
      backend_port     = 1522
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-dd.outputs.ec2_id, port : 1522 },
        { target_id : dependency.db02-dd.outputs.ec2_id, port : 1522 },
      ]
    },
    { # DD - index 16
      name_prefix      = "dd-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-dd.outputs.ec2_id, port : 1575 },
        { target_id : dependency.db02-dd.outputs.ec2_id, port : 1575 },
      ]
    },
    { # Smartvista - index 17
      name_prefix      = "sv-"
      backend_protocol = "TCP"
      backend_port     = 1522
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-smartvista.outputs.ec2_id, port : 1522 },
        { target_id : dependency.db02-smartvista.outputs.ec2_id, port : 1522 },
      ]
    },
    { # Smartvista - index 18
      name_prefix      = "sv-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-smartvista.outputs.ec2_id, port : 1575 },
        { target_id : dependency.db02-smartvista.outputs.ec2_id, port : 1575 },
      ]
    },
    { # MPСS - index 19
      name_prefix      = "mpcs-"
      backend_protocol = "TCP"
      backend_port     = 1522
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-mpcs.outputs.ec2_id, port : 1522 },
        { target_id : dependency.db02-mpcs.outputs.ec2_id, port : 1522 },
      ]
    },
    { # MPСS - index 20
      name_prefix      = "mpcs-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        { target_id : dependency.db01-mpcs.outputs.ec2_id, port : 1575 },
        { target_id : dependency.db02-mpcs.outputs.ec2_id, port : 1575 },
      ]
    },
  ]

  tags = merge(
    local.account_vars.locals.tags,
    local.domain_vars.locals.common_tags,
    { map-migrated = "d-server-01bgl4aumr8kuo" }
  )
}
