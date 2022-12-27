include {
  path = find_in_parent_folders()
}

# Hardcode!
dependency "vpc" {
  config_path = "../../../baseline"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v4.9.0"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  tags_map = local.common_tags.locals
  name      = "entrypoint-app.orion.test.loans.rbua"
}

inputs = {
  name = local.name
  description = "Security group for Application load balancer"
  vpc_id             = dependency.vpc.outputs.vpc_id.id
  tags = local.tags_map

  ingress_cidr_blocks      = ["0.0.0.0"]
  ingress_with_cidr_blocks = [
        {
            from_port   = 80
            to_port     = 80
            protocol    = "TCP"
            cidr_blocks = "10.0.0.0/8,100.100.17.99/32,185.84.148.4/32,100.100.17.178/32"
        },
        {
            from_port   = 443
            to_port     = 443
            protocol    = "TCP"
            cidr_blocks = "10.0.0.0/8,100.100.17.99/32,185.84.148.4/32,100.100.17.178/32"
        }
    ]
  egress_with_cidr_blocks = [
    {
      name = "All"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}