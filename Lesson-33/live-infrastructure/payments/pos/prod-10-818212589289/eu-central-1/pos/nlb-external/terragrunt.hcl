include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "envcommon" {
  path = find_in_parent_folders("_envcommon/pos/nlb-external.hcl")
}

locals {
  app_vars = read_terragrunt_config(find_in_parent_folders("application.hcl"))
}

# ---------------------------------------------------------------------------------------------------------------------
# Override parameters for this environment
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  subnets  = ["subnet-088ab769bf22ffd45", "subnet-02daeb6d620269a24"] # dependency.vpc.outputs.public_subnets.ids changed due to "This object does not have an attribute named "public_subnets" error
}