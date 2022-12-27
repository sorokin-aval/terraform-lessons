locals {
  aws_account_id = "323439214223"
}
iam_role = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"