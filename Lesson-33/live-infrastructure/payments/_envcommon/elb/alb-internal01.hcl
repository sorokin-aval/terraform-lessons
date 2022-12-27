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

dependency "sg" {
  config_path = find_in_parent_folders("sg")

  mock_outputs = {
    security_group_id = "temporary-id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependencies {
  paths = [
    find_in_parent_folders("core-infrastructure/vpc-info"),
    find_in_parent_folders("s3-access-log"),
    find_in_parent_folders("sg"),
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
  name = basename(dirname(find_in_parent_folders("alb")))

  load_balancer_type = "application"

  vpc_id          = dependency.vpc.outputs.vpc_id.id
  subnets         = dependency.vpc.outputs.lb_subnets.ids
  security_groups = ["${dependency.sg.outputs.security_group_id}"]
  internal        = true
  idle_timeout    = 120

  access_logs = {
    bucket = dependency.s3.outputs.s3_bucket_id
  }

  ### START Listeners ###

  https_listeners = [
    {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = local.account_vars.locals.default_alb_certificate
      action_type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "alb is ok"
        status_code  = "200"
      }
    },
    {
      port            = 9443
      protocol        = "HTTPS"
      certificate_arn = local.account_vars.locals.default_alb_certificate
      action_type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "alb is ok"
        status_code  = "200"
      }
    },
    {
      port            = 9043
      protocol        = "HTTPS"
      certificate_arn = local.account_vars.locals.default_alb_certificate
      action_type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "alb is ok"
        status_code  = "200"
      }
    },
    {
      port            = 8443
      protocol        = "HTTPS"
      certificate_arn = local.account_vars.locals.default_alb_certificate
      action_type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "alb is ok"
        status_code  = "200"
      }
    },
    {
      port            = 8445
      protocol        = "HTTPS"
      certificate_arn = local.account_vars.locals.default_alb_certificate
      action_type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "alb is ok"
        status_code  = "200"
      }
    },
    {
      port            = 8447
      protocol        = "HTTPS"
      certificate_arn = local.account_vars.locals.default_alb_certificate
      action_type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "alb is ok"
        status_code  = "200"
      }
    },
    {
      port            = 9081
      protocol        = "HTTPS"
      certificate_arn = local.account_vars.locals.default_alb_certificate
      action_type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "alb is ok"
        status_code  = "200"
      }
    },
  ]

  tags = merge(
    local.account_vars.locals.tags,
    local.domain_vars.locals.common_tags,
    { map-migrated = "d-server-020b2954batpyz" }
  )
}
