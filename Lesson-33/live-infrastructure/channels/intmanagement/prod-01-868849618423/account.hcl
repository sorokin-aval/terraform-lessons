locals {
  aws_account_id     = split("-", basename(get_terragrunt_dir()))[2]
  domain             = "channels.rbua"
  environment_letter = "p"
  system             = "IntManagement"
  environment        = "prod"

  tier1_subnets_list        = ["10.226.154.0/26"]
  tier1_subnet_abbr         = "TR"
  tier1_subnet_filter       = "*Transfer*"

  tier2_subnets_list        = ["10.226.154.64/26"]
  tier2_subnet_abbr         = "IN"
  tier2_subnet_filter       = "*Internal*"

  tier1_subnets            = join(",", local.tier1_subnets_list)
  tier2_subnets            = join(",", local.tier2_subnets_list)

  sources_vpc_info         = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//vpc_info?ref=vpc_v1.0.1"
  sources_baseline	       = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//.?ref=v3.0.1"
}