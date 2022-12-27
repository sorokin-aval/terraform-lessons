# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.

locals {
  aws_account_id = "424050786838"
  vpc            = "vpc-0ac6fbd2021d2b9de"
  environment    = "prod"
  domain         = "payments.rbua"
  core_subdomain = "prod-11"
  pca            = "arn:aws:acm-pca:eu-central-1:416957951464:certificate-authority/cb7a9ed0-af05-4593-a013-81c8858aa8ba"
  tags           = merge( read_terragrunt_config(find_in_parent_folders("group.hcl")).locals.tags, {
    "security:environment" = "Prod"
  } )

  sources = {
    "host"             = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-host.git//?ref=main" : find_in_parent_folders("ua-tf-aws-payments-host")
    "sg"               = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git//?ref=v4.9.0"
    "rds"              = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git//"
    "acm"              = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/acm-certificate?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/payments/acm-certificate")
    "vpc-info"         = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//vpc_info?ref=main" : find_in_parent_folders("ua-avalaunch-terraform-modules/vpc_info")
    "tg"               = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-lb-target-groups//?ref=v1.0.0" : find_in_parent_folders("ua-tf-aws-payments-lb-target-groups")
    "route53-alb"      = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/route53-alb?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/payments/route53-alb")
    "route53-endpoint" = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/route53-resolver-endpoint?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/payments/route53-resolver-endpoint")
    "aws-alb"          = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git//?ref=v7.0.0"
    "aws-s3-bucket"    = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git//?ref=v3.3.0"
    "target-group"     = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-lb-target-groups//?ref=v1.0.0"
    "nacl"             = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-vpc-network-acl.git//?ref=v1.0.0"
    "baseline"         = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//?ref=v3.0.1"
  }

  default_alb_certificate = "arn:aws:acm:eu-central-1:424050786838:certificate/eaa2ec86-e321-4199-95f9-a1495d771450"

  ec2_types = {
    "cv-ma01" = "r5a.large"
    # Fasttack
    "ap01.fasttack" = "r5.large"
    "ap02.fasttack" = "r5.large"
    "db01.fasttack" = "r5.large"
    "db02.fasttack" = "r5.large"
    # MBanking
    "db01.mbanking" = "r5.xlarge"
    "db02.mbanking" = "r5.xlarge"
  }

  rds_types = {
  }

  ips = {
    "db-syslog"            = "10.226.114.72/32"
    "zabbix"               = ["10.225.102.4/32"]
    "aval-common-test"     = ["10.225.103.0/24", "10.225.102.0/24"]
    "kms-windows"          = ["10.191.2.57/32", "10.191.2.107/32"]
    "ad"                   = ["10.225.109.0/27", "10.191.2.192/27", "10.227.50.128/25"]
    "ibm-mb"               = ["10.226.102.14/32", "10.226.102.39/32", "10.226.119.23/32", "10.226.118.52/32"]
    "ad-test"              = ["127.0.0.1/32"]
    "on-premise-databases" = ["10.191.12.0/24", "10.191.56.0/27", "10.191.253.0/26"]
    "arcsight"             = ["10.226.114.0/24"]
    "comm-vault"           = ["10.191.2.184/32", "10.226.122.0/24", "10.223.45.0/26", "10.224.227.64/26", "10.225.106.253/32"]
    "oracle-db-tf"         = ["10.225.112.98/32"]
    "cloudflare-ips"       = ["173.245.48.0/20", "103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "141.101.64.0/18", "108.162.192.0/18", "190.93.240.0/20", "188.114.96.0/20", "197.234.240.0/22", "198.41.128.0/17", "162.158.0.0/15", "104.16.0.0/13", "104.24.0.0/14", "172.64.0.0/13", "131.0.72.0/22"]
    "mirinda"              = ["10.191.4.133/32", "10.191.4.134/32", "10.191.4.233/32"]
    "zuko"                 = ["10.191.4.155/32"]
    "cyber_ark_net"        = ["10.191.242.32/28"]
    "jump"                 = ["10.225.112.126/32"]
  }

  dbs = {}

  pools = {
    "ho-pool-dba"          = ["10.190.62.128/26"]
    "ho-pool-payments"     = ["10.190.131.96/27"]
    "ho-pool-card"         = ["10.190.50.128/25"]
    "ho-pool-card-aws"     = ["10.226.45.0/24"]
    "ho-pool-vdi"          = ["10.190.49.0/26"]
    "ho-pool-opc10"        = ["10.190.56.0/22", "10.190.114.0/23"]
    "ho-pool-fairo"        = ["10.190.125.96/27"]
    "ho-pool-ho-dir"       = ["10.190.40.0/23", "10.190.42.0/23", "10.190.44.0/23", "10.190.46.0/23"]
    "ho-pool-ho-dir-aws"   = ["10.226.48.0/20"]
  }

  aws_accounts = {
    "data-dev-02-internal"           = ["10.225.112.0/26", "10.225.112.64/26"]
    "dev-mig-2k3h"                   = ["10.225.124.0/22"]
  }

}
