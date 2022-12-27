include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}
terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//private-link-provider?ref=provider_v0.0.1"
}

inputs = {
  name           = "rancher-cluster-vpces"
  nlb_arns       = ["arn:aws:elasticloadbalancing:eu-central-1:136812256255:loadbalancer/net/k8s-ingressn-ingressn-f3c4b8fea9/a850664c7dbc54e9"]
  description    = "VPC Endpoint Service for Rancher cluster"

  # Optional
  allowed_principals  = [
    "arn:aws:iam::682969052504:root",
    "arn:aws:iam::220153379415:root",
    "arn:aws:iam::858877166563:root",
    "arn:aws:iam::115292379528:root",
    "arn:aws:iam::731824765966:root",
    "arn:aws:iam::803318861901:root",
  ]
  acceptance_required = false
}
