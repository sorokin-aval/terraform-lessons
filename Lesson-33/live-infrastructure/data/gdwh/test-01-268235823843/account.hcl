# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "rbua-gdwh-test-01"
  aws_account_id = "268235823843"
  environment    = "test"
}
iam_role = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
