include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//cloudwatch/iam_role"
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
        "Federated": "arn:aws:iam::731824765966:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/4EB695BDD7A1CA4FB09E962C75FB90CA"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.eu-central-1.amazonaws.com/id/4EB695BDD7A1CA4FB09E962C75FB90CA:aud": "sts.amazonaws.com",
          "oidc.eks.eu-central-1.amazonaws.com/id/4EB695BDD7A1CA4FB09E962C75FB90CA:sub": "system:serviceaccount:infra-tools:prometheus-cloudwatch-exporter"
        }
      }
    }
  ]
}
EOF

}
