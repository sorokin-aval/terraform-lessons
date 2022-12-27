locals {
  aws_account_id     = split("-", basename(get_terragrunt_dir()))[2]
  domain             = "sandbox.channels.rbua"
  environment_letter = "s"
  system             = "Common"
  environment        = "sandbox"

  tier1_subnets_list        = ["10.226.120.0/25"]
  tier1_subnet_abbr         = "TR"
  tier1_subnet_filter       = "*Transfer*"

  tier2_subnets_list        = ["10.226.120.128/25", "10.226.121.0/25"]
  tier2_subnet_abbr         = "IN"
  tier2_subnet_filter       = "*Internal*"

  tier3_subnets_list        = ["10.226.121.128/25"]
  tier3_subnet_abbr         = "RT"
  tier3_subnet_filter       = "*Restricted*"

  tier1_subnets            = join(",", local.tier1_subnets_list)
  tier2_subnets            = join(",", local.tier2_subnets_list)
  tier3_subnets            = join(",", local.tier3_subnets_list)

  sources_vpc_info        = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//vpc_info?ref=vpc_v1.0.1"
  sources_baseline	      = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//.?ref=v3.0.1"
}