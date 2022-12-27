terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git?ref=v7.0.0"
}

dependency "vpc" {
  config_path = "../../../core-infrastructure/imported-vpc/"
}


dependency "security_groups" {
  config_path  = "alb-sg/"
  mock_outputs = {
    security_group_id = "mock"
  }
  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}

dependency "nifi_01" {
  config_path  = "../nifi-01/"
  mock_outputs = {
    id = "mock"
  }
  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}

dependency "arn_cert" {
  config_path  = "acm/"
  mock_outputs = {
    certificates = { "nifi" : { "arn" : "arn:aws:acm:eu-central-1:418574960021:certificate/test" } }
  }
  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}

dependency "registry" {
  config_path  = "../nifi-registry/"
  mock_outputs = {
    id = "mock"
  }
  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map     = local.project_vars.locals.project_tags
  name         = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-nifi-alb"
}

inputs = {
  name               = local.name
  load_balancer_type = "application"
  internal           = true
  vpc_id             = dependency.vpc.outputs.vpc_id.id
  subnets            = dependency.vpc.outputs.lb_subnets.ids
  security_groups    = [dependency.security_groups.outputs.security_group_id]


  target_groups = [
    {
      name             = "rbua-data-uat-nifi-tg"
      backend_protocol = "HTTPS"
      backend_port     = 8443
      target_type      = "instance"
      targets          = {
        nifi = {
          target_id = dependency.nifi_01.outputs.id
          port      = 8443
        }
      }
      health_check = {
        path                = "/nifi"
        port                = 8443
        protocol            = "HTTPS"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        matcher             = "200-499"
      }
    },
    {
      name             = "rbua-data-uat-nifi-registry-tg"
      backend_protocol = "HTTPS"
      backend_port     = 9443
      target_type      = "instance"
      targets          = {
        registry = {
          target_id = dependency.registry.outputs.id
          port      = 9443
        }
      }
      health_check = {
        path                = "/nifi-registry/"
        port                = 9443
        protocol            = "HTTPS"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        matcher             = "200-499"
      }
    }
  ]
  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = dependency.arn_cert.outputs.certificates.nifi.arn
      target_group_index = 0
      ssl_policy         = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
    }
  ]
  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect    = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  https_listener_rules = [
    {
      https_listener_index = 0

      actions = [
        {
          type               = "forward"
          target_group_index = 0
        }
      ]

      conditions = [
        {
          host_headers = ["nifi.uat.data.rbua"]
        }
      ]
    }
  ]
  https_listener_rules = [
    {
      https_listener_index = 0

      actions = [
        {
          type               = "forward"
          target_group_index = 1
        }
      ]

      conditions = [
        {
          host_headers = ["nifi-registry.uat.data.rbua"]
        }
      ]
    }
  ]
  tags = local.tags_map
}