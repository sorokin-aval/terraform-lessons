dependency "vpc" { config_path = find_in_parent_folders("vpc-info") }

dependency "s3" {
  config_path = find_in_parent_folders("s3/lb-access-log")

  mock_outputs = {
    s3_bucket_id = "temporary-id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

terraform {
  source = local.account_vars.sources_lb
}

iam_role = local.account_vars.iam_role

locals {
  name            = "${lower(local.tags_map.System)}-${local.tags_map.env}-${basename(get_terragrunt_dir())}"
  tags_map        = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars    = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  app_port        = local.account_vars.default_app_port
  db_plain_port   = local.account_vars.db_plain_backend_port
  tags            = merge(local.tags_map, { map-migrated = local.account_vars.tag_map_migrated_is-front })
  targets_is      = local.account_vars.lb_targets_is-front
  targets_auth    = local.account_vars.lb_targets_auth
  targets_db_main = local.account_vars.lb_targets_db_main
  targets_aopis   = local.account_vars.lb_targets_adm
}

inputs = {
  name = local.name

  load_balancer_type = "network"

  vpc_id          = dependency.vpc.outputs.vpc_id.id
  subnets         = dependency.vpc.outputs.app_subnets.ids
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
    { # listener_index 1 - IS
      port               = 8443
      protocol           = "TCP"
      target_group_index = 1
    },
    { # listener_index 2 - DB SSL
      port               = 1575
      protocol           = "TCP"
      target_group_index = 2
    },
    { # listener_index 3 - DB Plain
      port               = 1521
      protocol           = "TCP"
      target_group_index = 3
    },
    { # listener_index 1 - AOPIS
      port               = 9443
      protocol           = "TCP"
      target_group_index = 4
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
      name               = "${local.name}-is"
      backend_protocol   = "TCP"
      backend_port       = local.app_port
      target_type        = "instance"
      preserve_client_ip = true
      stickiness = {
        enabled         = false
        type            = "source_ip"
        cookie_duration = 3600
      }
      targets = local.targets_is
    },
    { # TG index 2
      name               = "${local.name}-db-main"
      backend_protocol   = "TCP"
      backend_port       = 1575
      target_type        = "ip"
      preserve_client_ip = true
      stickiness = {
        enabled         = false
        type            = "source_ip"
        cookie_duration = 3600
      }
      targets = local.targets_db_main
    },
    { # TG index 3
      name               = format("%.32s", "${local.name}-db-plain")
      backend_protocol   = "TCP"
      backend_port       = local.db_plain_port
      target_type        = "ip"
      preserve_client_ip = true
      stickiness = {
        enabled         = false
        type            = "source_ip"
        cookie_duration = 3600
      }
      health_check = {
        protocol = "TCP"
        port     = "traffic-port"
      }
      targets = local.targets_db_main
    },
    { # TG index 4
      name               = "${local.name}-aopis"
      backend_protocol   = "TCP"
      backend_port       = 8082
      target_type        = "instance"
      preserve_client_ip = true
      stickiness = {
        enabled         = false
        type            = "source_ip"
        cookie_duration = 3600
      }
      targets = local.targets_aopis
    },
  ]

  ### End Target groups

  tags = local.tags
}
