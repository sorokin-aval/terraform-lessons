# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "CyberSecurity_Monitoring_Prod_06"
  aws_account_id = "315001930005"
  environment    = "prod"
}
iam_role = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
