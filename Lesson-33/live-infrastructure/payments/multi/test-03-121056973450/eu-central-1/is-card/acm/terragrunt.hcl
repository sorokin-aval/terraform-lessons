include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/payments/_envcommon/acm.hcl"
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  certificates = {
    iscard = {
      domain_name = "is-card.${local.account_vars.locals.domain}"
    },
    vienna-iscard = {
      domain_name = "vienna.is-card.${local.account_vars.locals.domain}"
    },
  }
}
