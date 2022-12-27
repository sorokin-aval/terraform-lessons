terraform {
  source = local.account_vars.sources_iam_policy
}

locals {
  name             = "DescribeEC2"
  tags_map         = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  tags             = local.tags_map
}

iam_role = local.account_vars.iam_role

inputs = {
  name        = local.name
  path        = "/"
  description = "Policy allows describing instances for discovering Elasticsearch nodes on EC2. Created with Terragrunt"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:DescribeInstances"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF

  tags = local.tags_map

}