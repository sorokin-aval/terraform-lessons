include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

# Hardcode!
dependency "vpc" {
  config_path = "../../imported-vpc"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v4.9.0"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map     = local.common_tags.locals
  name         = local.common_tags.locals.Name
}

inputs = {
  name        = local.name
  description = "Security group for main ALB used by application"
  vpc_id      = dependency.vpc.outputs.vpc_id
  tags        = local.tags_map

  ingress_cidr_blocks = ["0.0.0.0"]
  ingress_with_cidr_blocks = [
    {
      name        = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      name        = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      name        = "All"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}
