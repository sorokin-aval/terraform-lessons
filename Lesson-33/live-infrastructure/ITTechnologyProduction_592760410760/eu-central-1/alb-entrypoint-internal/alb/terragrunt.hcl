include {
  path = find_in_parent_folders()
}

# Hardcode!

dependency "vpc" {
  config_path = "../imported-vpc"
}

dependency "sg" {
  config_path = "../sg"
}

dependency "s3" {
  config_path = "../s3-access-log"
}


terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-alb.git?ref=v6.8.0"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags_map = local.common_tags.locals
  name      = local.common_tags.locals.Name
}

inputs = {
    name = local.name
    load_balancer_type = "application"
    vpc_id             = dependency.vpc.outputs.vpc_id
    subnets            = dependency.vpc.outputs.subnets
    security_groups    = [dependency.sg.outputs.security_group_id]
    internal = true
    access_logs = {
      bucket = dependency.s3.outputs.s3_bucket_id
    }
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

    https_listeners = [
      {
        port               = 443
        protocol           = "HTTPS"
        certificate_arn    = "arn:aws:acm:eu-central-1:592760410760:certificate/ac013763-22f4-49a1-ac0c-17de9f3fe7ba"
        action_type = "fixed-response"
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

    extra_ssl_certs =   [
      {
        certificate_arn = "arn:aws:acm:eu-central-1:592760410760:certificate/d144f35a-9497-42bf-b7f4-56768b1df1b0"
        https_listener_index = 0
    }]

#######################
# FORWARDING RULES
#######################

    https_listener_rules = [
      {
        https_listener_index = 0
        actions = [{
          type        = "forward"
          target_group_index = 0
        }]
        conditions = [{
          host_headers = ["web.cmd.prod.rbua"]
        }]
      },
      {
        https_listener_index = 0
        actions = [{
          type        = "forward"
          target_group_index = 1
        }]
        conditions = [{
          host_headers = ["entry-internal.infra.prod.rbua"]
        }]
      },
    ]

#######################
# TARGET GROUPS
#######################

    target_groups = [
# karabas
      {
        name_prefix      = "app-"
        backend_protocol = "HTTP"
        backend_port     = 8080
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
            target_id = "i-0344ad0e11b55a7f9"
            port = 8080
          }
        ]
      },
# Rodion-Instance
      {
        name_prefix      = "test-"
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
            target_id = "i-087a62c841730968b"
            port = 80
          }
        ]
      }
    ]
}