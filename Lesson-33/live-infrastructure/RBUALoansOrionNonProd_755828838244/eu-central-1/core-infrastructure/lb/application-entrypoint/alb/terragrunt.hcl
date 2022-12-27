include {
  path = find_in_parent_folders()
}

# Hardcode!

dependency "vpc" {
  config_path = "../../../baseline/"
}

dependency "sg" {
  config_path = "../sg"
}

# dependency "s3" {
#   config_path = "../../../core-infrastructure/s3-access-logs"
# }


terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-alb.git?ref=v6.8.0"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags_map = local.common_tags.locals
  name      = "app-orion-test-loans-rbua"
}

inputs = {
    name = local.name
    load_balancer_type = "application"
    vpc_id             = dependency.vpc.outputs.vpc_id.id
    subnets            = dependency.vpc.outputs.lb_subnets.ids
    security_groups    = [dependency.sg.outputs.security_group_id]
    internal = true
    # access_logs = {
    #   bucket = dependency.s3.outputs.s3_bucket_id
    # }
    tags = local.tags_map

#######################
# ALB listeners
#######################

    http_tcp_listeners = [
      {
        port               = 80
        protocol           = "HTTP"
        action_type = "redirect"
        redirect = {
          port        = "443"
          protocol    = "HTTPS"
          status_code = "HTTP_301"
        }
      }
    ]

    # https_listeners = [
    #   {
    #     port               = 443
    #     protocol           = "HTTPS"
    #     certificate_arn    = "arn:aws:acm:eu-central-1:323439214223:certificate/ad7778f0-b154-4be3-8c15-c442e218f1cc"
    #     action_type = "fixed-response"
    #     fixed_response = {
    #       content_type = "text/plain"
    #       message_body = "It works!"
    #       status_code  = "200"
    #     }
    #   }
    # ]

#######################
# EXTRA CERTIFICATES FOR HTTPS LISTENER. See more: https://aws.amazon.com/en/blogs/aws/new-application-load-balancer-sni/
#######################

    # extra_ssl_certs =   [
    #   {
    #     certificate_arn = "arn:aws:acm:eu-central-1:682969052504:certificate/aae971d8-fa8b-4146-b8f9-d48e9f23c045"
    #     https_listener_index = 0
    # }]

#######################
# FORWARDING RULES
#######################

    # https_listener_rules = [
    #   {
    #     https_listener_index = 0
    #     actions = [{
    #       type        = "forward"
    #       target_group_index = 0
    #     }]
    #     conditions = [{
    #       host_headers = ["xml-app.b2.cbs.rbua"]
    #     }]
    #   },
    #   {
    #     https_listener_index = 0
    #     actions = [{
    #       type        = "forward"
    #       target_group_index = 1
    #     }]
    #     conditions = [{
    #       host_headers = ["morrowind-app.ci.cbs.rbua"]
    #     }]
    #   }
    # ]

#######################
# TARGET GROUPS
#######################

    target_groups = [
      {
        name_prefix      = "ros-"
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
            target_id = "i-0b589cf91f34321dd"
            port = 80
          }
        ]
      },
      {
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
            target_id = "i-0cbffdaf61c3363c3"
            port = 8443
          }
        ]
      }
    ]
}
