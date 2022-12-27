# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  aws_account_id = "022290515691"
  environment    = "dev"
}
iam_role = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
