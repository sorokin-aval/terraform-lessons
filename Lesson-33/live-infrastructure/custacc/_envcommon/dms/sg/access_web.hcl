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

  ip                        = [ "10.190.40.0/23", "10.190.42.0/23", "10.190.44.0/23", "10.190.46.0/23", "10.190.56.0/22", "10.190.114.0/23", "10.190.190.128/27", "10.226.48.0/20" ]
}


inputs = {
  name                      = "${upper(local.tags_map.locals.tags["business:product-project"])}: ${basename(get_terragrunt_dir())}"
  use_name_prefix           = false
  description               = "${upper(local.tags_map.locals.tags["business:product-project"])}: ${title(basename(get_terragrunt_dir()))}"
  vpc_id                    = dependency.vpc.outputs.vpc_id.id
  tags                      = local.tags_map.locals.tags

  ingress_cidr_blocks       = local.ip
  ingress_with_cidr_blocks  = [
    {
      from_port   = 9082
      to_port     = 9082
      protocol    = "tcp"
      description = "Api+Web"
    }
  ]
}