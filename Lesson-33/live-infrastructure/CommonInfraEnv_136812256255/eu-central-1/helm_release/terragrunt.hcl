include {
  path = "${find_in_parent_folders()}"
}
iam_role = local.account_vars.iam_role

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//helm_release"
}
locals {
  # Automatically load common variables from parent hcl
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  name          = "argo"
  namespace     = "kube-system"
  repository    = "https://nexus.avalaunch.aval/repository/helm-sre"
  chart         = "argo-cd"
  values        = file("argocd-values.yaml")
  chart_version = "3.26.1-1"
}
