include {
  path = find_in_parent_folders()
}

# Hardcode!

dependency "vpc" {
  config_path = "../../../core-infrastructure/baseline"
}

dependency "s3" {
  config_path = "../../../core-infrastructure/s3-access-logs"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-alb.git?ref=v6.8.0"
}
iam_role = local.account_vars.iam_role

locals {
  current_tags   = read_terragrunt_config("tags.hcl")
  common_tags    = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  common_tags_map = local.common_tags.locals
  local_tags_map  = local.current_tags.locals

  tags_map = merge(local.common_tags_map, local.local_tags_map)

  name = "b2-db-cbs-rbua"
}

inputs = {
  name                             = local.name
  load_balancer_type               = "network"
  vpc_id                           = dependency.vpc.outputs.vpc_id.id
  subnets                          = dependency.vpc.outputs.lb_subnets.ids
  internal                         = true
  idle_timeout                     = 180
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = true
  access_logs = {
    bucket = dependency.s3.outputs.s3_bucket_id
  }
  tags = local.tags_map

  #######################
  # NLB listeners
  #######################

  http_tcp_listeners = [
    {
      port               = 1521
      protocol           = "TCP"
      target_group_index = 0
    },
    {
      port               = 1522
      protocol           = "TCP"
      target_group_index = 1
    },
    {
      port               = 1523
      protocol           = "TCP"
      target_group_index = 2
    },
    {
      port               = 1524
      protocol           = "TCP"
      target_group_index = 3
    },
    {
      port               = 1525
      protocol           = "TCP"
      target_group_index = 4
    },
    {
      port               = 1526
      protocol           = "TCP"
      target_group_index = 5
    },
    {
      port               = 1575
      protocol           = "TCP"
      target_group_index = 6
    }
  ]

  #######################
  # TARGET GROUPS
  #######################

  target_groups = [
    {
      name_prefix      = "b2-"
      backend_protocol = "TCP"
      backend_port     = 1521
      target_type      = "instance"
      targets = [
        {
          target_id = "i-0b77b5ff6f8eb9865"
          port      = 1522
        }
        , {
          target_id = "i-0c2ce76498344a320"
          port      = 1522
        }
      ]
    },
    {
      name_prefix      = "b2-"
      backend_protocol = "TCP"
      backend_port     = 1522
      target_type      = "instance"
      targets = [
        {
          target_id = "i-0b77b5ff6f8eb9865"
          port      = 1522
        }
        , {
          target_id = "i-0c2ce76498344a320"
          port      = 1522
        }
      ]
    },
    {
      name_prefix      = "b2-"
      backend_protocol = "TCP"
      backend_port     = 1523
      target_type      = "instance"
      targets = [
        {
          target_id = "i-0b77b5ff6f8eb9865"
          port      = 1523
        }
        , {
          target_id = "i-0c2ce76498344a320"
          port      = 1523
        }
      ]
    },
    {
      name_prefix      = "b2-"
      backend_protocol = "TCP"
      backend_port     = 1524
      target_type      = "instance"
      targets = [
        {
          target_id = "i-0b77b5ff6f8eb9865"
          port      = 1524
        }
        , {
          target_id = "i-0c2ce76498344a320"
          port      = 1524
        }
      ]
    },
    {
      name_prefix      = "b2-"
      backend_protocol = "TCP"
      backend_port     = 1525
      target_type      = "instance"
      targets = [
        {
          target_id = "i-0b77b5ff6f8eb9865"
          port      = 1525
        }
        , {
          target_id = "i-0c2ce76498344a320"
          port      = 1525
        }
      ]
    },
    {
      name_prefix      = "b2-"
      backend_protocol = "TCP"
      backend_port     = 1526
      target_type      = "instance"
      targets = [
        {
          target_id = "i-0b77b5ff6f8eb9865"
          port      = 1526
        }
        , {
          target_id = "i-0c2ce76498344a320"
          port      = 1526
        }
      ]
    },
    {
      name_prefix      = "b2-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        {
          target_id = "i-0b77b5ff6f8eb9865"
          port      = 1575
        }
        , {
          target_id = "i-0c2ce76498344a320"
          port      = 1575
        }
      ]
    },
  ]
}
