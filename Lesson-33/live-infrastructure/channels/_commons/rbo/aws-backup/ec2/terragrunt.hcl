terraform {
  source = local.account_vars.sources_aws_backup_ec2
}

locals {
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

iam_role = local.account_vars.iam_role

inputs = {
  tags = merge(local.tags_map, { application_role = "AWS_Backup", map-migrated = local.account_vars.tag_map_migrated_backup } )
}
