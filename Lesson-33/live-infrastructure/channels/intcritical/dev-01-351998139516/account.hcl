# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  aws_account_id = split("-", basename(get_terragrunt_dir()))[2]
  environment    = "dev"
  iam_role       = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"

  aws_win_patch_enabled = true
  baseline_ref          = "v3.0.1"

  sources_iam_policy     = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=v5.2.0"
  sources_baseline       = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//.?ref=${local.baseline_ref}"
  sources_ami_management = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-channels-ami-management.git//.?ref=v1.2.2"
}
