include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-assumable-roles?ref=v4.11.0"
}

locals {
  # Automatically load common tags from parent hcl
  common_tags = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  create_poweruser_role       = true
  poweruser_role_requires_mfa = false
  poweruser_role_name         = "PowerUser-External"

  trusted_role_arns = [
    "arn:aws:sts::159269109341:assumed-role/Admin/mariusz.ferdyn-external@rbinternational.com",
    "arn:aws:sts::159269109341:assumed-role/Admin/rajeev.kumar-external@rbinternational.com",
    "arn:aws:sts::159269109341:assumed-role/Admin/shashank.gupta-external@rbinternational.com",
    "arn:aws:sts::159269109341:assumed-role/Admin/srikanth.kakani-external@rbinternational.com",
    "arn:aws:sts::159269109341:assumed-role/Admin/sujeet.jha-external@rbinternational.com",
    "arn:aws:sts::159269109341:assumed-role/Admin/swapnil.daunde-external@rbinternational.com",
    "arn:aws:sts::159269109341:assumed-role/Admin/tejaswini.gorla-external@rbinternational.com",
    "arn:aws:sts::159269109341:assumed-role/Admin/tomasz.dragosz-external@rbinternational.com",
    "arn:aws:sts::159269109341:assumed-role/Admin/rohit.bhakare-external@rbinternational.com"
  ]

  poweruser_role_tags = merge(
    local.common_tags.locals,
    {
      confidentiality  = 3
      owner            = "AVALaunch team"
      application_role = "Access for Hitachi team"
    }
  )
}