# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  aws_account_id      = split("-", basename(get_terragrunt_dir()))[2]
  domain              = "dev.rbo.rbua"
  public_domain       = "rbo-dev.avrb.com.ua"
  aval_public_domain  = "rbo.dev.aval.ua"
  environment_letter  = "D"
  iam_role            = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
  ccoe_ssm_iam_policy = "arn:aws:iam::${local.aws_account_id}:policy/servicecatalog-customers/CCOE-Mandatory-SSM-SessionPolicy"


  default_app_port        = 8443
  db_plain_backend_port   = 1521
  lb_ssl_cert_arn         = "arn:aws:acm:eu-central-1:957392411540:certificate/58def3d6-2bb7-4242-8216-a3c30b56e131"
  ssh_key_pub             = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL42gJAmpjokuUBVKYX+6LRhU2Y4gTTSsTwSMaVmtA+y"
  appdyn_conf_path_prefix = "/dbocorp"

  tier1_subnets_list        = ["10.227.51.64/26"]
  tier1_subnet_abbr         = "TR"
  tier1_subnet_filter       = "*Transfer*"

  tier2_subnets_list        = ["10.227.51.128/26"]
  tier2_subnet_abbr         = "IN"
  tier2_subnet_filter       = "*Internal*"

  tier3_subnets_list        = ["10.227.51.192/26"]
  tier3_subnet_abbr         = "RE"
  tier3_subnet_filter       = "*Restricted*"

  public_subnets_list           = ["100.100.46.32/27", "100.100.46.64/27"]
  rbua_private_aws_subnets_list = ["10.216.0.0/16", "10.223.0.0/16", "10.224.0.0/14", "10.215.0.0/16"]
  rbua_private_subnets_list     = ["10.184.0.0/13"]
  rbua_public_subnets_list      = ["185.84.148.0/23"]
  avalaunch_subnets_list        = ["10.225.120.0/22"]
  common_infra_subnets_list     = ["10.225.102.0/23"]
  bifit_db_subnets_list         = ["10.226.102.0/26", "10.226.119.192/26"]
  ibm_mq_subnets_list           = ["10.191.196.63/32"]
  activemq_subnets_list         = ["10.191.254.113/32", "10.191.254.114/32"]
  auth_subnets_list             = ["10.225.109.0/27", "10.227.50.176/28", "10.227.50.192/28"]
  ad_onprem_subnets_list        = ["10.191.199.200/32", "10.191.199.201/32", "10.191.199.202/32"]
  cloud_flare_subnets_list      = ["173.245.48.0/20", "103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "141.101.64.0/18", "108.162.192.0/18", "190.93.240.0/20", "188.114.96.0/20", "197.234.240.0/22", "198.41.128.0/17", "162.158.0.0/15", "104.16.0.0/13", "104.24.0.0/14", "172.64.0.0/13", "131.0.72.0/22"]
  security_subnets_list         = ["10.226.116.0/25", "10.225.100.0/24", "10.191.254.64/26"]
  ro_subnets_list               = ["10.191.254.83/32", "10.191.254.79/32"]
  support_access_subnets_list   = ["10.191.242.32/28", "10.225.102.199/32", "10.191.194.131/32", "10.190.133.0/24", "10.225.102.4/32", "10.190.62.128/26"]
  nifi_subnets_list             = ["10.225.121.36/32", "10.225.121.8/32", "10.225.121.118/32", "10.225.121.66/32", "10.225.121.77/32", "10.225.121.74/32"]
  kafka_subnets_list            = ["10.225.122.128/25", "10.225.123.0/24"]
  inbound_db_etl_subnets_list   = [
    { cidr = "10.190.49.0/26",    description = "VDI pool for Datastage & MBroker(ETL&ESB) administrators" },
    { cidr = "10.225.121.76/32",  description = "Clickhouse1" },
    { cidr = "10.225.121.184/32", description = "Clickhouse2" },
    { cidr = "10.225.122.19/32",  description = "Clickhouse3" },
  ]
  inbound_db_arch_subnets_list  = [ ]
  inbound_db_oracle_subnets_list  = [
    { cidr = "10.191.194.99/32",         description = "7up.test.kv.aval(DataStage)" },
    { cidr = "10.225.102.53/32",         description = "DBagent(Non-Prod)" },
    { cidr = "10.225.100.0/24",          description = "CSK" },
    { cidr = "10.190.134.0/26",          description = "DevLoans-VCD04" },
    { cidr = "10.226.114.0/25",          description = "CyberSecurity Monitoring" },
    { cidr = local.nifi_subnets_list[0], description = "NiFi cluster" },
    { cidr = local.nifi_subnets_list[1], description = "NiFi cluster" },
    { cidr = local.nifi_subnets_list[2], description = "NiFi cluster" },
    { cidr = local.nifi_subnets_list[3], description = "NiFi cluster" },
    { cidr = local.nifi_subnets_list[4], description = "NiFi cluster" },
    { cidr = local.nifi_subnets_list[5], description = "NiFi cluster" },
    { cidr = "10.225.106.72/32",         description = "DataStage AWS" },
    { cidr = "10.225.106.161/32",        description = "RBO Trino Dev" },
    { cidr = "10.225.121.76/32",         description = "Clickhouse1" },
    { cidr = "10.225.121.184/32",        description = "Clickhouse2" },
    { cidr = "10.225.122.19/32",         description = "Clickhouse3" },
    { cidr = "10.226.96.201/32",         description = "Data Domain NiFi" }
  ]
  commvault_control_subnets_list = ["10.191.2.184/32"]
  inbound_db_oracle_backup_subnets_list = [
    { cidr = "10.225.116.172/32",             description = "CommVault host in Backup account" },
    { cidr = local.commvault_control_subnets, description = "Access for BigPoint (DC)" },
  ]
  outbound_db_oracle_sync_subnets_list = [ ]
  logstash_subnets_list       = ["10.226.154.0/26"]
  letter_rbo_subnets_list     = ["10.191.194.78/32"]
  rba_proxy_subnets_list      = ["10.191.80.28/32"]
  celer_cbs_subnets_list      = ["10.226.130.192/26"]  # TODO: clarify
  branches_subnets_list	      = ["10.226.48.0/20"]     # TODO: clarify
  oim_subnets_list            = ["10.191.5.201/32"]    # TODO: clarify
  syslog_servers_subnets_list = ["10.226.114.72/32", "10.191.8.70/32"]
  inbound_adm_is_subnets_list = [
    { cidr = "10.190.133.0/24",  description = "Channels DEV Pool" },
    { cidr = "10.191.196.0/24",  description = "Robotics DEV Pool" },
    { cidr = "10.191.242.32/28", description = "CyberArk Pool" },
  ]

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

  tag_map_migrated_front    = "d-server-03dh1wcq1mowex"
  tag_map_migrated_adm      = "d-server-00phkg3olnosr3"
  tag_map_migrated_auth     = "d-server-03tabz8ibktvnm"
  tag_map_migrated_is-front = "d-server-01o5vs75jczmt6"
  tag_map_migrated_is-back1 = "d-server-01o5vs75jczmt6"
  tag_map_migrated_is-back2 = "d-server-01o5vs75jczmt6"
  tag_map_migrated_backup   = "d-server-037wwz582i7fyp"
  tag_map_migrated_db       = "d-server-012lihldc3i47r"

  tag_ami_policy_app          = "ec2bp_rbo-coreapps-non-prod"
  tag_ami_retention_count_app = 2
  tag_ami_expiration_days_app = 10
  tag_ami_policy_sys          = "ec2bp_rbo-sys"
  tag_ami_retention_count_sys = 2
  tag_ami_expiration_days_sys = 7

  tag_schedule                    = "mon-fri-start-8-end-21"
  tag_schedule_is-back_all_first  = "endtime-21"
  tag_schedule_is-back_all_second = "endtime-21"

  bastion_host_ip   = "127.0.0.1"

  instances_front = {
    defaults = {
      instance_type = "r5a.xlarge",
      ami           = "ami-019b5bfb826f23769",
    },
    items = {
      front01 = { },
      front02 = { create = false },
    },
  }

  instances_adm = {
    defaults = {
      instance_type = "r5a.xlarge",
      ami           = "ami-0febb80120e9281bb",
    },
    items = {
      adm01 = { },
      adm02 = { create = false },
    },
  }

  instances_auth = {
    defaults = {
      instance_type = "r5a.xlarge",
      ami           = "ami-06de78f02975c2a36",
    },
    items = {
      auth01 = { },
      auth02 = { create = false },
    },
  }

  instances_is-front = {
    defaults = {
      instance_type = "r5a.xlarge",
      ami           = "ami-0c8c7a4ea8fb74cad"
    },
    items = {
      is-front01 = { },
      is-front02 = { create = false },
    },
  }

  instances_is-back1 = {
    defaults = {
      instance_type = "r5a.xlarge",
      ami           = "ami-0aa249c9e7aa118d3"
    },
    items = {
      is-back101 = { },
      is-back102 = { create = true },
    },
  }

  instances_is-back2 = {
    defaults = {
      instance_type = "r5a.xlarge",
      ami           = "ami-0aa249c9e7aa118d3"
    },
    items = {
      is-back201 = { },
      is-back202 = { create = true },
    },
  }

  instances_db = {
    defaults = {
      instance_type = "r5b.4xlarge",
      ami           = "ami-01a75e0102568a2e2"
    },
    items = {
      db01 = { },
    },
  }

  lb_targets_front = [
    { target_id = "i-00db6efcfa8f55c10" },
  ]

  lb_targets_is-front = [
    { target_id = "i-055a951427871a5b6" },
  ]

  lb_targets_auth = [
    { target_id = "i-0f9951e10174dcece" },
  ]

  lb_targets_adm = [
    { target_id = "i-0375255f322dee1be" },
  ]

  lb_targets_db_main = [
    { target_id = "10.227.51.238" },
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
  sources_rds                  = "github.com/terraform-aws-modules/terraform-aws-rds.git//.?ref=v5.0.3"
  sources_r53_zone_with_common = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-route53-zone-with-common-association.git//.?ref=v1.0.0"
  sources_ami_management       = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-channels-ami-management.git//.?ref=v1.2.2"

  lb_public_tag_value   = "rbo-public-alb"
  lb_front_host_headers = [ local.public_domain ]

  dns_records_opensearch               = ["xxxxx.eu-central-1.es.amazonaws.com."]
  dns_records_etl_db                   = [
    "dev-rbo-etl.can8bthtyyic.eu-central-1.rds.amazonaws.com."
  ]
  dns_records_arch_db                  = [
    "dev-rbo-arch.can8bthtyyic.eu-central-1.rds.amazonaws.com."
  ]
  dns_records_registrationauthority_ca = ["10.225.100.84","10.225.100.178"]

  common_infra_account_vpc_id = "vpc-0f00f1b872ab5dff9"

  route53_resolver_rule_associations = {
    "aval"                 = { resolver_rule_id = "rslvr-rr-7386ce4b2e2c46b6a" },
    "rbua"                 = { resolver_rule_id = "rslvr-rr-cd8ee6dcf31040d5b" },
    "csk-corp.aval.ua"     = { resolver_rule_id = "rslvr-rr-e2ff465bb44649b38" },
    "auth-dev.avrb.com.ua" = { resolver_rule_id = "rslvr-rr-7506c9e1306b43db9" },
  }

  l2support_ssm_user = "dbocorp"
  developer_ssm_user = "developer"

  rds_arch_instance_class       = "db.t4g.large"
  rds_arch_allocated_storage    = "599"
  rds_arch_multi_az             = false
  rds_arch_snapshot_identifier  = "arn:aws:rds:eu-central-1:969585074877:snapshot:aldebaran-uat-23-08-22"
  rds_arch_engine_version       = "12.11"
  rds_arch_major_engine_version = "12"
  rds_arch_family               = "postgres12"

  rds_etl_instance_class        = "db.t4g.medium"
  rds_etl_allocated_storage     = "50"
  rds_etl_multi_az              = false
  rds_etl_snapshot_identifier   = "arn:aws:rds:eu-central-1:969585074877:snapshot:data-uat-23-08-22"
  rds_etl_engine_version        = "12.11"
  rds_etl_major_engine_version  = "12"
  rds_etl_family                = "postgres12"
}
