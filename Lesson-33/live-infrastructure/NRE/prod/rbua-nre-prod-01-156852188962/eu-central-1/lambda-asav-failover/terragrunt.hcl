locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  name         = basename(get_terragrunt_dir())
}
terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-lambda.git//?ref=v4.0.2"
}

inputs = {
  function_name          = local.name
  role                   = "arn:aws:iam::156852188962:role/RBUA-Customizations/Lambda-ASAv-Failover-role"
  runtime                = "python3.8"
  timeout                = 30
  handler                = "lambda_function.lambda_handler"

  create_package         = true
  source_path            = ["src/lambda_function.py"]
}

