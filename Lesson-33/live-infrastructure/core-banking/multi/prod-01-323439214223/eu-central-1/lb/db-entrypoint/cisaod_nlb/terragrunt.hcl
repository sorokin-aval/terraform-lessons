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
  source = "github.com/terraform-aws-modules/terraform-aws-alb.git//.?ref=v6.8.0"
}
iam_role = local.account_vars.iam_role

locals {
  common_tags    = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags_map       = local.common_tags.locals
  name           = "cisaod-db-cbs-rbua"
  aws_account_id = local.account_vars.locals.aws_account_id
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))

}

inputs = {
  name               = local.name
  load_balancer_type = "network"
  vpc_id             = dependency.vpc.outputs.vpc_id.id
  subnets            = dependency.vpc.outputs.lb_subnets.ids
  internal           = true

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
      port               = 1575
      protocol           = "TCP"
      target_group_index = 1
    }
  ]

  #######################
  # TARGET GROUPS
  #######################

  target_groups = [
    { # index 0
      name_prefix      = "cis-"
      backend_protocol = "TCP"
      backend_port     = 1522
      target_type      = "instance"
      targets = [
        {
          target_id = "i-06b5dca1482434194"
          port      = 1522
        },
        {
          target_id = "i-0dc3c40c465ab2ff1"
          port      = 1522
        }
      ]
    },
    { #index 1
      name_prefix      = "cis-"
      backend_protocol = "TCP"
      backend_port     = 1575
      target_type      = "instance"
      targets = [
        {
          target_id = "i-06b5dca1482434194"
          port      = 1575
        },
        {
          target_id = "i-0dc3c40c465ab2ff1"
          port      = 1575
        }
      ]
    }
  ]
}
