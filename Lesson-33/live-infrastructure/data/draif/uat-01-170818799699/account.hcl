# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "rbua-draif-test-01"
  aws_account_id = "170818799699"
  environment    = "uat"
}
iam_role = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
