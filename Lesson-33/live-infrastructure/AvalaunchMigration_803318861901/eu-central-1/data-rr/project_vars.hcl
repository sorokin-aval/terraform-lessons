# Set list of tags that can be used in child configurations

locals {
  tags         = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  common_tags  = local.tags.locals.common_tags
  # Extract out common tags for reuse
  project_tags = merge(local.common_tags,
    {
      Project                      = "${basename(get_terragrunt_dir())}",
      domain                       = "Data",
      BusinessUnit                 = "DataDomain",
      owner                        = "DataDomain",
      "business:emergency-contact" = "it.dataops@raiffeisen.ua",
      "business:cost-center"       = "0825",
      product                      = "${basename(get_terragrunt_dir())}",
      "ea:shared-service"          = false,
      "business:product-owner"     = "sergii.ovsenko@raiffeisen.ua",
      "business:product-project"   = "data-rr",
      "business:team"              = "data-rr"
    })
  account_vars    = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  resource_prefix = lower("${local.project_tags.entity}-${local.project_tags.domain}-${local.project_tags["security:environment"]}")
  project_prefix  = lower("${local.resource_prefix}-${local.project_tags.Project}")
  kms_key         = "arn:aws:kms:eu-central-1:100515202040:key/53593844-89ad-48a9-ab15-1db749f745e8"
}
