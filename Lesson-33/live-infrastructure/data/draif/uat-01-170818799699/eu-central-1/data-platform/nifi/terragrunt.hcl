## terragrunt.hcl
include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/global.hcl"
  expose = true
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-data-nifi.git//?ref=v0.0.5"
  #source = "/Users/IUADE0H5/PycharmProjects/ua-tf-aws-data-nifi"
}

include {
  path = find_in_parent_folders()
}

include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true
}

dependency "iam_role" {
  config_path  = "../iam/iam_assumable_role/nifi/"
  mock_outputs = {
    iam_role_arn = "arn:aws:iam::${include.account.locals.aws_account_id}:role/mock_role_id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map     = local.project_vars.locals.project_tags
  name         = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-nifi-01"
}
generate "locals" {
  path      = "locals.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    locals {
  target_groups = [
    {
      name             = "nifi-target-group"
      backend_protocol = "HTTPS"
      backend_port     = 8443
      target_type      = "instance"
      targets = {
        for k, v in local.nifi_instance_ids : k => {
          target_id = v
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
        port                = 9443
        protocol            = "HTTPS"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        matcher             = "200-499"
      }
    }
  ]
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
      certificate_arn    = module.alb.acm_cert_arn
      target_group_index = 0
      ssl_policy         = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
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
          host_headers = ["nifi.test.data.rbua"]
        }
      ]
    },
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
          host_headers = ["nifi-registry.test.data.rbua"]
        }
      ]
    },
  ]
  }

  EOF
}
inputs = {
  tags                          = local.tags_map
  hosted_zone                   = "uat.data.rbua"
  alb_route53_records           = ["nifi", "nifi-registry"]
  # use this var if route53 records should be created manually
  alb_subject_alternative_names = ["nifi.test.data.rbua", "nifi-registry.test.data.rbua"]
  create_lb                     = true
  name_prefix                   = "rbua-data-nifi"

  nifi_subnets_names_filter = "*Internal*"

  # nifi instances
  nifi_multiple_instances = {
    rbua-data-nifi-01 = {
      ami_id                    = "ami-09cd44d30d956fa22"
      instance_type             = "c5.2xlarge"
      subnets_names_filter      = "*Internal*"
      availability_zone         = "eu-central-1c"
      dns_record                = "nifi-01.ec2"
      issue_certificate         = false
      create_iam_role_ssm       = false
      iam_instance_profile      = dependency.iam_role.outputs.iam_role_name
      subject_alternative_names = ["nifi-01.ec2.uat.data.rbua"]
      root_block_device         = [
        {
          delete_on_termination = false
          encrypted             = true
          volume_type           = "gp3"
          throughput            = 125
          volume_size           = 50
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
          iops        = 6000
          throughput  = 250
          volume_size = 301
          encrypted   = true
        },
        data2 = {
          device_name = "/dev/xvdd"
          volume_type = "gp3"
          volume_size = 30
          encrypted   = true

        }
      }
    }
    #    rbua-data-nifi-02 = {
    #      ami_id                    = "ami-0a94df1bbd58c90f7"
    #      instance_type             = "t3.micro"
    #      subnets_names_filter      = "*Internal*"
    #      availability_zone         = "eu-central-1b"
    #      dns_record                = "nifi-02.ec2"
    #      issue_certificate         = false
    #      #vpc_id = "vpc-0bfa88a3c4ab61887"
    #      #subnet_id = "subnet-0bf0afa501c24ed67"
    #      subject_alternative_names = ["nifi-02.ec2.uat.data.rbua"]
    #      root_block_device         = [
    #        {
    #          encrypted   = true
    #          volume_type = "gp3"
    #          throughput  = 200
    #          volume_size = 40
    #        }
    #      ]
    #    }
    #    nifi-03 = {
    #      instance_type     = "t3.medium"
    #      availability_zone = element(module.vpc.azs, 2)
    #      subnet_id         = element(module.vpc.private_subnets, 2)
    #    }
  }
  nifi_registry_multiple_instances = {
    rbua-data-nifi_registry-01 = {
      ami_id                    = "ami-09cd44d30d956fa22"
      instance_type             = "t3.micro"
      subnets_names_filter      = "*Internal*"
      availability_zone         = "eu-central-1c"
      dns_record                = "nifi-registry-01.ec2"
      issue_certificate         = true
      subject_alternative_names = ["nifi-registry-01.ec2.uat.data.rbua"]
      root_block_device         = [
        {
          delete_on_termination = false
          encrypted             = true
          volume_type           = "gp3"
          throughput            = 125
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
          volume_size           = 50
        }
      }
    }
  }
}
