## terragrunt.hcl
include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/global.hcl"
  expose = true
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-data-nifi.git//?ref=v0.0.8"
  #source = "/Users/IUADE0H5/PycharmProjects/ua-tf-aws-data-nifi"
}

include {
  path = find_in_parent_folders()
}

include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true
}

#dependency "iam_role" {
#  config_path  = "../iam/iam_assumable_role/nifi/"
#  mock_outputs = {
#    iam_role_arn = "arn:aws:iam::${include.account.locals.aws_account_id}:role/mock_role_id"
#  }
#  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
#}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map     = local.project_vars.locals.project_tags
}
generate "locals" {
  path      = "locals.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    locals {
   nifi_target_groups = [
    for i, instance in local.nifi_instance_ids : {
      name             =  format("data-nifi-target-group-%d", i)
      backend_protocol = "HTTPS"
      backend_port     = 8443
      target_type      = "instance"
      targets = {
        0 = {
          target_id = instance
          port      = 8443
        }
      }
      health_check = {
        path                = "/nifi/"
        port                = "traffic-port"
        protocol            = "HTTPS"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        matcher             = "200-499"
      }
  }]
  registry_target_group = [{
    name             = "nifi-registry-target-group"
    backend_protocol = "HTTPS"
    backend_port     = 9443
    target_type      = "instance"
    targets = {
      for k, v in local.nifi_registry_instance_ids : k => {
        target_id = v
        port      = 9443
      }
    }
    health_check = {
      path                = "/nifi-registry/"
      port                = "traffic-port"
      protocol            = "HTTPS"
      healthy_threshold   = 3
      unhealthy_threshold = 3
      matcher             = "200-499"
    }
  }]
  target_groups = concat(local.registry_target_group, local.nifi_target_groups)

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
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
      certificate_arn    = "arn:aws:acm:eu-central-1:803318861901:certificate/d8f21aad-e945-4e5b-a08a-a56b9c8224aa"
      target_group_index = 0
      ssl_policy         = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
    }
  ]
  https_listener_rules = [for k, entry in var.alb_subject_alternative_names : {
    https_listener_index = 0
    actions = [{ type               = "forward"
        target_group_index = k
      }]
    conditions = [{host_headers = [entry]}]
    }
  ]
  }

  EOF
}
inputs = {
  tags                          = local.tags_map
  #hosted_zone                   = "uat.avalaunch.aval"
  #alb_route53_records           = ["nifi", "nifi-registry"]
  # TODO: use this var if route53 records should be created manually
  # order of this entries will be mapped to targets
  # make this transparent
  alb_subject_alternative_names = [
    "nifi-registry.data.rbua", "nifi-01.data.rbua", "nifi-02.data.rbua", "nifi-03.data.rbua"
  ]
  create_lb                 = true
  name_prefix               = "rbua-data-nifi"
  alb_subnets_names_filter  = "*Internal*"
  nifi_subnets_names_filter = "*Internal*"
  key_name                  = "Data_Ops_Prod"
  # nifi instances
  nifi_multiple_instances   = {
    rbua-data-nifi-01 = {
      ami_id                    = "ami-0560f8253e5186d73"
      instance_type             = "c5.4xlarge"
      subnets_names_filter      = "*Internal*"
      availability_zone         = "eu-central-1c"
      #dns_record           = "nifi-01.ec2"
      issue_certificate         = false
      create_iam_role_ssm       = true
      disable_api_termination   = true
      private_ip                = "10.225.126.47"
      #iam_instance_profile      = dependency.iam_role.outputs.iam_role_name
      subject_alternative_names = [] # ["nifi-01.ec2.uat.avalaunch.aval"]
      root_block_device         = [
        {
          delete_on_termination = false
          encrypted             = true
          volume_type           = "gp3"
          throughput            = 125
          volume_size           = 50
          iops                  = 3000
          tags                  = {
            Name = "root-nifi-01"
          }
        }
      ]
      enable_volume_tags   = false
      aws_ebs_block_device = {
        data1 = {
          device_name = "/dev/xvdf"
          volume_type = "gp3"
          iops        = 10000
          throughput  = 512
          volume_size = 750
          encrypted   = true
        }
      }
    }
    rbua-data-nifi-02 = {
      ami_id                    = "ami-0560f8253e5186d73"
      instance_type             = "c5.4xlarge"
      subnets_names_filter      = "*Internal*"
      availability_zone         = "eu-central-1b"
      #dns_record           = "nifi-01.ec2"
      issue_certificate         = false
      create_iam_role_ssm       = true
      disable_api_termination   = true
      private_ip                = "10.225.125.250"
      #iam_instance_profile      = dependency.iam_role.outputs.iam_role_name
      subject_alternative_names = [] # ["nifi-01.ec2.uat.avalaunch.aval"]
      root_block_device         = [
        {
          delete_on_termination = false
          encrypted             = true
          volume_type           = "gp3"
          throughput            = 250
          volume_size           = 50
          iops                  = 3000
          tags                  = {
            Name = "root-nifi-02"
          }
        }
      ]
      enable_volume_tags   = false
      aws_ebs_block_device = {
        data1 = {
          device_name = "/dev/xvdf"
          volume_type = "gp3"
          iops        = 10000
          throughput  = 512
          volume_size = 750
          encrypted   = true
        }
      }
    }
    rbua-data-nifi-03 = {
      ami_id                    = "ami-0560f8253e5186d73"
      instance_type             = "c5.2xlarge"
      subnets_names_filter      = "*Internal*"
      availability_zone         = "eu-central-1a"
      #dns_record           = "nifi-01.ec2"
      issue_certificate         = false
      create_iam_role_ssm       = true
      disable_api_termination   = true
      private_ip                = "10.225.125.79"
      #iam_instance_profile      = dependency.iam_role.outputs.iam_role_name
      subject_alternative_names = [] # ["nifi-01.ec2.uat.avalaunch.aval"]
      root_block_device         = [
        {
          delete_on_termination = false
          encrypted             = true
          volume_type           = "gp3"
          throughput            = 250
          volume_size           = 50
          iops                  = 3000
          tags                  = {
            Name = "root-nifi-03"
          }
        }
      ]
      enable_volume_tags   = false
      aws_ebs_block_device = {
        data1 = {
          device_name = "/dev/xvdf"
          volume_type = "gp3"
          iops        = 10000
          throughput  = 512
          volume_size = 500
          encrypted   = true
        }
      }
    }
  }
  nifi_registry_multiple_instances = {
    rbua-data-nifi_registry-01 = {
      ami_id                    = "ami-09cd44d30d956fa22"
      instance_type             = "t3.small"
      subnets_names_filter      = "*Internal*"
      availability_zone         = "eu-central-1c"
      #dns_record           = "nifi-registry-01.ec2"
      issue_certificate         = false
      private_ip                = "10.225.126.10"
      disable_api_termination   = true
      subject_alternative_names = [] #["nifi-registry-01.ec2.uat.avalaunch.aval"]
      root_block_device         = [
        {
          delete_on_termination = false
          encrypted             = true
          volume_type           = "gp3"
          throughput            = 125
          iops                  = 3000
          volume_size           = 40
        }
      ]
      aws_ebs_block_device = {
        data1 = {
          delete_on_termination = true
          device_name           = "/dev/xvdb"
          encrypted             = true
          volume_type           = "gp3"
          throughput            = 125
          iops                  = 3000
          volume_size           = 10
        }
      }
    }
  }
}
