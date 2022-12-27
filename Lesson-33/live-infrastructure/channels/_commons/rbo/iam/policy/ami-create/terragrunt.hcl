terraform {
  source = local.account_vars.sources_iam_policy
}

locals {
  name             = "L2Support-CreateAMI"
  tags_map         = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  tags             = local.tags_map
}

iam_role = local.account_vars.iam_role

inputs = {
  name        = local.name
  path        = "/"
  description = "Policy allows AMI creation by L2support. Created with Terragrunt"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags",
                "ec2:CreateSnapshots",
                "ec2:CreateSnapshot",
                "ec2:CreateImage"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:instance/*",
                "arn:aws:ec2:*::snapshot/*",
                "arn:aws:ec2:*:*:volume/*",
                "arn:aws:ec2:*::image/*"
            ]
        }
    ]
}
EOF

  tags = local.tags_map

}
