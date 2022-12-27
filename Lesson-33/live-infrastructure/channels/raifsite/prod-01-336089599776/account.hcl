# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  aws_account_id      = split("-", basename(get_terragrunt_dir()))[2]
  domain              = "web.rbua"
  public_domain       = "raiffeisen.ua"
  environment_letter  = "p"
  system              = "RaifSite"
  environment         = "prod"
  iam_role            = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
  ccoe_ssm_iam_policy = "arn:aws:iam::${local.aws_account_id}:policy/servicecatalog-customers/CCOE-Mandatory-SSM-SessionPolicy"

  tier1_subnets_list  = ["10.226.102.64/28", "10.226.102.80/28"]
  tier1_subnet_abbr   = "IN"
  tier1_subnet_filter = "*Internal*"

  tier2_subnets_list  = ["10.226.102.96/28", "10.226.102.112/28"]
  tier2_subnet_abbr   = "RT"
  tier2_subnet_filter = "*Restricted*"

  public_subnets_list = ["100.100.40.32/27", "100.100.40.64/27"]
  rbua_private_aws_subnets_list = ["10.216.0.0/16", "10.223.0.0/16", "10.224.0.0/14", "10.215.0.0/16"]
  rbua_private_subnets_list = ["10.184.0.0/13"]
  rbua_public_subnets_list  = ["185.84.148.0/23"]
  ad_aws_subnets_list = ["10.225.109.0/27", "10.227.50.176/28", "10.227.50.192/28"]
  zabbix_subnets_list = ["10.225.102.0/23"]
  cloud_flare_subnets_list  = ["173.245.48.0/20", "103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "141.101.64.0/18", "108.162.192.0/18", "190.93.240.0/20", "188.114.96.0/20", "197.234.240.0/22", "198.41.128.0/17", "162.158.0.0/15", "104.16.0.0/13", "104.24.0.0/14", "172.64.0.0/13", "131.0.72.0/22"]
  cyberark_subnets_list = ["10.191.242.32/28"]
  activemq_subnets_list = ["10.225.118.0/28", "10.227.57.96/27"]
  ibm_mq_subnets_list = ["10.226.119.0/26", "10.226.118.0/24"]
  esb_subnets_list    = ["10.191.253.84/32"]
  logstash_subnets_list = ["10.226.154.0/24"]
  salesbase_subnets_list  = ["10.225.106.0/24"]
  lipton_onpremise_subnets_list  = ["10.191.253.0/26"]
  dbre_private_subnets_list  = ["10.190.62.128/26"]
  cmsfont_onpemise_subnets_list = ["10.191.253.103/32"]
  salesbase_onprem_subnets_list = [  ]
  salesbase_aws_subnets_list = [ "10.226.138.0/23" ]

  tier1_subnets = join(",", local.tier1_subnets_list)
  tier2_subnets = join(",", local.tier2_subnets_list)

  public_subnets            = join(",", local.public_subnets_list)
  rbua_private_aws_subnets  = join(",", local.rbua_private_aws_subnets_list)
  rbua_private_subnets      = join(",", local.rbua_private_subnets_list)
  rbua_public_subnets       = join(",", local.rbua_public_subnets_list)
  ad_aws_subnets            = join(",", local.ad_aws_subnets_list)
  cloud_flare_subnets       = join(",", local.cloud_flare_subnets_list)
  cyberark_subnets          = join(",", local.cyberark_subnets_list)
  zabbix_subnets            = join(",", local.zabbix_subnets_list)
  activemq_subnets          = join(",", local.activemq_subnets_list)
  ibm_mq_subnets            = join(",", local.ibm_mq_subnets_list)
  esb_subnets               = join(",", local.esb_subnets_list)
  logstash_subnets          = join(",", local.logstash_subnets_list)
  salesbase_subnets         = join(",", local.salesbase_subnets_list)
  lipton_onpremise_subnets  = join(",", local.lipton_onpremise_subnets_list)
  dbre_private_subnets      = join(",", local.dbre_private_subnets_list)
  cmsfont_onpemise_subnets  = join(",", local.cmsfont_onpemise_subnets_list)
  salesbase_aws_subnets     = join(",", local.salesbase_aws_subnets_list)

  lb_public_tag_value	   = "raifsite-public-alb"
  lb_ssl_cert_arn        = "arn:aws:acm:eu-central-1:336089599776:certificate/229fd350-c878-4e84-b34a-95b28e38c4ae"

  ssh_key_devops_pub     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRJk3ERxdY1+VV+8pV1NqzrXknoPcsm1zCM47k4SJ9pteEtNd6CJgt0wx/jz9m0JNKKaaE2VbTOUXPe16bluZLmKPgcmlNWLewSerBE5BNycbu4Xc4DwWdJiTZ2VRL8P3PGfvJbnDeD7s47ZSTeZ6SD0vRwGiHLDtt04M7StY1z7eSfLYGHyzsj6OpeyxyKz3fy2fs0b3y4fOuqhICXyBLdbvH1WDAFdmCjiR0tnV2Le2is3lRk3F83cCALzSiUA3ByvdHSXIkreos4ngsLGhG3HQ+trpgJ9fkhvDb0npTKztI4YbKmz/nUmxWVxZber7XErTeEyJRG68ADja5UBI/EFVhd99V64P9jHz/EdyVJv/tgZ0cMCVOVKI/su5GSAgY4zZkeec18Ip77uUligPAaKJi4nB2CrlFBgz3abR3fUg7myG0ImCQAQGY3gT0ilHmeRVOwkyf1PurtW0XSCA4oCkL/VFFTzRhUyUotFjTeK5XQ94l1tx+iNv/MeMzlQ8= raifsite@devops"
  ssh_key_webpromo_devops_pub = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/+QUjrG++3szUhOwcbdF9uLOYUbfftTjO9iZSUJHlvWhSs9MH+XSnJYD3j8PH33UJ11TIP0wPc0sd/oPNk4jUGVS4kYGsh816xTZ0B8Wsek9qe6O09DmMWG/rxE4wzzTW085Ifw8EN+Q/LVWChpSlXEqqfbU0hY7t2FFBjs7RHBKka3R0E4YSyDkMgm0CiCXHyIcB8MEmSnD25uzJDLFF4xrReCJ+nL+1NW51QO6BUih6ztmIGN3tGoJcp7fcv8F+3+VAJ7Cd+4OwzERmHblC2cN1AYdAVPlytVvQ/LY90ga81ZIVgGdka/EEZzZIGRaHMlGu3oznR8VWDLc1g8yDBmBfegwriUtQmIQIA9Muzgy0Po9DS9GzOYryppgVjjIHTq2V7w3Y3CB8yruV8dY/lir5NiEuDz1lON/uxVbMuJxqnpDZacBfpXkwxvyi85LDoaBRWPRKmJau7rbm7ST3V5bZhzjmq92y0E92TetlfaahUKkOF/rRC0JeW4W4wfk= webpromo@devops"

  tag_map_migrated_cmsfront  = "d-server-0228i32fbgc5pq"
  tag_ami_policy_cmsfront = "ec2bp_raifsite-cmsfront"
  tag_ami_retention_count_cmsfront  = 3
  tag_ami_expiration_days_cmsfront  = 10

  int_cmsfront_admin_tg_arn = ["arn:aws:elasticloadbalancing:eu-central-1:336089599776:targetgroup/raifsite-internal-alb-cmsfront/33a22f609843d988"]
  int_cmsfront_main_tg_arn  = ["arn:aws:elasticloadbalancing:eu-central-1:336089599776:targetgroup/raifsite-internal-alb-public-cf/08a198aa5d5ef8e9"]
  pub_cmsfront_sales_tg_arn = ["arn:aws:elasticloadbalancing:eu-central-1:336089599776:targetgroup/raifsite-pub-alb-cmsfront-sales/1a1d2f949ff170f8"]
  pub_cmsfront_main_tg_arn  = ["arn:aws:elasticloadbalancing:eu-central-1:336089599776:targetgroup/raifsite-prod-public-alb-cmsfron/e6ab402660f8a55d"]

  route53_resolver_rule_associations = {
    "aval"     = { resolver_rule_id = "rslvr-rr-7386ce4b2e2c46b6a" },
    "rbua"     = { resolver_rule_id = "rslvr-rr-cd8ee6dcf31040d5b" },
  }

  cmsfront_autoscaling_options = {
    instance_type  = "m5.xlarge"
    instance_ami = "ami-072b2ba4a7f85eb9d"
    min_size  = 2
    max_size  = 4
    desired_capacity  = 2
    wait_for_capacity_timeout = 0
  }

  webpromo_options = {
    defaults = {
      instance_type = "t3.small"
      ami = "ami-01aa523a952e46e73"
    },
    items = {
      webpromo-01 = { },
      webpromo-02 = { create = true },
    }
  }

  webpromo_public_domain  = "promo.raiffeisen.ua"
  webpromo_domain         = "promo.rbua"
  dns_record_lipton_db    = ["lipton.cazwkpxipzsm.eu-central-1.rds.amazonaws.com"]
  lb_targets_webpromo     = [
    { target_id = "i-013b7d990473e9d2e" },
    { target_id = "i-0a7f6806c4a984274" },
  ]

  maintenance = "false"
  nginx_instance_type = "t3.xlarge"
  nginx_ami = "ami-0ceb8a69e311da998"

  dns_record_cms_db = ["cmsdb.cazwkpxipzsm.eu-central-1.rds.amazonaws.com"]

  l2support_ssm_user  = "apache"

  sources_vpc_info             = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//vpc_info?ref=vpc_v1.0.1"
  sources_nacl                 = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//vpc/network_acl?ref=v2.1.1"
  sources_ec2_instance         = "github.com/terraform-aws-modules/terraform-aws-ec2-instance.git//.?ref=v4.0.0"
  sources_ec2_instance_wrap    = "github.com/terraform-aws-modules/terraform-aws-ec2-instance.git//wrappers?ref=v4.1.4"
  sources_sg                   = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
  sources_lb                   = "github.com/terraform-aws-modules/terraform-aws-alb.git//.?ref=v6.10.0"
  sources_s3_bucket            = "github.com/terraform-aws-modules/terraform-aws-s3-bucket.git//.?ref=v3.1.0"
  sources_route53_record       = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=v2.6.0"
  sources_route53_zone         = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/zones?ref=v2.6.0"
  sources_route53_rra          = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/resolver-rule-associations?ref=v2.8.0"
  sources_aws_backup_ec2       = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//aws-backup/ec2?ref=v2.1.1"
  sources_ec2_key_pair         = "github.com/terraform-aws-modules/terraform-aws-key-pair.git//.?ref=v1.0.1"
  sources_iam_assumable_role   = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-assumable-role?ref=v4.24.1"
  sources_rds_subnet_group     = "github.com/terraform-aws-modules/terraform-aws-rds.git//modules/db_subnet_group?ref=v4.3.0"
  sources_auto_scaling_group   = "github.com/terraform-aws-modules/terraform-aws-autoscaling.git//.?ref=v6.4.0"
  sources_elasticache	         = "github.com/cloudposse/terraform-aws-elasticache-redis.git//.?ref=0.43.0"
  sources_elastic_fs           = "github.com/cloudposse/terraform-aws-efs.git//.?ref=0.32.7"
  sources_vpc_endpoints        = "github.com/terraform-aws-modules/terraform-aws-vpc.git//modules/vpc-endpoints?ref=v3.14.0"
  sources_iam_policy           = "github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-policy?ref=v5.2.0"
  sources_baseline	           = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//.?ref=v3.0.1"
  sources_r53_zone_with_common = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-route53-zone-with-common-association.git//.?ref=v1.0.0"
  sources_ami_management       = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-channels-ami-management.git//.?ref=v1.2.2"
}
