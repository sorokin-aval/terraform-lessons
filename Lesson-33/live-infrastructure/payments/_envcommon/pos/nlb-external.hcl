dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

dependency "ap01" {
  config_path = find_in_parent_folders("pos/ap01.pos")
}

dependency "ap02" {
  config_path = find_in_parent_folders("pos/ap02.pos")
}

dependencies {
  paths = [
    find_in_parent_folders("core-infrastructure/vpc-info"),
    # find_in_parent_folders("s3-access-log"),
    find_in_parent_folders("pos/ap01.pos"),
    find_in_parent_folders("pos/ap02.pos"),
  ]
}

terraform {
  source = local.account_vars.locals.sources["elb"]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
}

inputs = {
  name = basename(get_terragrunt_dir())

  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true

  vpc_id   = dependency.vpc.outputs.vpc_id.id
  subnets  = ["subnet-0023c5cf44371c9df", "subnet-0e55426d1e299f604"] # dependency.vpc.outputs.public_subnets.ids changed due to "This object does not have an attribute named "public_subnets" error
  internal = false

  #   access_logs = {
  #     bucket = dependency.s3.outputs.s3_bucket_id
  #   }

  http_tcp_listeners = [
    { # POS - index 0
      port               = 8441
      protocol           = "TCP"
      target_group_index = 0
    },
    { # POS - index 1
      port               = 8442
      protocol           = "TCP"
      target_group_index = 1
    },
    { # POS - index 2
      port               = 8443
      protocol           = "TCP"
      target_group_index = 2
    },
  ]

  target_groups = [
    { # POS - index 0
      name_prefix      = "pos-"
      backend_protocol = "TCP"
      backend_port     = 8441
      target_type      = "instance"
      targets = [
        { target_id : dependency.ap01.outputs.ec2_id, port : 8441 },
        { target_id : dependency.ap02.outputs.ec2_id, port : 8441 },
      ]
    },
    { # POS - index 1
      name_prefix      = "pos-"
      backend_protocol = "TCP"
      backend_port     = 8442
      target_type      = "instance"
      targets = [
        { target_id : dependency.ap01.outputs.ec2_id, port : 8442 },
        { target_id : dependency.ap02.outputs.ec2_id, port : 8442 },
      ]
    },
    { # POS - index 2
      name_prefix      = "pos-"
      backend_protocol = "TCP"
      backend_port     = 8443
      target_type      = "instance"
      targets = [
        { target_id : dependency.ap01.outputs.ec2_id, port : 8443 },
        { target_id : dependency.ap02.outputs.ec2_id, port : 8443 },
      ]
    },
  ]

  tags = merge(local.app_vars.locals.tags, { ccoe-inet-in-name = "nlb-public" })
}
