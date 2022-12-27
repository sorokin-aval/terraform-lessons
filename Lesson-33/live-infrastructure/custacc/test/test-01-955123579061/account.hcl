# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.

locals {

  account_name   = "RBUA_custacc_test_01"
  aws_account_id = "955123579061"

  environment    = "test"
#                    LZ-RBUA_custacc_test_01-VPC
  vpc            = "vpc-0f6b77079caea81bb"
  domain         = "test.custacc.rbua"
  pca            = "arn:aws:acm-pca:eu-central-1:416957951464:certificate-authority/cb7a9ed0-af05-4593-a013-81c8858aa8ba"
  tags           = merge( read_terragrunt_config(find_in_parent_folders("group.hcl")).locals.tags, {
#  tags           = merge( read_terragrunt_config("domain.hcl").locals.tags, {
#            "security:environment" = "Test"
            "business:cost-center" = ".741."
            "internet-faced"       = "false"
  } )


  sources = {
      "host"     = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/host?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/payments/host")
      "ua-tf-aws-payments-host" = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-host.git//?ref=v1.0.1"
      "sg"       = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
  #    "acm"      = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/acm-certificate?ref=payments" : find_in_parent_folders("ua-avalaunch-terraform-modules/payments/acm-certificate")
      "vpc-info"         = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//vpc_info?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/vpc_info")
  }
}
iam_role = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
