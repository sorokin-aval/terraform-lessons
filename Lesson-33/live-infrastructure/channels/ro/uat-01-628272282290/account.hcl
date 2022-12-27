# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  aws_account_id     = split("-", basename(get_terragrunt_dir()))[2]
  domain             = "dev-ro.avalaunch.aval"
  environment_letter = "U"
  system             = "RO"
  environment        = "uat"

  default_app_port = 8443
  otp_nlb_port     = 8443
  sms_nlb_port     = 9443
  lb_ssl_cert_arn  = "arn:aws:acm:eu-central-1:628272282290:certificate/f9d3e410-e0d9-40e9-a573-b85e3e2b3c5d"
  ssh_key_name     = "channels_devops_shared"
  iam_instance_profile_name = "AmazonSSMRoleForInstancesQuickSetup"
  appdyn_conf_path_prefix   = "/DBO"
  iam_role           = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"

  tier1_subnets_list        = ["10.225.99.0/24"]
  tier1_subnet_abbr         = "TR"
  tier1_subnet_filter       = "*Transfer*"

  tier2_subnets_list        = ["10.225.98.0/24"]
  tier2_subnet_abbr         = "IN"
  tier2_subnet_filter       = "*Internal*"

  public_subnets_list           = ["100.100.19.64/26", "100.100.19.128/26"]
  rbua_private_aws_subnets_list = ["10.216.0.0/16", "10.223.0.0/16", "10.224.0.0/14", "10.215.0.0/16"]
  rbua_private_subnets_list     = ["10.184.0.0/13"]
  rbua_public_subnets_list      = ["185.84.148.0/23"]
  avalaunch_subnets_list        = ["10.225.120.0/22"]
  common_infra_subnets_list     = ["10.225.102.0/23"]
  db_subnets_list               = ["10.225.98.116/32", "10.225.98.53/32"]
  ibm_mq_subnets_list           = ["10.191.196.60/32", "10.226.119.162/32"]
  activemq_subnets_list         = ["10.225.106.90/32", "10.225.106.169/32"]
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
  support_access_subnets_list   = ["10.190.133.0/24", "10.190.134.0/26", "10.191.196.64/32", "10.191.2.165/32", "10.191.208.0/20", "10.191.242.32/28", "10.190.62.128/26", "10.197.28.21/32", "10.197.28.213/32"]
  syslog_servers_subnets_list   = ["10.226.114.72/32", "10.191.8.70/32"]
  logstash_subnets_list         = local.tier2_subnets_list
  inbound_db_subnets_list       = ["10.226.115.64/26", "10.226.115.128/26"]
  inbound_otp_subnets_list      = concat(local.rbua_private_subnets_list, local.avalaunch_subnets_list, ["10.226.100.0/26", "10.227.37.0/24"])
  inbound_sms_subnets_list      = concat(local.rbua_private_subnets_list, local.avalaunch_subnets_list, ["10.226.100.0/26", "10.227.37.0/24"])
  inbound_auth_subnets_list     = local.ibm_mq_subnets_list
  db_onprem_subnets_list = [
    { cidr = "10.191.254.15/32", description = "On-premise Oracle DB" },
  ]
  robotics_onprem_subnets_list = [
    { cidr = "10.191.206.7/32", description = "On-premise Robotics DB" },
  ]

  tier1_subnets            = join(",", local.tier1_subnets_list)
  tier2_subnets            = join(",", local.tier2_subnets_list)
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
  logstash_subnets         = join(",", local.logstash_subnets_list)
  inbound_db_subnets       = join(",", local.inbound_db_subnets_list)
  inbound_otp_subnets      = join(",", local.inbound_otp_subnets_list)
  inbound_sms_subnets      = join(",", local.inbound_sms_subnets_list)
  inbound_auth_subnets     = join(",", local.inbound_auth_subnets_list)

  tag_map_migrated_console        = "d-server-03kj9clzvylind"
  tag_map_migrated_ibank          = "d-server-00o6ltt8axgaob"
  tag_map_migrated_clientendpoint = "d-server-033l0bgstnjpg7"
  tag_map_migrated_otp            = "d-server-0047ubbguw1u3g"
  tag_map_migrated_sms            = "d-server-02jw6g9odoa15g"
  tag_map_migrated_auth           = "d-server-01rcq6ps0osex4"
  tag_map_migrated_oauth          = "d-server-00g926j6vhq0s1"
  tag_map_migrated_backup         = "d-server-037wwz582i7fyp"
  tag_map_migrated_stub           = local.tag_map_migrated_ibank

  bastion_host_ip = "127.0.0.1"

  instances_console = {
    defaults = { instance_type = "t3.large" },
    items = {
      console01 = { ami = "ami-0491553eb219377cc" },
    },
  }

  instances_sms = {
    defaults = { instance_type = "t3.large" },
    items = {
      sms01 = { ami = "ami-01912161dcd735364" },
    },
  }

  instances_otp = {
    defaults = { instance_type = "t3.large" },
    items = {
      otp01 = { ami = "ami-06853e1e537e8101d" },
    },
  }

  instances_auth = {
    defaults = { instance_type = "t3.large" },
    items = {
      auth01 = { ami = "ami-0d683e82241998ab7" },  # ami-0f880df09098247f3 - newer image
    },
  }

  instances_oauth = {
    defaults = { instance_type = "t3.large" },
    items = {
      oauth01 = { ami = "ami-04a1148ce11802594" },
    },
  }

  instances_ibank = {
    defaults = { instance_type = "t3.xlarge" },
    items = {
      ibank01 = { ami = "ami-02693fc5fe5c7f2c9" },
      ibank02 = { ami = "ami-00412fefaa8a7bc39", create = true },
    },
  }

  instances_clientendpoint = {
    defaults = { instance_type = "t3.large" },
    items = {
      clientendpoint01 = { ami = "ami-0a4325e78805059bd" },
    },
  }

  instances_stub = {
    defaults = { instance_type = "t3a.small" },
    items = {
      stub01 = { ami = "ami-0d2fde47dc5adc02f", create = true },
    },
  }

  lb_targets_console = [
    { target_id = "i-014a2ddbb0f37767f" },
  ]

  lb_targets_otp = [
    { target_id = "i-049f8e944899ffc14" },
  ]

  lb_targets_sms = [
    { target_id = "i-081fa8e8002519df8" },
  ]

  lb_targets_auth = [
    { target_id = "i-06852c0356d8d1b58" },
  ]

  lb_targets_oauth = [
    { target_id = "i-0e75f4965873796a3" },
  ]

  lb_targets_ibank = [
    { target_id = "i-000c239c5adfdb11d" },
    { target_id = "i-0af14bdcf7e34db8e" },
  ]

  lb_targets_clientendpoint = [
    { target_id = "i-0e1dacbc4a24d3192" },
  ]

  lb_targets_db_main = [
    { target_id = "10.225.98.116" },
  ]

  lb_targets_db_archive = [
    { target_id = "10.225.98.116" },
  ]

  sources_vpc_info           = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//vpc_info?ref=vpc_v1.0.1"
  sources_nacl               = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//vpc/network_acl?ref=v2.1.1"
  sources_ec2_instance       = "github.com/terraform-aws-modules/terraform-aws-ec2-instance.git//wrappers?ref=v4.0.0"
  sources_sg                 = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
  sources_lb                 = "github.com/terraform-aws-modules/terraform-aws-alb.git//.?ref=v6.10.0"
  sources_s3_bucket          = "github.com/terraform-aws-modules/terraform-aws-s3-bucket.git//.?ref=v3.1.0"
  sources_route53_record     = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=v2.6.0"
  sources_route53_zone       = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/zones?ref=v2.6.0"
  sources_aws_backup_ec2     = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//aws-backup/ec2?ref=v2.1.1"
  sources_vpc_endpoints      = "github.com/terraform-aws-modules/terraform-aws-vpc.git//modules/vpc-endpoints?ref=v3.14.0"
  sources_iam_policy         = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=v5.2.0"
  sources_baseline	         = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//.?ref=v3.0.1"
  sources_iam_assumable_role = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role?ref=v4.24.1"
  sources_ami_management     = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-channels-ami-management.git//.?ref=v1.2.2"

  lb_public_tag_value    = "nonprod-ro-public-alb"
  lb_public_host_headers = ["digital-uat.avrb.com.ua"]
  lb_oauth_host_headers  = ["bankid-uat.avrb.com.ua"]

  dns_name_logstash     = "open-search-test"
  dns_name_console      = "console"

  dns_records_opensearch = ["vpc-nonprod-ro-os-c4gokochunvcqez5y2jo2xob3y.eu-central-1.es.amazonaws.com."]

  l2support_ssm_user = "dbo"
}
