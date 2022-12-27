include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "git::https://gitlab.devops.aval/sre/terraform-modules.git//thanos"
}

locals {
  # Automatically load common variables from parent hcl
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out exact variables for reuse
  env          = local.account_vars.locals.environment
  tags_map     = local.common_tags.locals
}

inputs = {
  ### Global configuration ###
  zone                              = "prod"
  component_name                    = "thanos"

  ### S3 configuration ###
  s3_bucket_force_destroy           = false
  s3_bucket_acl                     = "private"

  ### EKS target cluster role
  ### You can find it in module.eks.worker_iam_role_name output
  worker_iam_role                   = "common-infrastructure20210723114609039300000003"
}
