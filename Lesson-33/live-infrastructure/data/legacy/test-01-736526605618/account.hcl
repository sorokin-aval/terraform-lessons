# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "rbua-legacy-test-01"
  aws_account_id = "736526605618"
  environment    = "test"
}
#iam_role = "arn:aws:iam::736526605618:role/rbua-data-terraform"
iam_role = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
