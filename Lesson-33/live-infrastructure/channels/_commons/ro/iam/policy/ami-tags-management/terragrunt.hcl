terraform {
  source = local.account_vars.sources_iam_policy
}

locals {
  name             = "L2Support-EnableTagging4AMImanagement"
  tags_map         = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  tags             = local.tags_map
}

iam_role = local.account_vars.iam_role

inputs = {
  name        = local.name
  path        = "/"
  description = "Policy allows adding and removing of certain tags for AMI by L2support. Created with Terragrunt"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
          "Sid": "EnableTagging4AMImanagement",
          "Effect": "Allow",
          "Action": [
              "ec2:DeleteTags",
              "ec2:CreateTags"
          ],
          "Resource": [
              "arn:aws:ec2:*:*:instance/*"
          ],
          "Condition": {
              "ForAllValues:StringEquals": {
                  "aws:TagKeys": [
                      "ami-policy",
                      "ami-retention-count",
                      "ami-expiration-days"
                  ]
              }
          }
      }
    ]
}
EOF

  tags = local.tags_map

}