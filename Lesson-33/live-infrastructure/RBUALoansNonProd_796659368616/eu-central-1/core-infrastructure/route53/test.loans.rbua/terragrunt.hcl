include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  # Hardcode!
  config_path = "../../baseline/"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/zones?ref=v2.6.0"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags_map = local.common_tags.locals
}

inputs = {
  zones = {
    "test.loans.rbua" = {
      comment = "Production zone for test loans workloads"
      vpc = [
        {
          vpc_id = dependency.vpc.outputs.vpc_id.id
        }
      ]
      tags = local.tags_map
    }
  }
}