# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name            = "rbua-draif-prod-01"
  aws_account_id          = "100515202040"
  environment             = "prod"
  oidc_avalaunch_prod_arn = "arn:aws:iam::100515202040:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/E0C85E2520E6340F9069F48CF5A6FC1C"
  oidc_data_prod_arn      = "https://oidc.eks.eu-central-1.amazonaws.com/id/50B3ECC53757FB3F3F908F7AC4F67057"
  glue_kms_key   = "arn:aws:kms:eu-central-1:100515202040:key/44cb0f7e-7d73-43fb-aef0-dad32929ac3e"
}
iam_role = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
