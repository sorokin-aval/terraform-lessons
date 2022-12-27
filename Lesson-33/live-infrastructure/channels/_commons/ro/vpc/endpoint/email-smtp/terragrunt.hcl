dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

dependency "sg" {
  config_path = find_in_parent_folders("sg/vpc-endpoint-email-smtp")
}

terraform {
  source = local.account_vars.sources_vpc_endpoints
}

locals {
  name         = "VPC-Endpoint-Email-SMTP"
  subnet       = "app"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

# email-smtp.eu-central-1.amazonaws.com
inputs = {
  vpc_id             = dependency.vpc.outputs.vpc_id.id
  tags               = merge(local.tags_map, { Name = local.name })
  security_group_ids = [dependency.sg.outputs.security_group_id]
  subnet_ids         = dependency.vpc.outputs["${local.subnet}_subnets"].ids

  endpoints = {
    email-smtp = {
      service             = "email-smtp"
      private_dns_enabled = true
    },
  }
}
