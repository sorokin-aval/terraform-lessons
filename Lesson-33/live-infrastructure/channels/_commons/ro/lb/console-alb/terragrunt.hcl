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

dependency "sg" {
  config_path = find_in_parent_folders("sg/alb-console")

  mock_outputs = {
    security_group_id = "temporary-id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "instances" {
  config_path = find_in_parent_folders("ec2/instance/console")
}

dependencies {
  paths = [
    find_in_parent_folders("vpc-info"),
    find_in_parent_folders("s3/lb-access-log"),
    find_in_parent_folders("sg/alb-console"),
    find_in_parent_folders("ec2/instance/console")
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
  tags         = merge(local.tags_map, { map-migrated = local.account_vars.tag_map_migrated_console })
  targets      = local.account_vars.lb_targets_console
}

inputs = {
  name = local.name

  load_balancer_type = "application"

  vpc_id          = dependency.vpc.outputs.vpc_id.id
  subnets         = dependency.vpc.outputs.lb_subnets.ids
  security_groups = ["${dependency.sg.outputs.security_group_id}"]
  internal        = true

  access_logs = {
    bucket = dependency.s3.outputs.s3_bucket_id
  }

  ### Start Listeners

  https_listeners = [
    { # listener_index 0
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
      certificate_arn = local.account_vars.lb_ssl_cert_arn
      action_type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "LB is ok, however the path was not found"
        status_code  = "404"
      }
    },
  ]

  https_listener_rules = [
    {
      https_listener_index = 0
      actions = [{
        type               = "forward"
        target_group_index = 0
      }]
      conditions = [{
        path_patterns = ["/console", "/console/*"]
      }]
    },
  ]

  ### End Listeners

  ### Start Target groups

  target_groups = [
    # index 0
    {
      name             = local.name
      backend_protocol = "HTTPS"
      backend_port     = local.app_port
      target_type      = "instance"
      stickiness = {
        type            = "app_cookie"
        cookie_name     = "JSESSIONID"
        cookie_duration = 3600
      }
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/console/healthcheck.txt"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 6
        protocol            = "HTTPS"
        matcher             = "200"
      }
      targets = local.targets
    },
  ]

  ### End Target groups

  tags = local.tags
}
