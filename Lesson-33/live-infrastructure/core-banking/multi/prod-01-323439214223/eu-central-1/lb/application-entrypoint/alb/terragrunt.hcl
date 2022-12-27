include {
  path = find_in_parent_folders()
}

# Hardcode!

dependency "vpc" {
  config_path = "../../../core-infrastructure/baseline/"
}

dependency "sg" {
  config_path = "../sg"
}

dependency "sg_GlassFish" {
  config_path = "../../../sg/GlassFish"
}

dependency "s3" {
  config_path = "../../../core-infrastructure/s3-access-logs"
}


terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git//.?ref=v6.8.0"
}
iam_role = local.account_vars.iam_role

locals {
  common_tags    = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags_map       = local.common_tags.locals
  name           = "entrypoint-app-cbs-rbua"
  aws_account_id = local.account_vars.locals.aws_account_id
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))

}

inputs = {
  name               = local.name
  load_balancer_type = "application"
  vpc_id             = dependency.vpc.outputs.vpc_id.id
  subnets            = dependency.vpc.outputs.lb_subnets.ids
  security_groups    = [dependency.sg.outputs.security_group_id, dependency.sg_GlassFish.outputs.security_group_id]
  internal           = true
  idle_timeout       = 300
  access_logs = {
    bucket = dependency.s3.outputs.s3_bucket_id
  }
  tags = local.tags_map

  #######################
  # ALB listeners
  #######################

  http_tcp_listeners = [
    { #index 0
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    , { #index 1
      port        = 7100
      protocol    = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "It works!"
        status_code  = "200"
      }
    }
    , { #index 2
      port        = 7200
      protocol    = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "It works!"
        status_code  = "200"
      }
    }
    , { #index 3
      port        = 7300
      protocol    = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "It works!"
        status_code  = "200"
      }
    }
    , { #index 4
      port        = 7400
      protocol    = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "It works!"
        status_code  = "200"
      }
    }
    , { #index 5
      port        = 7500
      protocol    = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "It works!"
        status_code  = "200"
      }
    }
    , { #index 6
      port        = 9100
      protocol    = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "It works!"
        status_code  = "200"
      }
    }
    , { #index 7
      port        = 9101
      protocol    = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "It works!"
        status_code  = "200"
      }
    }
    , { #index 8
      port        = 9200
      protocol    = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "It works!"
        status_code  = "200"
      }
    }
    , { #index 9
      port        = 9201
      protocol    = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "It works!"
        status_code  = "200"
      }
    }
    , { #index 10
      port        = 9300
      protocol    = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "It works!"
        status_code  = "200"
      }
    }
    , { #index 11
      port        = 9400
      protocol    = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "It works!"
        status_code  = "200"
      }
    }
    , { #index 12
      port        = 9401
      protocol    = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "It works!"
        status_code  = "200"
      }
    }
    , { #index 13
      port        = 8777
      protocol    = "HTTP"
      action_type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "It works!"
        status_code  = "200"
      }
    }
  ]

  https_listeners = [
    { #index 0
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:acm:eu-central-1:323439214223:certificate/ad7778f0-b154-4be3-8c15-c442e218f1cc"
      action_type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "It works!"
        status_code  = "200"
      }
    }
  ]

  #######################
  # EXTRA CERTIFICATES FOR HTTPS LISTENER. See more: https://aws.amazon.com/en/blogs/aws/new-application-load-balancer-sni/
  #######################

  extra_ssl_certs = [
    {
      certificate_arn      = "arn:aws:acm:eu-central-1:323439214223:certificate/41809eff-fb29-4d20-86e3-29319b673ed4"
      https_listener_index = 0
    },
    {
      certificate_arn      = "arn:aws:acm:eu-central-1:323439214223:certificate/d251e411-a5e8-4b58-b3fb-250dbf3f9d86"
      https_listener_index = 0
    },
    {
      certificate_arn      = "arn:aws:acm:eu-central-1:323439214223:certificate/8426f4a1-cd07-43a2-a44b-fb7a654da72b"
      https_listener_index = 0
    }
  ]


  #######################
  # TARGET GROUPS
  #######################

  target_groups = [
    { #index0
      name_prefix      = "xml-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      targets = [
        {
          target_id = "i-0709700bc970ab865"
          port      = 80
        },
        {
          target_id = "i-0c6be5725a7228a21"
          port      = 80
        }
      ]
    },
    { #index1
      name_prefix      = "mor-"
      backend_protocol = "HTTPS"
      backend_port     = 8443
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTPS"
        matcher             = "200-399"
      }
      targets = [
        {
          target_id = "i-069146b3f250a307f"
          port      = 8443
        },
        {
          target_id = "i-0e79620542b79cb56"
          port      = 8443
        }
      ]
    },
    { #index2
      name_prefix      = "GlsF-"
      backend_protocol = "HTTP"
      backend_port     = 7100
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      targets = [
        {
          target_id = "i-011b21bbe543417f3"
          port      = 7100
        },
        {
          target_id = "i-002b561d0c67e6e9c"
          port      = 7100
        }
      ]
    },
    { #index3
      name_prefix      = "GlsF-"
      backend_protocol = "HTTP"
      backend_port     = 7200
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      targets = [
        {
          target_id = "i-011b21bbe543417f3"
          port      = 7200
        },
        {
          target_id = "i-002b561d0c67e6e9c"
          port      = 7200
        }
      ]
    },
    { #index4
      name_prefix      = "GlsF-"
      backend_protocol = "HTTP"
      backend_port     = 7300
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      targets = [
        {
          target_id = "i-011b21bbe543417f3"
          port      = 7300
        },
        {
          target_id = "i-002b561d0c67e6e9c"
          port      = 7300
        }
      ]
    },
    { #index5
      name_prefix      = "GlsF-"
      backend_protocol = "HTTP"
      backend_port     = 7400
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      targets = [
        {
          target_id = "i-011b21bbe543417f3"
          port      = 7400
        },
        {
          target_id = "i-002b561d0c67e6e9c"
          port      = 7400
        }
      ]
    },
    { #index6
      name_prefix      = "GlsF-"
      backend_protocol = "HTTP"
      backend_port     = 7500
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      targets = [
        {
          target_id = "i-011b21bbe543417f3"
          port      = 7500
        },
        {
          target_id = "i-002b561d0c67e6e9c"
          port      = 7500
        }
      ]
    },

    { #index7
      name_prefix      = "GlsF-"
      backend_protocol = "HTTP"
      backend_port     = 9100
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      targets = [
        {
          target_id = "i-011b21bbe543417f3"
          port      = 9100
        },
        {
          target_id = "i-002b561d0c67e6e9c"
          port      = 9100
        }
      ]
    },
    { #index8
      name_prefix      = "GlsF-"
      backend_protocol = "HTTP"
      backend_port     = 9101
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      targets = [
        {
          target_id = "i-011b21bbe543417f3"
          port      = 9101
        },
        {
          target_id = "i-002b561d0c67e6e9c"
          port      = 9101
        }
      ]
    },
    { #index9
      name_prefix      = "GlsF-"
      backend_protocol = "HTTP"
      backend_port     = 9200
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      targets = [
        {
          target_id = "i-011b21bbe543417f3"
          port      = 9200
        },
        {
          target_id = "i-002b561d0c67e6e9c"
          port      = 9200
        }
      ]
    },
    { #index10
      name_prefix      = "GlsF-"
      backend_protocol = "HTTP"
      backend_port     = 9201
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      targets = [
        {
          target_id = "i-011b21bbe543417f3"
          port      = 9201
        },
        {
          target_id = "i-002b561d0c67e6e9c"
          port      = 9201
        }
      ]
    },
    { #index11
      name_prefix      = "GlsF-"
      backend_protocol = "HTTP"
      backend_port     = 9300
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      targets = [
        {
          target_id = "i-011b21bbe543417f3"
          port      = 9300
        },
        {
          target_id = "i-002b561d0c67e6e9c"
          port      = 9300
        }
      ]
    },
    { #index12
      name_prefix      = "GlsF-"
      backend_protocol = "HTTP"
      backend_port     = 9400
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      targets = [
        {
          target_id = "i-011b21bbe543417f3"
          port      = 9400
        },
        {
          target_id = "i-002b561d0c67e6e9c"
          port      = 9400
        }
      ]
    },
    { #index13
      name_prefix      = "GlsF-"
      backend_protocol = "HTTP"
      backend_port     = 9401
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      targets = [
        {
          target_id = "i-011b21bbe543417f3"
          port      = 9401
        },
        {
          target_id = "i-002b561d0c67e6e9c"
          port      = 9401
        }
      ]
    },
    { #index14
      name_prefix      = "GlsF-"
      backend_protocol = "HTTP"
      backend_port     = 8777
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      targets = [
        {
          target_id = "i-011b21bbe543417f3"
          port      = 8777
        },
        {
          target_id = "i-002b561d0c67e6e9c"
          port      = 8777
        }
      ]
    },
    { #index15
      name_prefix      = "jet-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      targets = [
        {
          target_id = "i-0bd4780d59e7279c0"
          port      = 80
        },
        {
          target_id = "i-0fdf3ac56bc7f0deb"
          port      = 80
        }
      ]
    }
  ]

  #######################
  # FORWARDING RULES
  #######################
  http_tcp_listener_rules = [
    {
      http_tcp_listener_index = 1
      actions = [{
        type               = "forward"
        target_group_index = 2
      }]
      conditions = [{
        host_headers = ["glassf-app.cbs.rbua"]
      }]
    }
    , {
      http_tcp_listener_index = 2
      actions = [{
        type               = "forward"
        target_group_index = 3
      }]
      conditions = [{
        host_headers = ["glassf-app.cbs.rbua"]
      }]
    }
    , {
      http_tcp_listener_index = 3
      actions = [{
        type               = "forward"
        target_group_index = 4
      }]
      conditions = [{
        host_headers = ["glassf-app.cbs.rbua"]
      }]
    }
    , {
      http_tcp_listener_index = 4
      actions = [{
        type               = "forward"
        target_group_index = 5
      }]
      conditions = [{
        host_headers = ["glassf-app.cbs.rbua"]
      }]
    }
    , {
      http_tcp_listener_index = 5
      actions = [{
        type               = "forward"
        target_group_index = 6
      }]
      conditions = [{
        host_headers = ["glassf-app.cbs.rbua"]
      }]
    }
    , {
      http_tcp_listener_index = 6
      actions = [{
        type               = "forward"
        target_group_index = 7
      }]
      conditions = [{
        host_headers = ["glassf-app.cbs.rbua"]
      }]
    }
    , {
      http_tcp_listener_index = 7
      actions = [{
        type               = "forward"
        target_group_index = 8
      }]
      conditions = [{
        host_headers = ["glassf-app.cbs.rbua"]
      }]
    }
    , {
      http_tcp_listener_index = 8
      actions = [{
        type               = "forward"
        target_group_index = 9
      }]
      conditions = [{
        host_headers = ["glassf-app.cbs.rbua"]
      }]
    }
    , {
      http_tcp_listener_index = 9
      actions = [{
        type               = "forward"
        target_group_index = 10
      }]
      conditions = [{
        host_headers = ["glassf-app.cbs.rbua"]
      }]
    }
    , {
      http_tcp_listener_index = 10
      actions = [{
        type               = "forward"
        target_group_index = 11
      }]
      conditions = [{
        host_headers = ["glassf-app.cbs.rbua"]
      }]
    }
    , {
      http_tcp_listener_index = 11
      actions = [{
        type               = "forward"
        target_group_index = 12
      }]
      conditions = [{
        host_headers = ["glassf-app.cbs.rbua"]
      }]
    }
    , {
      http_tcp_listener_index = 12
      actions = [{
        type               = "forward"
        target_group_index = 13
      }]
      conditions = [{
        host_headers = ["glassf-app.cbs.rbua"]
      }]
    }
    , {
      http_tcp_listener_index = 13
      actions = [{
        type               = "forward"
        target_group_index = 14
      }]
      conditions = [{
        host_headers = ["glassf-app.cbs.rbua"]
      }]
    }
  ]

  https_listener_rules = [
    {
      https_listener_index = 0
      actions = [{
        type               = "forward"
        target_group_index = 0
      }]
      conditions = [{
        host_headers = ["xml-app.b2.cbs.rbua"]
      }]
    },
    {
      https_listener_index = 0
      actions = [{
        type               = "forward"
        target_group_index = 15
      }]
      conditions = [{
        host_headers = ["jet-app.b2.cbs.rbua"]
      }]
    },
    {
      https_listener_index = 0
      actions = [{
        type               = "forward"
        target_group_index = 1
      }]
      conditions = [{
        host_headers = ["morrowind-app.ci.cbs.rbua"]
      }]
    }
  ]

}
