dependency "s3" {
  config_path = find_in_parent_folders("s3")
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  domain_vars  = read_terragrunt_config(find_in_parent_folders("domain.hcl"))
  name         = basename(find_in_parent_folders("comm-vault"))
}

inputs = {
  name = local.name
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectRetention",
        "s3:PutObjectTagging",
        "s3:ListBucket",
        "s3:ListAllMyBuckets",
        "s3:DeleteObject",
        "s3:DeleteObjectVersion"
      ],
      "Resource": ["${dependency.s3.outputs.s3_bucket_arn}", "${dependency.s3.outputs.s3_bucket_arn}/*"]
    }
  ]
}
EOF

  tags = merge(local.account_vars.locals.tags,
    local.domain_vars.locals.common_tags,
    { map-migrated = "d-server-00sj1xhbfx35r4" })
}
