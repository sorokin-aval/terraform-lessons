# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "CyberSecurity_General_Prod_04"
  aws_account_id = "508566973729"
  environment    = "prod"
}
