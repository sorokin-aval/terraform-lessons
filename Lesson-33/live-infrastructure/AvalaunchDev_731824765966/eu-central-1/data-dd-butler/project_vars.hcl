# Set list of tags that can be used in child configurations

locals {
  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  # Extract out common tags for reuse
  project_tags = merge(local.common_tags.locals,
    {
      Project      = "${basename(get_terragrunt_dir())}",
      Domain       = "data",
      BusinessUnit = "DataDomain",
      owner        = "DataDomain",
      Tech_domain  = "data-dd-butler",
      Environment  = "uat",
      Nwu          = "rbua"
  })
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}
