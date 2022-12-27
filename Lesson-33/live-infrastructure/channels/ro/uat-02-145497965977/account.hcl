locals {
  aws_account_id     = split("-", basename(get_terragrunt_dir()))[2]
  domain             = "uat.ro.rbua"
  environment_letter = "u"
  system             = "RO"
  environment        = "uat"
  iam_role           = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"

  tier1_subnets_list        = ["10.225.105.0/26"]
  tier1_subnet_abbr         = "TR"
  tier1_subnet_filter       = "*Transfer*"

  tier2_subnets_list        = ["10.225.105.64/26", "10.225.105.128/26"]
  tier2_subnet_abbr         = "IN"
  tier2_subnet_filter       = "*Internal*"

  tier3_subnets_list        = ["10.225.105.192/26"]
  tier3_subnet_abbr         = "RT"
  tier3_subnet_filter       = "*Restricted*"

  tier1_subnets            = join(",", local.tier1_subnets_list)
  tier2_subnets            = join(",", local.tier2_subnets_list)
  tier3_subnets            = join(",", local.tier2_subnets_list)

  tag_map_migrated_console        = "d-server-003iyo9cz8wrhn"
  tag_map_migrated_ibank          = "d-server-01nn10reb2sw6l"
  tag_map_migrated_clientendpoint = "d-server-03023whdeg6hal"
  tag_map_migrated_otp            = "d-server-00wmuu5tr3zphl"
  tag_map_migrated_sms            = "d-server-00uhowidh9hduv"
  tag_map_migrated_auth           = "d-server-02l8l15xyllpl3"
  tag_map_migrated_oauth          = "d-server-03egn7dpz7f9fv"
  tag_map_migrated_backup         = "d-server-037wwz582i7fyp"

  sources_vpc_info           = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//vpc_info?ref=vpc_v1.0.1"
  sources_iam_policy         = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=v5.2.0"
  sources_baseline	         = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//.?ref=v3.0.1"
  sources_s3_bucket          = "github.com/terraform-aws-modules/terraform-aws-s3-bucket.git//.?ref=v3.1.0"
  sources_iam_assumable_role = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role?ref=v4.24.1"
  sources_ami_management     = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-channels-ami-management.git//.?ref=v1.2.2"

  l2support_ssm_user = "dbo"
}