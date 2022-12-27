include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "${local.source_map.source_base_url}//modules/iam-assumable-role?ref=${local.source_map.ref}"
}

iam_role = local.account_vars.iam_role

locals {
  # Automatically load common variables from parent hcl
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars  = read_terragrunt_config(find_in_parent_folders("source.hcl"))

  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  tags_map       = local.common_tags.locals
  aws_account_id = local.account_vars.locals.aws_account_id
  module_tags = {
    Name             = "${basename(get_terragrunt_dir())}"
    application_role = "IAM Assumable Role"
  }
  role_name = "${basename(get_terragrunt_dir())}"
}

dependency "cloudwatch_exporter_iam_policy" {
  config_path = "../../iam-policy/CloudwatchExporterEC2Policy"
  mock_outputs = {
    arn = "arn:aws:iam::aws:policy/DummyPolicy"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "fmt", "show"]
}

inputs = {
  create_role             = true
  create_instance_profile = true
  role_name               = local.role_name
  role_description        = "This role provides access to CloudWatch metrics on any our AWS account for Cloudwatch exporter's EC2 instance"
  tags                    = merge(local.module_tags, local.tags_map)
  role_requires_mfa       = false
  trusted_role_arns       = []
  trusted_role_services = [
    "ec2.amazonaws.com"
  ]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::${local.aws_account_id}:policy/servicecatalog-customers/CCOE-Mandatory-SSM-SessionPolicy",
    dependency.cloudwatch_exporter_iam_policy.outputs.arn
  ]
}
