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
    "9043" = {
      listener_port   = 9043
      name_prefix     = "was-"
      target_port     = 9043
      protocol        = "HTTPS"
      certificate_arn = dependency.acm.outputs.certificates.ptele.arn
      stickiness = {
        enabled = true
      }
      health_check = {
        path     = "/ibm/console/profileSelection.jsp"
        protocol = "HTTPS"
        matcher  = "200"
      }
      listener_rule = {
        host_header = ["ap.${local.app_vars.locals.name}.${local.account_vars.locals.domain}"]
      }
    },
    "9443" = {
      listener_port   = 9443
      name_prefix     = "was-"
      target_port     = 9443
      protocol        = "HTTPS"
      certificate_arn = dependency.acm.outputs.certificates.ptele.arn
      stickiness = {
        enabled = true
      }
      health_check = {
        path     = "/pte-le/auth/login.jsf"
        protocol = "HTTPS"
        matcher  = "200"
      }
      listener_rule = {
        host_header = ["ap.${local.app_vars.locals.name}.${local.account_vars.locals.domain}"]
      }
    },
  }
}
