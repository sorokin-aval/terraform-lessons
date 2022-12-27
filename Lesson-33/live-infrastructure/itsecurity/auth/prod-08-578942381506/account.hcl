# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configurations.
locals {
  account_name   = "CyberSecurity_Auth_Prod_08"
  aws_account_id = "578942381506"
  environment    = "prod"
}
iam_role = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
