dependency "vpc" { config_path = find_in_parent_folders("vpc-info") }
dependency "s3" { config_path = find_in_parent_folders("s3/lb-access-logs") }
dependency "sg" { config_path = find_in_parent_folders("sg/alb-public") }
dependency "target_nginx" { config_path = find_in_parent_folders("ec2/instances/maintenance-nginx") }
dependency "target_webpromo" { config_path = find_in_parent_folders("webpromo/ec2/instances/webpromo") }

terraform { source = local.account_vars.sources_lb }

locals {
  name         = "${lower(local.tags_map.System)}-${local.tags_map.env}-${basename(get_terragrunt_dir())}"
  lb_name      = "public"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  targets_webpromo = local.account_vars.lb_targets_webpromo
  tags         = merge(local.tags_map, { ccoe-inet-in-name = local.account_vars.lb_public_tag_value })
}

iam_role = local.account_vars.iam_role

inputs = {
  name = local.lb_name

  load_balancer_type = "application"

  vpc_id          = dependency.vpc.outputs.vpc_id.id
  subnets         = dependency.vpc.outputs.public_subnets.ids
  security_groups = ["${dependency.sg.outputs.security_group_id}"]
  internal        = false

  access_logs = {
    bucket = dependency.s3.outputs.s3_bucket_id
  }

  https_listeners = [
    { 
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
      certificate_arn = local.account_vars.lb_ssl_cert_arn
      action_type     = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Host header or path was not found"
        status_code  = "404"
      }
    },
  ]

  https_listener_rules = [
    {
      https_listener_index = 0
      actions = [{
        type               = "forward"
        target_group_index = 1
      }]
      conditions = [{
        host_headers = ["sales-uat.avrb.com.ua", "sales.raiffeisen.ua"]
      }]
    },
    {
      https_listener_index = 0
      actions = [{
        type        = "redirect"
        host        = "sales.raiffeisen.ua"
        status_code = "HTTP_302"
        protocol    = "HTTPS"
	}]
      conditions = [{
        host_headers = ["sales.aval.ua"]
      }]
    },
    {
      https_listener_index = 0
      actions = [{
        type               = "forward"
        target_group_index = "${local.account_vars.maintenance == "true" ? "2" : "0"}"
      }]
      conditions = [{
        host_headers = ["${local.account_vars.public_domain}", "www.${local.account_vars.public_domain}"]
      }]
    },
    {
      https_listener_index = 0
      actions = [{
        type               = "forward"
        target_group_index = 3
      }]
      conditions = [{
        host_headers = ["${local.account_vars.webpromo_public_domain}"]
      }]
    },
  ]

  target_groups = [
    { ## index 0
      name             = substr("${local.name}-cmsfront",0,32)
      backend_protocol = "HTTPS"
      backend_port     = 443
      target_type      = "instance"
      stickiness = {
        type            = "app_cookie"
        cookie_name     = "laravel_session"
        cookie_duration = 3600
      }
      health_check = {
        enabled             = true
        interval            = 10
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTPS"
        matcher             = "200"
      }
    },
    { ## index 1
      name             = "raifsite-pub-alb-cmsfront-sales"
      backend_protocol = "HTTPS"
      backend_port     = 8443
      target_type      = "instance"
      stickiness = {
        type            = "app_cookie"
        cookie_name     = "laravel_session"
        cookie_duration = 3600
      }
      health_check = {
        enabled             = true
        interval            = 10
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTPS"
        matcher             = "200"
      }
    },
    { ## index 2
      name             = substr("${local.name}-nginx",0,32)
      backend_protocol = "HTTPS"
      backend_port     = 443
      target_type      = "instance"
      stickiness = {
        type            = "lb_cookie"
        cookie_duration = 3600
      }
      health_check = {
        enabled             = true
        interval            = 10
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTPS"
        matcher             = "200"
      }
      targets = [  
#      { target_id = "${dependency.target_nginx.outputs.id}" }, #come up with a way to try ti registrate target only if the needed flag is set
      ]
    },
    { ## index 3
      name             = substr("${local.name}-webpromo",0,32)
      backend_protocol = "HTTPS"
      backend_port     = 443
      target_type      = "instance"
      stickiness = {
        type            = "lb_cookie"
        cookie_duration = 3600
      }
      health_check = {
        enabled             = true
        interval            = 10
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTPS"
        matcher             = "302"
      }
      targets = local.targets_webpromo
    },
  ]

  tags = local.tags
}
