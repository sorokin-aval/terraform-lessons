terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role-with-saml"
}

dependency "policy" {
  config_path = find_in_parent_folders("policy")
}

dependencies {
  paths = [find_in_parent_folders("policy")]
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  create_role = true

  role_name        = "GlueAdmin"
  role_path        = "/"
  role_policy_arns = [
    dependency.policy.outputs.arn, 
    "arn:aws:iam::aws:policy/AmazonAthenaFullAccess", 
    "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess", 
    "arn:aws:iam::aws:policy/AwsGlueDataBrewFullAccessPolicy", 
    "arn:aws:iam::aws:policy/AWSGlueSchemaRegistryFullAccess", 
    "arn:aws:iam::aws:policy/AmazonSNSFullAccess", 
    "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess", 
    "arn:aws:iam::aws:policy/AmazonEventBridgeSchemasFullAccess"
  ]
  provider_id      = "arn:aws:iam::${local.account_vars.locals.aws_account_id}:saml-provider/RBI-PingFederate"

  tags = local.account_vars.locals.tags
}
