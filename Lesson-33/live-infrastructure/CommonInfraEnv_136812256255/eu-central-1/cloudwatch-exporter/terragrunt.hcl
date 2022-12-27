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
        "Federated": "arn:aws:iam::136812256255:oidc-provider/oidc.eks.eu-central-1.amazonaws.com/id/7E4A803ABEFE3796F5BA957462EF5AA7"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.eu-central-1.amazonaws.com/id/7E4A803ABEFE3796F5BA957462EF5AA7:aud": "sts.amazonaws.com",
          "oidc.eks.eu-central-1.amazonaws.com/id/7E4A803ABEFE3796F5BA957462EF5AA7:sub": "system:serviceaccount:infra-tools:prometheus-cloudwatch-exporter"
        }
      }
    }
  ]
}
EOF

}
