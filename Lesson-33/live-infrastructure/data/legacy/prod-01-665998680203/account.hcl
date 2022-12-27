# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "rbua-legacy-prod-01"
  aws_account_id = "665998680203"
  environment    = "prod"
}
# iam_role = "arn:aws:iam::665998680203:role/rbua-data-terraform"
iam_role = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
