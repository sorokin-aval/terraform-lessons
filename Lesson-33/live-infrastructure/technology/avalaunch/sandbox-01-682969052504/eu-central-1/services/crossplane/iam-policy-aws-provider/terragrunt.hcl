include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  tags_map = local.common_tags.locals

  name = "crossplane-aws-provider"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:*",
          "rds:*",
          "iam:*",
          "ec2:*SecurityGroup*",
          "ec2:DeleteTags",
          "ec2:CreateTags",
          "elasticache:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=v5.0.0"
}

inputs = {
  name        = local.name
  description = "IAM policy using by crossaple aws provider to manage AWS resources"

  policy = local.policy
}