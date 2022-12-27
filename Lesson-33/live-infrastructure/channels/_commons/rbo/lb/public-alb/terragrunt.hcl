dependency "vpc" { config_path = find_in_parent_folders("vpc-info") }

dependency "s3" {
  config_path = find_in_parent_folders("s3/lb-access-log")

  mock_outputs = {
    s3_bucket_id = "temporary-id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "sg" {
  config_path = find_in_parent_folders("sg/alb-public")

  mock_outputs = {
    security_group_id = "temporary-id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

terraform { source = local.account_vars.sources_lb }

iam_role = local.account_vars.iam_role

locals {
  name          = "${lower(local.tags_map.System)}-${local.tags_map.env}-${basename(get_terragrunt_dir())}"
  lb_name       = "public"
  tags_map      = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  app_port      = local.account_vars.default_app_port
  tags          = merge(local.tags_map, { map-migrated = local.account_vars.tag_map_migrated_front, ccoe-inet-in-name = local.account_vars.lb_public_tag_value })
  targets_front = local.account_vars.lb_targets_front
}

inputs = {
  name = local.lb_name

  load_balancer_type = "application"

  vpc_id          = dependency.vpc.outputs.vpc_id.id
  subnets         = dependency.vpc.outputs.public_subnets.ids
  security_groups = ["${dependency.sg.outputs.security_group_id}"]
  internal        = false

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
      priority             = 100
      actions = [{
        type               = "forward"
        target_group_index = 0
      }]
      conditions = [
        {
          host_headers = local.account_vars.lb_front_host_headers
        },
      ]
    },
    {
      https_listener_index = 0
      priority             = 200
      actions = [{
        type = "redirect"
        host = local.account_vars.public_domain
        status_code = "HTTP_302"
      }]
      conditions = [
        {
          host_headers = [ local.account_vars.aval_public_domain ]
        },
      ]
    },
  ]

  ### End Listeners

  ### Start Target groups

  target_groups = [
    # index 0
    {
      name             = substr("${local.name}-front",0,32)
      backend_protocol = "HTTPS"
      backend_port     = local.app_port
      target_type      = "instance"
      stickiness = {
        type            = "lb_cookie"
        cookie_duration = 3600
        cookie_name     = "JSESSIONID"  # is not used, but keep it here to prevent unappliable diff
      }
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/ibank/version.txt"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 6
        protocol            = "HTTPS"
        matcher             = "200"
      }
      targets = local.targets_front
    },
  ]

  ### End Target groups

  tags = local.tags
}
