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
    "isc-8443" = {
      listener_port   = 8443
      name_prefix     = "isc-"
      target_port     = 8443
      protocol        = "HTTPS"
      certificate_arn = dependency.acm.outputs.certificates.iscard.arn
      stickiness = {
        enabled = true
      }
      health_check = {
        interval = 300
        path     = "/ws-upc-isc-jpos-20.0.0/health"
        protocol = "HTTPS"
        matcher  = "401"
      }
      listener_rule = {
        host_header = ["is-card.${local.account_vars.locals.domain}"]
      }
    },
    "isc-8445" = {
      listener_port   = 8445
      name_prefix     = "isc-"
      target_port     = 8445
      protocol        = "HTTPS"
      certificate_arn = dependency.acm.outputs.certificates.iscard.arn
      stickiness = {
        enabled = true
      }
      health_check = {
        interval = 300
        path     = "/calculateCvv2/app/health"
        protocol = "HTTPS"
        matcher  = "200"
      }
      listener_rule = {
        host_header = ["is-card.${local.account_vars.locals.domain}"]
      }
    },
    "isc-8447" = {
      listener_port   = 8447
      name_prefix     = "isc-"
      target_port     = 8447
      protocol        = "HTTPS"
      certificate_arn = dependency.acm.outputs.certificates.iscard.arn
      stickiness = {
        enabled = true
      }
      health_check = {
        interval = 300
        path     = "/ws-upc-isc-hsm-ps-20.0.0/health"
        protocol = "HTTPS"
        matcher  = "401"
      }
      listener_rule = {
        host_header = ["is-card.${local.account_vars.locals.domain}"]
      }
    },
    "iscv-8443" = {
      listener_port   = 8443
      name_prefix     = "iscv-"
      target_port     = 8443
      protocol        = "HTTPS"
      certificate_arn = dependency.acm.outputs.certificates.vienna-iscard.arn
      stickiness = {
        enabled = true
      }
      health_check = {
        interval = 30
        path     = "/ws-upc-isc-jpos-20.0.0/health"
        protocol = "HTTPS"
        matcher  = "200"
      }
      listener_rule = {
        host_header = ["vienna.is-card.${local.account_vars.locals.domain}"]
      }
    },
    "iscv-8445" = {
      listener_port   = 8445
      name_prefix     = "iscv-"
      target_port     = 8445
      protocol        = "HTTPS"
      certificate_arn = dependency.acm.outputs.certificates.vienna-iscard.arn
      stickiness = {
        enabled = true
      }
      health_check = {
        interval = 30
        path     = "/calculateCvv2/app/health"
        protocol = "HTTPS"
        matcher  = "200"
      }
      listener_rule = {
        host_header = ["vienna.is-card.${local.account_vars.locals.domain}"]
      }
    },
    "iscv-8447" = {
      listener_port   = 8447
      name_prefix     = "iscv-"
      target_port     = 8447
      protocol        = "HTTPS"
      certificate_arn = dependency.acm.outputs.certificates.vienna-iscard.arn
      stickiness = {
        enabled = true
      }
      health_check = {
        interval = 30
        path     = "/ws-upc-isc-hsm-ps-20.0.0/health"
        protocol = "HTTPS"
        matcher  = "200"
      }
      listener_rule = {
        host_header = ["vienna.is-card.${local.account_vars.locals.domain}"]
      }
    },
  }
}
