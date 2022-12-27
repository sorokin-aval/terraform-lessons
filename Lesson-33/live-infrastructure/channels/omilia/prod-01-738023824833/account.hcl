locals {
  aws_account_id     = split("-", basename(get_terragrunt_dir()))[2]
  environment_letter = "P"
  iam_role           = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"

  baseline_ref          = "v3.0.1"
  aws_win_patch_enabled = false

  sources_baseline = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//.?ref=${local.baseline_ref}"
}
