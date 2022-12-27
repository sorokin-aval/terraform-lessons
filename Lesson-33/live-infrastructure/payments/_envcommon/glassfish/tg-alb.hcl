dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }
dependency "alb" { config_path = find_in_parent_folders("alb-internal/alb") }
dependency "acm" { config_path = find_in_parent_folders("acm") }

terraform {
  source = local.account_vars.locals.sources["target-group"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
}

inputs = {
  load_balancer_arn = dependency.alb.outputs.lb_arn
  vpc_id = dependency.vpc.outputs.vpc_id.id

  target_groups = {
    "9100" = {
      listener_port   = 9100
      name_prefix     = "slb-"
      target_port     = 9100
      protocol        = "HTTP"
      stickiness = {
        enabled = true
      }
      health_check = {
        path     = "/"
        protocol = "HTTP"
        matcher  = "200-299"
      }
      listener_rule = {
        host_header = ["slb.${local.app_vars.locals.name}.${local.account_vars.locals.domain}"]
      }
    },
    "9200" = {
      listener_port   = 9200
      name_prefix     = "slb-"
      target_port     = 9200
      protocol        = "HTTP"
      stickiness = {
        enabled = true
      }
      health_check = {
        path     = "/"
        protocol = "HTTP"
        matcher  = "200-299"
      }
      listener_rule = {
        host_header = ["slb.${local.app_vars.locals.name}.${local.account_vars.locals.domain}"]
      }
    },
    "9300" = {
      listener_port   = 9300
      name_prefix     = "slb-"
      target_port     = 9300
      protocol        = "HTTP"
      stickiness = {
        enabled = true
      }
      health_check = {
        path     = "/"
        protocol = "HTTP"
        matcher  = "200-299"
      }
      listener_rule = {
        host_header = ["slb.${local.app_vars.locals.name}.${local.account_vars.locals.domain}"]
      }
    },
    "9400" = {
      listener_port   = 9400
      name_prefix     = "slb-"
      target_port     = 9400
      protocol        = "HTTP"
      stickiness = {
        enabled = true
      }
      health_check = {
        path     = "/"
        protocol = "HTTP"
        matcher  = "200-299"
      }
      listener_rule = {
        host_header = ["slb.${local.app_vars.locals.name}.${local.account_vars.locals.domain}"]
      }
    },
    "9500" = {
      listener_port   = 9500
      name_prefix     = "slb-"
      target_port     = 9500
      protocol        = "HTTP"
      stickiness = {
        enabled = true
      }
      health_check = {
        path     = "/"
        protocol = "HTTP"
        matcher  = "200-299"
      }
      listener_rule = {
        host_header = ["slb.${local.app_vars.locals.name}.${local.account_vars.locals.domain}"]
      }
    },
    "8777" = {
      listener_port   = 8777
      name_prefix     = "slb-"
      target_port     = 8777
      protocol        = "HTTP"
      stickiness = {
        enabled = true
      }
      health_check = {
        path     = "/"
        protocol = "HTTP"
        matcher  = "200-299"
      }
      listener_rule = {
        host_header = ["slb.${local.app_vars.locals.name}.${local.account_vars.locals.domain}"]
      }
    },
  }
}
