include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

// Hardcode and should be changed to git path
dependency "vpc" {
  config_path = "../imported-vpc/"
}

dependency "sg" {
  config_path = "../imported-vpc/"
}

// Instances. Hardcode and should be changed to git path

dependency "ksi-noc-dc1-kv-aval" {
  config_path = "../../services/infrastructure/apacheDS/ksi.noc-dc1.kv.aval"
}

dependency "phi-noc-dc1-kv-aval" {
  config_path = "../../services/infrastructure/apacheDS/phi.noc-dc1.kv.aval"
}

dependency "psi-noc-dc1-kv-aval" {
  config_path = "../../services/infrastructure/apacheDS/psi.noc-dc1.kv.aval"
}

dependency "tau-noc-dc1-kv-aval" {
  config_path = "../../services/infrastructure/apacheDS/tau.noc-dc1.kv.aval"
}


locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map     = local.common_tags.locals
  name         = "nlb-entrypoint"
}

terraform {
  #source = "github.com/terraform-aws-modules/terraform-aws-alb.git?ref=v6.8.0"
  source = "github.com/terraform-aws-modules/terraform-aws-alb.git?ref=v8.2.1"
}

inputs = {
  name               = local.name
  load_balancer_type = "network"
  internal           = true
  vpc_id             = dependency.vpc.outputs.vpc_id.id
  subnets            = dependency.vpc.outputs.app_subnets.ids
  tags               = local.tags_map
  http_tcp_listeners = [
    {
      port               = 389
      protocol           = "TCP"
      target_group_index = 0

    },
    {
      port               = 636
      protocol           = "TCP"
      target_group_index = 1
    },
    {
      port               = 443
      protocol           = "TCP"
      target_group_index = 2
    }
  ]
  target_groups = [
    #Oracle ldap auth servers
    {
      name_prefix      = "ds-"
      backend_protocol = "TCP"
      backend_port     = 389
      target_type      = "instance"
      health_check = {
        enabled             = true
        healthy_threshold   = 3
        unhealthy_threshold = 3
        interval            = 30
        protocol            = "TCP"


      }
      preserve_client_ip = true
      targets = [
        #Oracle ldap auth servers
        #Target group index 0
        {
          target_id = dependency.ksi-noc-dc1-kv-aval.outputs.id
          port      = 10389
        },
        {
          target_id = dependency.psi-noc-dc1-kv-aval.outputs.id
          port      = 10389
        },
        {
          target_id = dependency.tau-noc-dc1-kv-aval.outputs.id
          port      = 10389
        },
        {
          target_id = dependency.phi-noc-dc1-kv-aval.outputs.id
          port      = 10389
        },
      ]
    },
    #Oracle ldap auth servers
    #Target group index 1
    {
      name_prefix      = "dt-"
      backend_protocol = "TCP"
      backend_port     = 10636
      target_type      = "instance"
      health_check = {
        enabled             = true
        healthy_threshold   = 3
        unhealthy_threshold = 3
        interval            = 30
        protocol            = "TCP"


      }
      preserve_client_ip = true
      targets = [
        {
          target_id = dependency.ksi-noc-dc1-kv-aval.outputs.id
          port      = 10636
        },
        {
          target_id = dependency.psi-noc-dc1-kv-aval.outputs.id
          port      = 10636
        },
        {
          target_id = dependency.tau-noc-dc1-kv-aval.outputs.id
          port      = 10636
        },
        {
          target_id = dependency.phi-noc-dc1-kv-aval.outputs.id
          port      = 10636
        },
      ]
    },
    #Avalaunch target group
    #Target group index 2
    {
      name_prefix        = "fa-"
      backend_protocol   = "TCP"
      backend_port       = 443
      target_type        = "ip"
      preserve_client_ip = true

      targets = [
        {
          target_id         = "10.225.121.22"
          port              = 443
          availability_zone = "all"
        },
        {
          target_id         = "10.225.121.191"
          port              = 443
          availability_zone = "all"
        },
        {
          target_id         = "10.225.122.88"
          port              = 443
          availability_zone = "all"
        }
      ]
    },
  ]
}

