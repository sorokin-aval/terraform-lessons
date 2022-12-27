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
        "Federated": "arn:aws:iam::803318861901:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/E0C85E2520E6340F9069F48CF5A6FC1C"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.eu-central-1.amazonaws.com/id/E0C85E2520E6340F9069F48CF5A6FC1C:aud": "sts.amazonaws.com",
          "oidc.eks.eu-central-1.amazonaws.com/id/E0C85E2520E6340F9069F48CF5A6FC1C:sub": "system:serviceaccount:infra-tools:prometheus-cloudwatch-exporter"
        }
      }
    }
  ]
}
EOF

}
