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
    pte = {
      domain_name = "pte.${local.account_vars.locals.domain}"
    },
    vpos = {
      domain_name = "vpos.${local.account_vars.locals.domain}"
    },
  }
}