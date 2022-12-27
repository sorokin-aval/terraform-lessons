include {
  path = "${find_in_parent_folders()}"
}
iam_role = local.account_vars.iam_role

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//cloudwatch/iam_role"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  aws_account_id = local.account_vars.locals.aws_account_id
}

inputs = {
  ### Global configuration ###

trusted_entities_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::682969052504:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/AE80AAAFD499E3C68C1D62FDC1C21D61"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.eu-central-1.amazonaws.com/id/AE80AAAFD499E3C68C1D62FDC1C21D61:sub": "system:serviceaccount:infra-tools:prometheus-cloudwatch-exporter",
                    "oidc.eks.eu-central-1.amazonaws.com/id/AE80AAAFD499E3C68C1D62FDC1C21D61:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
}
EOF

}
