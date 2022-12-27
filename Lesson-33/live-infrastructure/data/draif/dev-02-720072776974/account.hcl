# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "rbua-draif-dev-02"
  aws_account_id = "720072776974"
  environment    = "dev"
}
iam_role = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
