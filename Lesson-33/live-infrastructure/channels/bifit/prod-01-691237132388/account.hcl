# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  aws_account_id      = "691237132388"
  domain              = "bifit.rbua"
  environment_letter  = "P"
  system              = "Bifit"
  environment         = "prod"
  iam_role            = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
  ccoe_ssm_iam_policy = "arn:aws:iam::${local.aws_account_id}:policy/servicecatalog-customers/CCOE-Mandatory-SSM-SessionPolicy"

  tier1_subnets_list   = ["10.226.105.0/26"]
  tier1_subnet_abbr    = "TR"
  tier1_subnet_filter  = "*Transfer*"

  tier2_subnets_list   = ["10.226.105.64/26", "10.226.105.128/26"]
  tier2_subnet_abbr    = "IN"
  tier2_subnet_filter  = "*Internal*"

  tier3_subnets_list   = ["10.226.105.192/26"]
  tier3_subnet_abbr    = "RT"
  tier3_subnet_filter  = "*Restricted*"

  account_subnets_list = ["10.226.105.0/24"]

  public_subnets_list           = ["100.100.27.32/27", "100.100.27.64/27"]
  rbua_private_aws_subnets_list = ["10.216.0.0/16", "10.223.0.0/16", "10.224.0.0/14", "10.215.0.0/16"]
  rbua_private_subnets_list     = ["10.184.0.0/13"]
  rbua_public_subnets_list      = ["185.84.148.0/23"]

  db_subnets_list             = ["10.191.253.0/25", "10.226.119.64/26", "10.226.118.64/26", "10.226.102.0/24"]
  db_tm_subnets_list		      = ["10.226.122.0/25", "10.191.12.85/32"]
  ibm_subnets_list		        = ["10.226.118.0/24", "10.226.119.0/24", "10.226.102.0/24", "10.191.5.150/32", "10.191.5.153/32"]
  barsep_subnets_list		      = ["10.225.112.64/26", "10.226.130.192/26", "10.226.131.0/24", "10.191.12.88/32"]
  ad_aws_subnets_list		      = ["10.225.109.0/27", "10.227.50.176/28", "10.227.50.192/28"]
  ad_subnets_list             = ["10.191.199.0/24"]
  bm_subnets_list		          = ["10.226.108.0/24", "10.191.12.130/32", "10.191.12.120/32"]
  messdb_subnets_list		      = ["10.191.253.0/25", "10.225.119.0/25"]
  fs_subnets_list             = ["10.226.41.0/24", "10.184.0.0/13", "10.226.108.0/23", "10.226.149.84/32"]
  cloud_flare_subnets_list    = ["173.245.48.0/20", "103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "141.101.64.0/18", "108.162.192.0/18", "190.93.240.0/20", "188.114.96.0/20", "197.234.240.0/22", "198.41.128.0/17", "162.158.0.0/15", "104.16.0.0/13", "104.24.0.0/14", "172.64.0.0/13", "131.0.72.0/22"]
  support_access_subnets_list = ["10.190.50.32/27", "10.191.242.32/28"]
  logstash_subnets_list       = ["10.226.105.64/26", "10.226.105.128/26", "10.226.154.0/24"]
  zabbix_subnets_list		      = ["10.225.102.0/24", "10.225.103.0/24"]
  infra_subnets_list          = ["10.225.102.0/23"]
  tech_support_subnets_list	  = ["10.191.49.192/26"]
  cyberark_subnets_list	      = ["10.191.242.32/28"]
  wininfra_subnets_list       = ["10.191.2.107/32"]
  user_private_subnets_list   = ["10.226.48.0/20"]

  tier1_subnets            = join(",", local.tier1_subnets_list)
  tier2_subnets            = join(",", local.tier2_subnets_list)
  tier3_subnets            = join(",", local.tier3_subnets_list)
  account_subnets	         = join(",", local.account_subnets_list)
  public_subnets           = join(",", local.public_subnets_list)
  rbua_private_aws_subnets = join(",", local.rbua_private_aws_subnets_list)
  rbua_private_subnets     = join(",", local.rbua_private_subnets_list)
  rbua_public_subnets      = join(",", local.rbua_public_subnets_list)
  db_subnets               = join(",", local.db_subnets_list)
  db_tm_subnets		         = join(",", local.db_tm_subnets_list)
  ad_aws_subnets	         = join(",", local.ad_aws_subnets_list)
  ad_subnets               = join(",", local.ad_subnets_list)
  ibm_subnets		           = join(",", local.ibm_subnets_list)
  barsep_subnets	         = join(",", local.barsep_subnets_list)
  bm_subnets		           = join(",", local.bm_subnets_list)
  messdb_subnets	         = join(",", local.messdb_subnets_list)
  fs_subnets		           = join(",", local.fs_subnets_list)
  cloud_flare_subnets      = join(",", local.cloud_flare_subnets_list)
  support_access_subnets   = join(",", local.support_access_subnets_list)
  logstash_subnets         = join(",", local.logstash_subnets_list)
  zabbix_subnets	         = join(",", local.zabbix_subnets_list)
  infra_subnets		         = join(",", local.infra_subnets_list)
  tech_support_subnets	   = join(",", local.tech_support_subnets_list)
  cyberark_subnets	       = join(",", local.cyberark_subnets_list)
  wininfra_subnets         = join(",", local.wininfra_subnets_list)
  user_private_pool        = join(",", local.user_private_subnets_list)

  l2support_ssm_user    = "ibank2ua"
  baseline_ref          = "v3.0.1"
  aws_win_patch_enabled = true

  sources_vpc_info       = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//vpc_info?ref=vpc_v1.0.1"
  sources_nacl           = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//vpc/network_acl?ref=v2.1.1"
  sources_sg             = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
  sources_iam_policy     = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=v5.2.0"
  sources_baseline	     = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//.?ref=${local.baseline_ref}"
  sources_s3_bucket      = "github.com/terraform-aws-modules/terraform-aws-s3-bucket.git//.?ref=v3.1.0"
  sources_iam_assumable_role = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role?ref=v4.24.1"
  sources_ami_management     = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-channels-ami-management.git//.?ref=v1.2.2"
}
