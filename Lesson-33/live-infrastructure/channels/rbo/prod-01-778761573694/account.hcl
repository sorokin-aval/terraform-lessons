# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  aws_account_id      = split("-", basename(get_terragrunt_dir()))[2]
  domain              = "rbo.rbua"
  public_domain       = "rbo.raiffeisen.ua"
  aval_public_domain  = "rbo.aval.ua"
  environment_letter  = "P"
  iam_role            = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
  ccoe_ssm_iam_policy = "arn:aws:iam::${local.aws_account_id}:policy/servicecatalog-customers/CCOE-Mandatory-SSM-SessionPolicy"

  default_app_port        = 8443
  db_plain_backend_port   = 1522
  lb_ssl_cert_arn         = "arn:aws:acm:eu-central-1:778761573694:certificate/1f6eaeeb-6ca1-4551-a87d-f1b06d30b033"
  ssh_key_pub             = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL42gJAmpjokuUBVKYX+6LRhU2Y4gTTSsTwSMaVmtA+y"
  appdyn_conf_path_prefix = "/dbole"

  tier1_subnets_list        = ["10.226.101.64/26"]
  tier1_subnet_abbr         = "TR"
  tier1_subnet_filter       = "*Transfer*"

  tier2_subnets_list        = ["10.226.101.0/26"]
  tier2_subnet_abbr         = "IN"
  tier2_subnet_filter       = "*Internal*"

  tier3_subnets_list        = ["10.226.101.128/26"]
  tier3_subnet_abbr         = "RE"
  tier3_subnet_filter       = "*Restricted*"

  public_subnets_list           = ["100.100.34.32/27", "100.100.34.64/27"]
  rbua_private_aws_subnets_list = ["10.216.0.0/16", "10.223.0.0/16", "10.224.0.0/14", "10.215.0.0/16"]
  rbua_private_subnets_list     = ["10.184.0.0/13"]
  rbua_public_subnets_list      = ["185.84.148.0/23"]
  avalaunch_subnets_list        = ["10.225.124.0/22"]
  common_infra_subnets_list     = ["10.225.102.0/23"]
  bifit_db_subnets_list         = ["10.226.118.64/26"]
  ibm_mq_subnets_list           = ["10.226.118.52/32", "10.226.119.23/32"]
  activemq_subnets_list         = ["10.227.57.104/32", "10.227.57.112/32"]
  auth_subnets_list             = ["10.225.109.0/27", "10.227.50.176/28", "10.227.50.192/28"]
  ad_onprem_subnets_list        = ["10.191.199.200/32"]
  cloud_flare_subnets_list      = ["173.245.48.0/20", "103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "141.101.64.0/18", "108.162.192.0/18", "190.93.240.0/20", "188.114.96.0/20", "197.234.240.0/22", "198.41.128.0/17", "162.158.0.0/15", "104.16.0.0/13", "104.24.0.0/14", "172.64.0.0/13", "131.0.72.0/22"]
  security_subnets_list         = ["10.226.116.0/25"]
  ro_subnets_list               = ["10.225.119.0/24"]
  support_access_subnets_list   = ["10.191.242.32/28", "10.190.50.32/27", "10.191.2.165/32", "10.225.102.4/32", "10.190.62.128/26", "10.191.253.53/32", "10.225.112.126/32", "10.225.102.104/32"]
  nifi_subnets_list             = ["10.225.125.86/32", "10.225.125.116/32", "10.225.125.57/32"]
  kafka_subnets_list            = ["10.225.126.128/25", "10.225.127.0/24"]
  inbound_db_etl_subnets_list   = [ ]
  inbound_db_arch_subnets_list  = [
    { cidr = "10.191.253.16/32", description = "aldebaran1.inet-dmz.kv.aval" },
    { cidr = "10.191.253.17/32", description = "aldebaran2.inet-dmz.kv.aval" },
  ]
  inbound_db_oracle_subnets_list = [
    { cidr = "10.225.103.14/32",         description = "DBAgent(Prod)" },
    { cidr = "10.226.114.0/25",          description = "Cyber Security Monitoring" },
    { cidr = "10.225.112.68/32",         description = "DataStage AWS PROD" },
    { cidr = "10.225.126.47/32",         description = "Data Domain NiFi" },
    { cidr = local.nifi_subnets_list[0], description = "NiFi cluster" },
    { cidr = local.nifi_subnets_list[1], description = "NiFi cluster" },
    { cidr = local.nifi_subnets_list[2], description = "NiFi cluster" },
    { cidr = "10.225.125.250/32",        description = "Data Domain NiFi" },
    { cidr = "10.225.125.79/32",         description = "Data Domain NiFi" },
    { cidr = "10.223.39.196/32",         description = "Group Data Catalog" },
    { cidr = "10.223.39.128/26",         description = "Group Data Catalog" }
  ]
  commvault_control_subnets_list = ["10.191.2.184/32", "10.225.116.172/32"]
  inbound_db_oracle_backup_subnets_list = [
    { cidr = local.commvault_control_subnets, description = "Access for BigPoint (DC)" },
    { cidr = "10.226.101.24/32",              description = "CommVault Media Agent" },
    { cidr = "10.226.116.128/25",             description = "CSK" },
  ]
  outbound_db_oracle_sync_subnets_list = [
    { cidr = "10.191.253.53/32", description = "leftpixel.inet-dmz.kv.aval" },
    { cidr = "10.191.253.54/32", description = "rightpixel.inet-dmz.kv.aval" },
  ]
  logstash_subnets_list       = ["10.226.154.64/26"]
  letter_rbo_subnets_list     = ["10.225.125.125/32", "10.225.125.228/32", "10.225.126.117/32", "10.226.40.128/25"]
  rba_proxy_subnets_list      = ["10.191.80.28/32"]
  celer_cbs_subnets_list      = ["10.226.130.192/26", "10.226.131.0/26", "10.226.131.64/26"]
  branches_subnets_list	      = ["10.226.48.0/20"]
  oim_subnets_list            = ["10.191.5.201/32", "10.191.5.202/32", "10.191.5.107/32", "10.226.112.160/27", "10.226.112.192/27"]
  syslog_servers_subnets_list = ["10.226.114.72/32", "10.191.8.70/32"]
  inbound_adm_is_subnets_list = []

  tier1_subnets             = join(",", local.tier1_subnets_list)
  tier2_subnets             = join(",", local.tier2_subnets_list)
  tier3_subnets             = join(",", local.tier3_subnets_list)
  public_subnets            = join(",", local.public_subnets_list)
  rbua_private_aws_subnets  = join(",", local.rbua_private_aws_subnets_list)
  rbua_private_subnets      = join(",", local.rbua_private_subnets_list)
  rbua_public_subnets       = join(",", local.rbua_public_subnets_list)
  avalaunch_subnets         = join(",", local.avalaunch_subnets_list)
  common_infra_subnets      = join(",", local.common_infra_subnets_list)
  bifit_db_subnets          = join(",", local.bifit_db_subnets_list)
  ibm_mq_subnets            = join(",", local.ibm_mq_subnets_list)
  activemq_subnets          = join(",", local.activemq_subnets_list)
  auth_subnets              = join(",", local.auth_subnets_list)
  ad_onprem_subnets         = join(",", local.ad_onprem_subnets_list)
  cloud_flare_subnets       = join(",", local.cloud_flare_subnets_list)
  security_subnets          = join(",", local.security_subnets_list)
  ro_subnets                = join(",", local.ro_subnets_list)
  support_access_subnets    = join(",", local.support_access_subnets_list)
  nifi_subnets              = join(",", local.nifi_subnets_list)
  kafka_subnets             = join(",", local.kafka_subnets_list)
  commvault_control_subnets = join(",", local.commvault_control_subnets_list)
  logstash_subnets          = join(",", local.logstash_subnets_list)
  letter_rbo_subnets	      = join(",", local.letter_rbo_subnets_list)
  rba_proxy_subnets	        = join(",", local.rba_proxy_subnets_list)
  celer_cbs_subnets	        = join(",", local.celer_cbs_subnets_list)
  branches_subnets	        = join(",", local.branches_subnets_list)
  oim_subnets               = join(",", local.oim_subnets_list)
  syslog_servers_subnets    = join(",", local.syslog_servers_subnets_list)

  tag_map_migrated_front    = "d-server-01x2qmfbkdlzx8"
  tag_map_migrated_adm      = "d-server-02boc08zv9gdkv"
  tag_map_migrated_auth     = "d-server-02ys54fpboj550"
  tag_map_migrated_is-front = "d-server-032f5t8f31oq2u"
  tag_map_migrated_is-back1 = "d-server-032f5t8f31oq2u"
  tag_map_migrated_is-back2 = "d-server-032f5t8f31oq2u"
  tag_map_migrated_backup   = "d-server-037wwz582i7fyp"
  tag_map_migrated_bastion  = "d-server-01j117r40h8tjl"

  tag_ami_policy_app          = "ec2bp_rbo-coreapps"
  tag_ami_retention_count_app = 3
  tag_ami_expiration_days_app = 10
  tag_ami_policy_sys          = "ec2bp_rbo-sys"
  tag_ami_retention_count_sys = 2
  tag_ami_expiration_days_sys = 7

  bastion_host_ip   = "10.226.101.60"

  instances_front = {
    defaults = {
      instance_type = "r5a.xlarge",
      ami           = "ami-0deaec745d5b21fa4",
    },
    items = {
      front01 = { ami           = "ami-01789209848d7355c", },
      front02 = { create = true },
      front03 = { create = true },
      front04 = { create = true },
      front05 = { create = true },
      front06 = { create = true },
      front07 = { create = true },
      front08 = { create = true },
      front09 = { create = true },
      front10 = { create = true },
    },
  }

  instances_adm = {
    defaults = {
      instance_type = "r5a.xlarge",
      ami           = "ami-07f194bf60b782d9a",
    },
    items = {
      adm01 = { ami           = "ami-03331f3c77735e441",  },
      adm02 = { create = true },
      adm03 = { create = true },
      adm04 = { create = true },
    },
  }

  instances_auth = {
    defaults = {
      instance_type = "r5a.xlarge",
      ami           = "ami-0e1f666d9ad69fd32",
    },
    items = {
      auth01 = { ami           = "ami-04ee7d5ba0a9804f1", },
      auth02 = { create = true },
      auth03 = { create = true },
      auth04 = { create = true },
    },
  }

  instances_is-front = {
    defaults = {
      instance_type = "r5a.xlarge",
      ami           = "ami-01830104aff0614c1"
    },
    items = {
      is-front01 = {  ami           = "ami-0c5f1223ea991deb8" },
      is-front02 = { create = true },
      is-front03 = { create = true },
      is-front04 = { create = true },
      is-front05 = { create = true },
      is-front06 = { create = true },
      is-front07 = { create = true },
      is-front08 = { create = true },
    },
  }

  instances_is-back1 = {
    defaults = {
      instance_type = "r5a.xlarge",
      ami           = "ami-04214cb4e66536755"
    },
    items = {
      is-back101 = { ami           = "ami-0c5f1223ea991deb8" },
      is-back102 = { create = true },
    },
  }

  instances_is-back2 = {
    defaults = {
      instance_type = "r5a.xlarge",
      ami           = "ami-06f8d6d4368137ef1"
    },
    items = {
      is-back201 = { ami           = "ami-0c5f1223ea991deb8" },
      is-back202 = { create = true },
    },
  }

  instances_bastion = {
    items = {
      bastion = { 
        instance_type = "t2.small",
        ami           = "ami-0d403d9046fb75440",
        private_ip    = local.bastion_host_ip,
      },
    }
  }

  lb_targets_front = [
    { target_id = "i-00086ae92ffefca13" },
    { target_id = "i-054c318de418aaf77" },
    { target_id = "i-0d5e5f5f049bd8663" },
    { target_id = "i-0db9e1ca837b86b0b" },
    { target_id = "i-00c5cc86664fd7dd6" },
    { target_id = "i-05d24516ef94c71de" },
    { target_id = "i-024046dcb33694bd4" },
    { target_id = "i-022aabc5f93dbf633" },
    { target_id = "i-02497078ec53ce867" },
    { target_id = "i-0addfc26d6462e989" },
  ]

  lb_targets_is-front = [
    { target_id = "i-0263d40433ede1f6e" },
    { target_id = "i-00cbbba0f127c2064" },
    { target_id = "i-0f5f2a424978c1330" },
    { target_id = "i-06a88f3d47263301c" },
    { target_id = "i-0ba528304589995cb" },
    { target_id = "i-0e7f7a1f5e5b12e3c" },
    { target_id = "i-09a442d5f6ed7804d" },
    { target_id = "i-0a95dc76f5277e90f" },
  ]

  lb_targets_auth = [
    { target_id = "i-015626102461e22a7" },
    { target_id = "i-0909e80e0661d98e9" },
    { target_id = "i-01ebf0fb1eba0ed88" },
    { target_id = "i-024040f5d05a403cd" },
  ]

  lb_targets_adm = [
    { target_id = "i-0a289cd19fd576eaf" },
    { target_id = "i-01d8a294654f042cd" },
    { target_id = "i-074cda14ac24b387e" },
    { target_id = "i-0ac5177d79047fdfa" },
  ]

  lb_targets_db_main = [
    { target_id = "10.226.101.146" },
    { target_id = "10.226.101.179" },
  ]

  baseline_ref = "v3.0.1"

  sources_vpc_info             = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//vpc_info?ref=vpc_v1.0.1"
  sources_nacl                 = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-vpc-network-acl.git//.?ref=v1.0.0"
  sources_ec2_instance         = "github.com/terraform-aws-modules/terraform-aws-ec2-instance.git//wrappers?ref=v4.0.0"
  sources_sg                   = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
  sources_lb                   = "github.com/terraform-aws-modules/terraform-aws-alb.git//.?ref=v6.10.0"
  sources_s3_bucket            = "github.com/terraform-aws-modules/terraform-aws-s3-bucket.git//.?ref=v3.1.0"
  sources_route53_record       = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=v2.6.0"
  sources_route53_zone         = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/zones?ref=v2.6.0"
  sources_route53_rra          = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/resolver-rule-associations?ref=v2.8.0"
  sources_aws_backup_ec2       = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//aws-backup/ec2?ref=v2.1.1"
  sources_ec2_key_pair         = "github.com/terraform-aws-modules/terraform-aws-key-pair.git//.?ref=v1.0.1"
  sources_rds_subnet_group     = "github.com/terraform-aws-modules/terraform-aws-rds.git//modules/db_subnet_group?ref=v4.3.0"
  sources_iam_assumable_role   = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role?ref=v4.24.1"
  sources_iam_policy           = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=v5.2.0"
  sources_baseline             = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//.?ref=${local.baseline_ref}"
  sources_r53_zone_with_common = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-route53-zone-with-common-association.git//.?ref=v1.0.0"
  sources_ami_management       = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-channels-ami-management.git//.?ref=v1.2.2"


  lb_public_tag_value   = "rbo-public-alb"
  lb_front_host_headers = [ local.public_domain ]

  dns_records_opensearch               = ["xxxxx.eu-central-1.es.amazonaws.com."]
  dns_records_etl_db                   = ["xxxxx.eu-central-1.es.amazonaws.com."]
  dns_records_arch_db                  = ["aldebaran.cpbuug7k97xa.eu-central-1.rds.amazonaws.com."]
  dns_records_registrationauthority_ca = ["10.226.116.20","10.226.116.70"]

  common_infra_account_vpc_id = "vpc-0f00f1b872ab5dff9"

  route53_resolver_rule_associations = {
    "aval"               = { resolver_rule_id = "rslvr-rr-7386ce4b2e2c46b6a" },
    "rbua"               = { resolver_rule_id = "rslvr-rr-cd8ee6dcf31040d5b" },
    "cskrba.aval.ua"     = { resolver_rule_id = "rslvr-rr-73dd42d6a61344e8b" },
    "auth.raiffeisen.ua" = { resolver_rule_id = "rslvr-rr-a4563ece84f4b4589" },
  }

  l2support_ssm_user = "dbole"
  developer_ssm_user = "developer"
}
