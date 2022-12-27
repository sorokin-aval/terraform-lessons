terraform {
  source = local.account_vars.locals.sources["sg"]
}

iam_role = "arn:aws:iam::${local.account_vars.locals.aws_account_id}:role/terraform-role"

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

locals {
  account_vars              = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map                  = read_terragrunt_config(find_in_parent_folders("project.hcl"))

  ip                        = [ "10.190.0.0/18", "10.190.124.0/25", "10.190.112.0/21"  ]
}


inputs = {
  name                      = "${upper(local.tags_map.locals.tags["business:product-project"])}: ${basename(get_terragrunt_dir())}"
  use_name_prefix           = false
  description               = "${upper(local.tags_map.locals.tags["business:product-project"])}: ${title(basename(get_terragrunt_dir()))} for VMView-VDI-Not-Isolated-Not-Test-net"
  vpc_id                    = dependency.vpc.outputs.vpc_id.id
  tags                      = local.tags_map.locals.tags

  ingress_cidr_blocks       = local.ip
  ingress_with_cidr_blocks  = [
    {
      from_port   = 9440
      to_port     = 9449
      protocol    = "tcp"
      description = "Api+Web"
    },
    {
      from_port   = 8080
      to_port     = 8089
      protocol    = "tcp"
      description = "HTTP"
    }
  ]
}