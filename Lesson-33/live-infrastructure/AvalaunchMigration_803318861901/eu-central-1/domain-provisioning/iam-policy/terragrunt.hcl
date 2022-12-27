include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

dependency "eks" {
  config_path = find_in_parent_folders("eks")
}

terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-policy?version=5.5.2"
}

locals {
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  tags_map     = local.common_tags.locals.common_tags
}

inputs = {
  name        = "AmazonEKSDomainProvisionGithubRunnerPolicy"
  description = "IAM Policy for domain-provisioning Github Runners which allows to describe EKS"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "eks:AccessKubernetesApi",
          "eks:DescribeCluster",
          "eks:ListClusters"
        ],
        "Resource": "${dependency.eks.outputs.cluster_arn}"
      }
    ]
  })

  tags = local.tags_map
}
