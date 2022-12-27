include {
  path = "${find_in_parent_folders()}"
}
include "account" {
  path = find_in_parent_folders("account.hcl")
}

terraform {
  source = "${local.source_map.source_base_url}?ref=${local.source_map.ref}"
}

locals {
  project_vars   = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  source_vars    = read_terragrunt_config(find_in_parent_folders("source.hcl"))
  # Extract out exact variables for reuse
  source_map     = local.source_vars.locals
  tags_map       = local.project_vars.locals.project_tags
  aws_account_id = local.account_vars.locals.aws_account_id
  layer          = "integration"
}

inputs = {
  name        = "${local.project_vars.locals.resource_prefix}-${basename(get_terragrunt_dir())}"
  path        = "/"
  description = "${basename(get_terragrunt_dir())} policy. Created with Terragrunt. Used by Dynatrace"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "athena:ListWorkGroups",
                "autoscaling:DescribeAutoScalingGroups",
                "cloudformation:ListStackResources",
                "cloudwatch:GetMetricData",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics",
                "dynamodb:ListTables",
                "dynamodb:ListTagsOfResource",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInstances",
                "ec2:DescribeNatGateways",
                "ec2:DescribeSpotFleetRequests",
                "ec2:DescribeTransitGateways",
                "ec2:DescribeVolumes",
                "ec2:DescribeVpnConnections",
                "elasticloadbalancing:DescribeInstanceHealth",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeTags",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticmapreduce:ListClusters",
                "events:ListEventBuses",
                "glue:GetJobs",
                "inspector:ListAssessmentTemplates",
                "lambda:ListFunctions",
                "lambda:ListTags",
                "logs:DescribeLogGroups",
                "opsworks:DescribeStacks",
                "rds:DescribeDBClusters",
                "rds:DescribeDBInstances",
                "rds:DescribeEvents",
                "rds:ListTagsForResource",
                "route53:ListHostedZones",
                "s3:ListAllMyBuckets",
                "sns:ListTopics",
                "sqs:ListQueues",
                "sts:GetCallerIdentity",
                "tag:GetResources",
                "tag:GetTagKeys"
            ],
            "Resource": "*"
        }
    ]
}
EOF

  tags = local.tags_map

}
