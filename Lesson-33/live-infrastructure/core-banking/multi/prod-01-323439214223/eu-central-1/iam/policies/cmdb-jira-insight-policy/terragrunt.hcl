include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=v5.2.0"
}

iam_role = local.account_vars.iam_role

locals {
  #account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  name        = basename(get_terragrunt_dir())
  description = "CMDB readonly policy for trusted entries"
  aws_account_id = local.account_vars.locals.aws_account_id
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  #current_tags = read_terragrunt_config("tags.hcl")
  #local_tags_map = local.current_tags.locals

  common_tags     = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  common_tags_map = local.common_tags.locals

  tags_map = merge(local.common_tags_map)

}

inputs = {
  #create_policy=1

  name = local.name
  #path        = "/"
  description = local.description

  tags = local.tags_map

  policy = jsonencode(

    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "acm:List*",
            "acm:Describe*",
            "autoscaling:Describe*",
            "autoscaling-plans:Get*",
            "autoscaling-plans:Describe*",
            "apigateway:Get*",
            "application-autoscaling:Describe*",
            "budgets:ViewBudget",
            "ce:Get*",
            "ce:Describe*",
            "ce:List*",
            "cloudformation:Get*",
            "cloudformation:List*",
            "cloudformation:Describe*",
            "cloudtrail:List*",
            "cloudtrail:Describe*",
            "cloudwatch:List*",
            "cloudwatch:Describe*",
            "dynamodb:List*",
            "dynamodb:Describe*",
            "ec2:Describe*",
            "ecr:List*",
            "ecr:Describe*",
            "ecs:List*",
            "ecs:Describe*",
            "eks:List*",
            "eks:Describe*",
            "elasticbeanstalk:List*",
            "elasticbeanstalk:Describe*",
            "elasticache:List*",
            "elasticache:Describe*",
            "elasticloadbalancing:Describe*",
            "elasticbeanstalk:Describe*",
            "elasticbeanstalk:List*",
            "iam:List*",
            "iam:Get*",
            "kms:List*",
            "kms:Describe*",
            "lambda:List*",
            "logs:List*",
            "logs:Describe*",
            "rds:List*",
            "rds:Describe*",
            "route53:List*",
            "s3:List*",
            "s3:Describe*",
            "s3:Get*",
            "savingsplans:Describe*",
            "ssm:List*",
            "ssm:Describe*",
            "ssm:Get*",
            "ssm:Send*",
            "sns:List*",
            "sns:Get*",
            "sqs:Get*",
            "sqs:List*",
            "workspaces:List*",
            "workspaces:Describe*",
            "xray:Get*",
            "sts:AssumeRole"
          ],
          "Resource" : "*"
        }
      ]
    }
  )

}

