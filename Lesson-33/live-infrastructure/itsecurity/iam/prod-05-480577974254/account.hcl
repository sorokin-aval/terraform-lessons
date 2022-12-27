# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "CyberSecurity_IAM_Prod_05"
  aws_account_id = "480577974254"
  environment    = "prod"
}
iam_role = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
