## terragrunt.hcl
include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/global.hcl"
  expose = true
}

# terraform {
#   source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//payments/host?ref=payments/main"
# }

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-platform-host.git//?ref=main"
}

include {
  path = find_in_parent_folders()
}

include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "../../../core-infrastructure/imported-vpc/"
}

dependency "iam_role" {
  config_path  = "../../iam/iam_assumable_role/nifi/"
  mock_outputs = {
    iam_role_arn = "arn:aws:iam::${include.account.locals.aws_account_id}:role/mock_role_id"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  project_vars = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map     = local.project_vars.locals.project_tags
  name         = "${local.tags_map.Nwu}-${local.tags_map.Domain}-${local.tags_map.Environment}-nifi-01"
}

inputs = {
  name                         = local.name
  ami                          = "ami-0d482dcbbf08d1be0"
  instance_type                = "c5.xlarge"
  ebs_optimized                = true
  hosted_zone                  = "uat.data.rbua"
  subnet_id                    = dependency.vpc.outputs.app_subnets.ids[0]
  zone                         = "eu-central-1a"
  description                  = "The EC2 ${local.name} for ${local.tags_map.Project} team"
  vpc                          = dependency.vpc.outputs.vpc_id.id
  iam_instance_profile         = dependency.iam_role.outputs.iam_instance_profile_name
  create_iam_role_ssm          = false
  create_security_group_inline = true
  tags                         = local.tags_map
  metadata_options             = {
    http_tokens                 = "required"
    http_put_response_hop_limit = "1"
  }
}
