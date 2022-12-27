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
    "int-443" = {
      listener_port   = 443
      name_prefix     = "fst-"
      target_port     = 13000
      protocol        = "HTTP"
      certificate_arn = dependency.acm.outputs.certificates.fasttack.arn
      stickiness = {
        enabled = true
      }
      health_check = {
        path     = "/fasttack-core/health"
        protocol = "HTTP"
        matcher  = "200-299"
      }
      listener_rule = {
        host_header = ["${local.app_vars.locals.name}.${local.account_vars.locals.domain}"]
      }
    },
    "int-445" = {
      listener_port   = 445
      name_prefix     = "fst-"
      target_port     = 13000
      protocol        = "HTTP"
      certificate_arn = dependency.acm.outputs.certificates.fasttack.arn
      stickiness = {
        enabled = true
      }
      health_check = {
        path     = "/fasttack-core/health"
        protocol = "HTTP"
        matcher  = "200-299"
      }
      listener_rule = {
        host_header = ["${local.app_vars.locals.name}.${local.account_vars.locals.domain}"]
      }
    },
  }
}
