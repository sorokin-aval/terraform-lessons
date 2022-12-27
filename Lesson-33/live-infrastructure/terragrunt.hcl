terraform_version_constraint = "~> 1.0"

locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract the variables we need for easy access
  account_id = local.account_vars.locals.aws_account_id
  aws_region = local.region_vars.locals.aws_region

  # Define IAM role ARN for the remote state
  # Check if local remote_state_iam_role_name exists in iam.hcl file
  remote_state_iam_role_name   = try(read_terragrunt_config("iam.hcl").locals.remote_state_iam_role_name, "")
  remote_state_iam_role_option = local.remote_state_iam_role_name != "" ? { role_arn = "arn:aws:iam::${local.account_id}:role/${local.remote_state_iam_role_name}" } : {}

  remote_state_config = merge(
    {
      bucket         = "terraform-state-${local.account_id}-${local.aws_region}"
      key            = "${path_relative_to_include()}/terraform.tfstate"
      region         = local.aws_region
      encrypt        = true
      dynamodb_table = "terraform-locks"
    },
    local.remote_state_iam_role_option
  )
}

# Automatically set AWS region everywhere
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.aws_region}"
    }
  EOF
}

# Terragrunt configuration to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"

  config = local.remote_state_config

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Global variables that will be applied to all child configurations via the include block
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
)
