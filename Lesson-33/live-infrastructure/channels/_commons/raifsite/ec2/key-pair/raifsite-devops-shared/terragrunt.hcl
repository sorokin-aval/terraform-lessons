terraform {
  source = local.account_vars.sources_ec2_key_pair
}

iam_role = local.account_vars.iam_role

locals {
  name         = "raifsite-devops-shared"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

inputs = {
  key_name   = local.name
  public_key = local.account_vars.ssh_key_devops_pub
  tags       = merge(local.tags_map, { Name = local.name })
}
