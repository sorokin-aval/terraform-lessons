# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.

locals {
  aws_account_id = "595150552767"
  vpc            = "vpc-0314b86ca473151b9"
  environment    = "test"
  domain         = "test-payments.rbua"
  core_subdomain = "test-07"
  pca            = "arn:aws:acm-pca:eu-central-1:416957951464:certificate-authority/cb7a9ed0-af05-4593-a013-81c8858aa8ba"
  disable_api_termination = false
  tags           = merge( read_terragrunt_config(find_in_parent_folders("group.hcl")).locals.tags, {
    "security:environment" = "Test"
  } )

  sources = {
    "host"             = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-host.git//?ref=v1.2.0" : find_in_parent_folders("ua-tf-aws-payments-host")
    "sg"               = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git//?ref=v4.9.0"
    "rds"              = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git//"
    "acm"              = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/acm-certificate?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/payments/acm-certificate")
    "vpc-info"         = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//vpc_info?ref=main" : find_in_parent_folders("ua-avalaunch-terraform-modules/vpc_info")
    "route53-alb"      = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/route53-alb?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/payments/route53-alb")
    "route53-endpoint" = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/route53-resolver-endpoint?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/payments/route53-resolver-endpoint")
    "aws-alb"          = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git//?ref=v7.0.0"
    "aws-s3-bucket"    = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git//?ref=v3.3.0"
    "target-group"     = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-lb-target-groups//?ref=v1.0.0"
#    "nacl"             = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//vpc/network_acl?ref=v2.1.1"
    "nacl"             = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-vpc-network-acl.git//?ref=v1.0.0"
    "baseline"         = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//?ref=v3.0.1"
  }

  default_alb_certificate = "arn:aws:acm:eu-central-1:595150552767:certificate/6c3765bc-42f1-40ef-9eeb-f1e21047bd5a"

  ec2_types = {
    # Fasttack
    "ap01.fasttack" = "t3a.medium"
    "ap02.fasttack" = "t3a.medium"
    "db01.fasttack" = "t3a.medium"
  }

  rds_types = {
  }

  ips = {
    "db-syslog"            = "10.226.114.72/32"
    "zabbix"               = ["10.225.102.4/32"]
    "aval-common-test"     = ["10.225.103.0/24", "10.225.102.0/24"]
    "kms-windows"          = ["10.191.2.57/32", "10.191.2.107/32"]
    "ad"                   = ["10.225.109.0/27", "10.191.2.192/27", "10.227.50.128/25"]
    "ibm-mb"               = ["10.226.119.162/32"]
    "ad-test"              = ["10.191.199.200/32", "10.191.199.201/32", "10.191.199.202/32"]
    "cloudflare-ips"       = ["173.245.48.0/20", "103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "141.101.64.0/18", "108.162.192.0/18", "190.93.240.0/20", "188.114.96.0/20", "197.234.240.0/22", "198.41.128.0/17", "162.158.0.0/15", "104.16.0.0/13", "104.24.0.0/14", "172.64.0.0/13", "131.0.72.0/22"]
    "on-premise-databases" = ["127.0.0.1/32"]
    "arcsight"             = ["10.226.114.0/24"]
    "comm-vault"           = ["127.0.0.1/32"]
    "oracle-db-tf"         = ["127.0.0.1/32"]
    "mirinda"              = ["127.0.0.1/32"]
    "zuko"                 = ["127.0.0.1/32"]
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
    "data-dev-02-internal"           = ["127.0.0.1/32"]
    "dev-mig-2k3h"                   = ["10.225.124.0/22"]
  }

}
