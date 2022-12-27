dependency "s3" {
  config_path = find_in_parent_folders("s3/exchange")

  mock_outputs = {
    s3_bucket_id = "temporary-id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "show"]
}

terraform {
  source = local.account_vars.sources_iam_policy
}

locals {
  name         = "${basename(get_terragrunt_dir())}"
  description  = "Policy to grant RW access to the `exchange` S3 bucket"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

iam_role = local.account_vars.iam_role

inputs = {
  name        = local.name
  path        = "/"
  description = local.description

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["${dependency.s3.outputs.s3_bucket_arn}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["${dependency.s3.outputs.s3_bucket_arn}/*"]
    }
  ]
}
EOF

  tags = local.tags_map
}
