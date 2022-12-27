# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  aws_account_id     = split("-", basename(get_terragrunt_dir()))[2]
  domain             = "prod.ro.rbua"
  environment_letter = "P"
  system             = "RO"
  environment        = "prod"
  iam_role = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"


  default_app_port = 8443
  otp_nlb_port     = 8443
  sms_nlb_port     = 9443
  iam_instance_profile_name = "AmazonSSMRoleForInstancesQuickSetup"

  tier1_subnets_list        = ["10.225.104.0/26"]
  tier1_subnet_abbr         = "TR"
  tier1_subnet_filter       = "*Transfer*"

  tier2_subnets_list        = ["10.225.104.64/26", "10.225.104.128/26"]
  tier2_subnet_abbr         = "IN"
  tier2_subnet_filter       = "*Internal*"

  tier3_subnets_list        = ["10.225.104.192/26"]
  tier3_subnet_abbr         = "RE"
  tier3_subnet_filter       = "*Restricted*"

  public_subnets_list           = ["100.100.43.160/27", "100.100.43.192/27"]
  rbua_private_aws_subnets_list = ["10.216.0.0/16", "10.223.0.0/16", "10.224.0.0/14", "10.215.0.0/16"]
  rbua_private_subnets_list     = ["10.184.0.0/13"]
  rbua_public_subnets_list      = ["185.84.148.0/23"]
  avalaunch_subnets_list        = ["10.225.124.0/22"]
  common_infra_subnets_list     = ["10.225.102.0/23"]
  db_subnets_list               = ["10.225.119.45/32"]
  ibm_mq_subnets_list           = ["10.226.118.52/32", "10.226.119.23/32", "10.191.5.150/32", "10.226.102.0/26"]
  activemq_subnets_list         = ["10.225.118.10/32", "10.225.118.9/32"]
  auth_subnets_list             = ["10.225.109.0/27"]
  ad_onprem_subnets_list        = ["10.191.199.200/32", "10.191.199.201/32", "10.191.199.202/32"]
  cloud_flare_subnets_list      = ["173.245.48.0/20", "103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "141.101.64.0/18", "108.162.192.0/18", "190.93.240.0/20", "188.114.96.0/20", "197.234.240.0/22", "198.41.128.0/17", "162.158.0.0/15", "104.16.0.0/13", "104.24.0.0/14", "172.64.0.0/13", "131.0.72.0/22"]
  security_subnets_list         = ["10.226.116.0/26"]
  sms_gw_vpn_subnets_list       = ["10.191.255.225/32"]
  smpp_gw_subnets_list          = ["185.46.88.47/32"]
  threemob_gw_vpn_subnets_list  = ["10.191.255.4/32"]
  gmsu_gw_vpn_subnets_list      = ["10.191.255.5/32"]
  kyivstar_gw_vpn_subnets_list  = ["10.191.255.6/32"]
  lifecell_gw_vpn_subnets_list  = ["10.191.255.7/32"]
  support_access_subnets_list   = ["10.190.50.32/27", "10.191.2.165/32", "10.190.62.128/26", "10.191.242.32/28"]
  syslog_servers_subnets_list   = ["10.226.114.72/32", "10.191.8.70/32"]
  inbound_db_subnets_list       = ["10.226.115.64/26", "10.226.115.128/26"]
  inbound_otp_subnets_list      = concat(local.rbua_private_subnets_list, local.avalaunch_subnets_list, local.ibm_mq_subnets_list, ["10.226.101.0/26", "10.226.138.5/32"])
  inbound_sms_subnets_list      = concat(local.rbua_private_subnets_list, local.avalaunch_subnets_list, local.ibm_mq_subnets_list, ["10.226.101.0/26"])
  inbound_auth_subnets_list     = local.ibm_mq_subnets_list
  db_onprem_subnets_list        = [ ]
  robotics_onprem_subnets_list  = [ ]

  tier1_subnets            = join(",", local.tier1_subnets_list)
  tier2_subnets            = join(",", local.tier2_subnets_list)
  tier3_subnets             = join(",", local.tier3_subnets_list)
  public_subnets           = join(",", local.public_subnets_list)
  rbua_private_aws_subnets = join(",", local.rbua_private_aws_subnets_list)
  rbua_private_subnets     = join(",", local.rbua_private_subnets_list)
  rbua_public_subnets      = join(",", local.rbua_public_subnets_list)
  avalaunch_subnets        = join(",", local.avalaunch_subnets_list)
  common_infra_subnets     = join(",", local.common_infra_subnets_list)
  db_subnets               = join(",", local.db_subnets_list)
  ibm_mq_subnets           = join(",", local.ibm_mq_subnets_list)
  activemq_subnets         = join(",", local.activemq_subnets_list)
  auth_subnets             = join(",", local.auth_subnets_list)
  ad_onprem_subnets        = join(",", local.ad_onprem_subnets_list)
  cloud_flare_subnets      = join(",", local.cloud_flare_subnets_list)
  security_subnets         = join(",", local.security_subnets_list)
  sms_gw_vpn_subnets       = join(",", local.sms_gw_vpn_subnets_list)
  smpp_gw_subnets          = join(",", local.smpp_gw_subnets_list)
  threemob_gw_vpn_subnets  = join(",", local.threemob_gw_vpn_subnets_list)
  gmsu_gw_vpn_subnets      = join(",", local.gmsu_gw_vpn_subnets_list)
  kyivstar_gw_vpn_subnets  = join(",", local.kyivstar_gw_vpn_subnets_list)
  lifecell_gw_vpn_subnets  = join(",", local.lifecell_gw_vpn_subnets_list)
  support_access_subnets   = join(",", local.support_access_subnets_list)
  syslog_servers_subnets   = join(",", local.syslog_servers_subnets_list)
  #inbound_db_subnets       = join(",", local.inbound_db_subnets_list)
  #inbound_otp_subnets      = join(",", local.inbound_otp_subnets_list)
  #inbound_sms_subnets      = join(",", local.inbound_sms_subnets_list)
  #inbound_auth_subnets     = join(",", local.inbound_auth_subnets_list)

  tag_map_migrated_console        = "d-server-003iyo9cz8wrhn"
  tag_map_migrated_ibank          = "d-server-01nn10reb2sw6l"
  tag_map_migrated_clientendpoint = "d-server-03023whdeg6hal"
  tag_map_migrated_otp            = "d-server-00wmuu5tr3zphl"
  tag_map_migrated_sms            = "d-server-00uhowidh9hduv"
  tag_map_migrated_auth           = "d-server-02l8l15xyllpl3"
  tag_map_migrated_oauth          = "d-server-03egn7dpz7f9fv"
  tag_map_migrated_backup         = "d-server-037wwz582i7fyp"

 
  #lb_targets_db_main = [
  #  { target_id = "10.225.112.22", availability_zone = "all" },
  #]

  sources_vpc_info           = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//vpc_info?ref=vpc_v1.0.1"
  sources_nacl               = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//vpc/network_acl?ref=v2.1.1"
  #sources_ec2_instance      = "github.com/terraform-aws-modules/terraform-aws-ec2-instance.git//wrappers?ref=v4.0.0"
  #sources_sg                = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
  #sources_lb                = "github.com/terraform-aws-modules/terraform-aws-alb.git//.?ref=v6.10.0"
  sources_s3_bucket          = "github.com/terraform-aws-modules/terraform-aws-s3-bucket.git//.?ref=v3.1.0"
  sources_route53_record     = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=v2.6.0"
  sources_route53_zone       = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/zones?ref=v2.6.0"
  sources_aws_backup_ec2     = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//aws-backup/ec2?ref=v2.1.1"
  sources_vpc_endpoints      = "github.com/terraform-aws-modules/terraform-aws-vpc.git//modules/vpc-endpoints?ref=v3.14.0"
  sources_iam_policy         = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=v5.2.0"
  sources_baseline	         = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//.?ref=v3.0.1"
  sources_iam_assumable_role = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role?ref=v4.24.1"
  sources_ami_management     = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-channels-ami-management.git//.?ref=v1.2.2"

  lb_public_tag_value    = "ro-public-alb"
  lb_public_host_headers = ["online.raiffeisen.ua"]
  lb_oauth_host_headers  = ["bankid.raiffeisen.ua"]

  dns_name_console      = "console-alb"

  l2support_ssm_user = "dbo"
}

