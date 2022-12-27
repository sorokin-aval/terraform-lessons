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
    "10101" = {
      listener_port   = 443
      name_prefix     = "nrk-"
      target_port     = 10101
      protocol        = "HTTPS"
      certificate_arn = dependency.acm.outputs.certificates.norkom.arn
      stickiness = {
        enabled = true
      }
      health_check = {
        protocol = "HTTPS"
        matcher  = "200"
      }
      listener_rule = {
        host_header = ["norkom.${local.account_vars.locals.domain}"]
      }
    },
  }
}
