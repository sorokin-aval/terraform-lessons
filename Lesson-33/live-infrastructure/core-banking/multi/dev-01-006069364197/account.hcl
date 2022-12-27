locals {
  aws_account_id = "006069364197"
}
iam_role = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
