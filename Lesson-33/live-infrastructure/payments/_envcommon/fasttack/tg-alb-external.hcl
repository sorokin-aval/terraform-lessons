dependency "vpc" { config_path = find_in_parent_folders("core-infrastructure/vpc-info") }
dependency "alb" { config_path = find_in_parent_folders("alb-external/alb") }
dependency "acm" { config_path = find_in_parent_folders("acm") }

terraform {
  source = local.account_vars.locals.sources["target-group"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  hostnames    = local.account_vars.locals.environment == "prod" ? ["tlcms.aval.ua"] : ["tlcms-uat.avrb.com.ua"]
  cert_arn     = local.account_vars.locals.environment == "prod" ? "arn:aws:acm:eu-central-1:424050786838:certificate/a4d4d6d6-566f-4ac6-a96d-fb5456b235b0" : "arn:aws:acm:eu-central-1:595150552767:certificate/da32d89e-b69b-4642-ae24-1b9e032822f5"
}

inputs = {
  load_balancer_arn = dependency.alb.outputs.lb_arn
  vpc_id = dependency.vpc.outputs.vpc_id.id

  target_groups = {
    "13000" = {
      listener_port   = 443
      name_prefix     = "fst-"
      target_port     = 13000
      protocol        = "HTTP"
      certificate_arn = local.cert_arn
      stickiness = {
        enabled = true
      }
      health_check = {
        path     = "/fasttack-core/health"
        protocol = "HTTP"
        matcher  = "200-299"
      }
      listener_rule = {
        host_header = local.hostnames
      }
    },
  }
}
