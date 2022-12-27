# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.

locals {
  aws_account_id = "818212589289"
  vpc            = "vpc-0595fd503b0722969"
  environment    = "prod"
  domain         = "payments.rbua"
  pca            = "arn:aws:acm-pca:eu-central-1:416957951464:certificate-authority/cb7a9ed0-af05-4593-a013-81c8858aa8ba"
  tags           = merge( read_terragrunt_config(find_in_parent_folders("group.hcl")).locals.tags, {
    "security:environment" = "Prod"
  } )

  sources = {
    "host"             = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-host.git//?ref=main" : find_in_parent_folders("ua-tf-aws-payments-host")
    "sg"               = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git//?ref=v4.9.0"
    "rds"              = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git//"
    "acm"              = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-acm-certificate.git//?ref=v1.0.0" : find_in_parent_folders("ua-tf-aws-acm-certificate")
    "vpc-info"         = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//vpc_info?ref=main" : find_in_parent_folders("ua-avalaunch-terraform-modules/vpc_info")
    "tg"               = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-lb-target-groups//?ref=v1.0.0" : find_in_parent_folders("ua-tf-aws-payments-lb-target-groups")
    "route53-alb"      = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/route53-alb?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/payments/route53-alb")
    "route53-endpoint" = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/route53-resolver-endpoint?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/payments/route53-resolver-endpoint")
    "statements"       = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/statements?ref=payments/main"
    "elb"              = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git//?ref=v6.8.0"
    "aws-s3-bucket"    = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git//?ref=v3.3.0"
    "target-group"     = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-lb-target-groups//?ref=v1.0.0"
    "baseline"         = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//?ref=v3.0.1"
    "nacl"             = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-vpc-network-acl.git//?ref=v1.0.0"
  }

  default_alb_certificate = "arn:aws:acm:eu-central-1:818212589289:certificate/8fbdf77b-76aa-4df9-a85f-707e019a8164"

  ec2_types = {
    # POS
    "ap01.pos" = "t3.small"
    "ap02.pos" = "t3.small"
    "ap01.ejbca" = "t2.small"
    "ap02.ejbca" = "t2.small"
  }

  rds_types = {
    "rds-pos" = "db.t3.xlarge"
  }

  ips = {
    "db-syslog"        = "10.226.114.72/32"
    "zabbix"           = ["10.225.102.4/32"]
    "aval-common-test" = ["10.225.103.0/24", "10.225.102.0/24"] # 136812256255
    "ad"               = ["10.225.109.0/27", "10.191.2.192/27", "10.227.50.128/25"]
    "kms-windows"      = ["10.191.2.57/32", "10.191.2.107/32"]
    "cloudflare-ips"   = ["173.245.48.0/20", "103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "141.101.64.0/18", "108.162.192.0/18", "190.93.240.0/20", "188.114.96.0/20", "197.234.240.0/22", "198.41.128.0/17", "162.158.0.0/15", "104.16.0.0/13", "104.24.0.0/14", "172.64.0.0/13", "131.0.72.0/22"] # ca.aval.ua
    "all"              = ["0.0.0.0/0"]
    "ejbca-db1"        = ["10.191.253.12/32"]
    "upc"              = ["10.244.254.139/32"]
    "cyber_ark_net"    = ["10.191.242.32/28"]
  }

  dbs = {}

  pools = {
    "ho-pool-dba"          = ["10.190.62.128/26"]
    "ho-pool-payments"     = ["10.190.131.96/27"]
    "ho-pool-vpps"         = ["10.190.51.192/26"]
    "ho-pool-card"         = ["10.190.50.128/25"]
    "rbua-public-ip-pool"  = ["185.84.148.0/24"]
  }

}
