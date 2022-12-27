terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  name = "AWSGluePolicy"
  path = "/"
  tags = merge(local.account_vars.locals.tags, { "Name" = "AWSGluePolicy" })

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:PassRole"
            ],
            "Resource": "arn:aws:iam::${local.account_vars.locals.aws_account_id}:role/Glue*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogStreams",
                "logs:FilterLogEvents",
                "logs:ListTagsLogGroup",
                "logs:DescribeSubscriptionFilters"
            ],
            "Resource": "arn:aws:logs:eu-central-1:${local.account_vars.locals.aws_account_id}:log-group:/aws-glue/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogGroups",
                "logs:DescribeQueryDefinitions",
                "logs:TestMetricFilter",
                "logs:PutMetricFilter",
                "logs:PutQueryDefinition"
            ],
            "Resource": "arn:aws:logs:eu-central-1:${local.account_vars.locals.aws_account_id}:log-group:*:log-stream:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:ListMetrics",
                "cloudwatch:GetDashboard",
                "cloudwatch:PutDashboard"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
