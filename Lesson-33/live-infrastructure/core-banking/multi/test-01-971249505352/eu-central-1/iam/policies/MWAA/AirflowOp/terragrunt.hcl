include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=v5.2.0"
}

iam_role = local.account_vars.iam_role

locals {
  aws_account_id = local.account_vars.locals.aws_account_id
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  airflow_role = "Op"
  description = "policy for the Apache Airflow"


  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  name = basename(get_terragrunt_dir())

  current_tags = read_terragrunt_config("tags.hcl")
  local_tags_map = local.current_tags.locals

  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  common_tags_map = local.common_tags.locals

  tags_map = merge(local.common_tags_map, local.local_tags_map)

}

inputs = {
  create_policy=1

  name        = local.name
  path        = "/"
  description = local.description

  tags = local.tags_map

  policy = jsonencode(

  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": "airflow:CreateWebLoginToken",
              "Resource": [
                  format("arn:aws:airflow:%s:%d:role/%s/%s",
                         local.env_vars.locals.region_vars.locals.aws_region,
                         local.env_vars.locals.account_vars.locals.aws_account_id,
                         local.env_vars.locals.env_name,
                         local.airflow_role
                        )
              ]
          }
      ]
  }
)

}
