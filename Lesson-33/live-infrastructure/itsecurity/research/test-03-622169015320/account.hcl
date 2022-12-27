# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "Account for WAF and LB"
  aws_account_id = "622169015320"
  environment    = "test"
}
iam_role = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
