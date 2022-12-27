include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  # Hardcode!
  config_path = "../../alb-entrypoint-internal/imported-vpc/"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/zones?ref=v2.6.0"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags_map = local.common_tags.locals
  name      = "infra.prod.rbua"
}

inputs = {
  zones = {
    "infra.prod.rbua" = {
      comment = "Production zone for infrastructure"
      vpc = [
        {
          vpc_id = dependency.vpc.outputs.vpc_id
        }
      ]
      tags = local.tags_map
    },
    "cmd.prod.rbua" = {
      comment = "Production zone for CMD services"
      vpc = [
        {
          vpc_id = dependency.vpc.outputs.vpc_id
        }
      ]
      tags = local.tags_map
    },
    "odb.rbua" = {
        comment = "Production zone for ODB services"
        vpc = [
          {
            vpc_id = dependency.vpc.outputs.vpc_id
          }
        ]
        tags = local.tags_map
      }
    }
  }