locals {
  aws_account_id = "971249505352"
  ssh_key_name   = "platformOps"
}

iam_role = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"

