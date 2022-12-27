dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

dependency "s3" {
  config_path = find_in_parent_folders("s3/lb-access-log")

  mock_outputs = {
    s3_bucket_id = "temporary-id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependencies {
  paths = [
    find_in_parent_folders("vpc-info"),
    find_in_parent_folders("s3/lb-access-log"),
  ]
}

terraform {
  source = local.account_vars.sources_lb
}

locals {
  name         = "${lower(local.tags_map.System)}-${local.tags_map.env}-${basename(get_terragrunt_dir())}"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  app_port     = local.account_vars.default_app_port
  tags         = merge(local.tags_map, { map-migrated = local.account_vars.tag_map_migrated_otp })
  targets_otp  = local.account_vars.lb_targets_otp
  targets_sms  = local.account_vars.lb_targets_sms
  targets_auth = local.account_vars.lb_targets_auth
  targets_db_main    = local.account_vars.lb_targets_db_main
  targets_db_archive = local.account_vars.lb_targets_db_archive
}

inputs = {
  name = local.name

  load_balancer_type = "network"

  vpc_id          = dependency.vpc.outputs.vpc_id.id
  subnets         = dependency.vpc.outputs.lb_subnets.ids
  internal        = true
  enable_cross_zone_load_balancing = true

  access_logs = {
    bucket = dependency.s3.outputs.s3_bucket_id
  }

  ### Start Listeners

  http_tcp_listeners = [
    { # listener_index 0 - Auth
      port               = 443
      protocol           = "TCP"
      target_group_index = 0
    },
    { # listener_index 1
      port               = 8443
      protocol           = "TCP"
      target_group_index = 1
    },
    { # listener_index 2
      port               = 9443
      protocol           = "TCP"
      target_group_index = 2
    },
    { # listener_index 3
      port               = 1575
      protocol           = "TCP"
      target_group_index = 3
    },
    { # listener_index 4
      port               = 1576
      protocol           = "TCP"
      target_group_index = 4
    },
    { # listener_index 5
      port               = 1521
      protocol           = "TCP"
      target_group_index = 5
    },
    { # listener_index 6
      port               = 1522
      protocol           = "TCP"
      target_group_index = 6
    },
  ]

  ### End Listeners

  ### Start Target groups

  target_groups = [
    { # TG index 0
      name               = "${local.name}-auth"
      backend_protocol   = "TCP"
      backend_port       = local.app_port
      target_type        = "instance"
      preserve_client_ip = true
      stickiness = {
        enabled         = false
        type            = "source_ip"
        cookie_duration = 3600
      }
      targets = local.targets_auth
    },
    { # TG index 1
      name               = "${local.name}-otp"
      backend_protocol   = "TCP"
      backend_port       = local.app_port
      target_type        = "instance"
      preserve_client_ip = true
      stickiness = {
        type            = "source_ip"
        cookie_duration = 3600
      }
      targets = local.targets_otp
    },
    { # TG index 2
      name               = "${local.name}-sms"
      backend_protocol   = "TCP"
      backend_port       = local.app_port
      target_type        = "instance"
      preserve_client_ip = true
      stickiness = {
        type            = "source_ip"
        cookie_duration = 3600
      }
      targets = local.targets_sms
    },
    { # TG index 3
      name               = "${local.name}-db-main"
      backend_protocol   = "TCP"
      backend_port       = 1575
      target_type        = "ip"
      preserve_client_ip = false
      stickiness = {
        type            = "source_ip"
        cookie_duration = 3600
      }
      targets = local.targets_db_main
    },
    { # TG index 4
      name               = "${local.name}-db-archive"
      backend_protocol   = "TCP"
      backend_port       = 1575
      target_type        = "ip"
      preserve_client_ip = false
      stickiness = {
        type            = "source_ip"
        cookie_duration = 3600
      }
      targets = local.targets_db_archive
    },
    { # TG index 5
      name               = "${local.name}-db-plain"
      backend_protocol   = "TCP"
      backend_port       = 1521
      target_type        = "ip"
      preserve_client_ip = false
      stickiness = {
        type            = "source_ip"
        cookie_duration = 3600
      }
      targets = local.targets_db_main
    },
    { # TG index 6
      name               = "${local.name}-db-arch-pl"
      backend_protocol   = "TCP"
      backend_port       = 1521
      target_type        = "ip"
      preserve_client_ip = false
      stickiness = {
        type            = "source_ip"
        cookie_duration = 3600
      }
      targets = local.targets_db_archive
    },
  ]

  ### End Target groups

  tags = local.tags
}
