# Set list of tags that can be used in child configurations

locals {
  common_tags       = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  # Extract out common tags for reuse
  project_tags = merge(local.common_tags.locals.common_tags, { Project = "${basename(get_terragrunt_dir())}" })
  account_vars      = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  oidc_provider_arn = "arn:aws:iam::100515202040:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/50B3ECC53757FB3F3F908F7AC4F67057"

}
