include {
  path = "${find_in_parent_folders()}"
}
include "account" {
  path = find_in_parent_folders("account.hcl")
}
terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}


locals {
  # Automatically load common variables from parent hcl
  project_vars   = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars    = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  tags_map       = local.project_vars.locals.project_tags
  aws_account_id = local.account_vars.locals.aws_account_id
}


inputs = {
  create_role           = true
  role_name             = "ebs-csi"
  attach_ebs_csi_policy = true
  description           = "${basename(get_terragrunt_dir())} policy. Created with Terragrunt"
  # need to extra attach policy arn:aws:iam::100515202040:policy/KMS_Key_For_Encryption_On_EBS_Policy
  oidc_providers        = {
    ex = {
      provider_arn               = local.project_vars.locals.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
  tags = local.tags_map

}
