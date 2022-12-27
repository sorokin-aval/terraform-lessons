terraform {
  source = local.account_vars.locals.sources["sg"]
}

iam_role = "arn:aws:iam::${local.account_vars.locals.aws_account_id}:role/terraform-role"

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

locals {
  account_vars            = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  tags_map                = read_terragrunt_config(find_in_parent_folders("project.hcl"))
}

inputs = {
  name                    = "${upper(local.tags_map.locals.tags["business:product-project"])}: ${basename(get_terragrunt_dir())}"
  use_name_prefix         = false
  description             = "${upper(local.tags_map.locals.tags["business:product-project"])}: security group for connection from DC hosts"
  vpc_id                  = dependency.vpc.outputs.vpc_id.id
  tags                    = local.tags_map.locals.tags

  ingress_cidr_blocks      = local.account_vars.locals.ips["dms_dc"]
  ingress_with_cidr_blocks = [
    {
      "description" = "All Incoming from DC hosts"
      "from_port"   = 0
      "to_port"     = 0
      "protocol"    = -1
    }
  ]
}