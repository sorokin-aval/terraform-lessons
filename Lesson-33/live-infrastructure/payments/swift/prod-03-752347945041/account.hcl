# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.

locals {
  aws_account_id = "752347945041"
  vpc            = "vpc-04f5982a7dbce63ad"
  environment    = "prod"
  domain         = "payments.rbua"
  tags = merge(read_terragrunt_config(find_in_parent_folders("group.hcl")).locals.tags, {
    "security:environment" = "Prod"
  })

  sources = {
    "host"             = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-host.git//?ref=main" : find_in_parent_folders("ua-tf-aws-payments-host")
    "sg"               = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git//?ref=v4.9.0"
    "rds"              = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git//"
    "acm"              = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/acm-certificate?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/payments/acm-certificate")
    "vpc-info"         = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//vpc_info?ref=main" : find_in_parent_folders("ua-avalaunch-terraform-modules/vpc_info")
    "tg"               = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-lb-target-groups//?ref=v1.0.0" : find_in_parent_folders("ua-tf-aws-payments-lb-target-groups")
    "route53-alb"      = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/route53-alb?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/payments/route53-alb")
    "route53-endpoint" = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/route53-resolver-endpoint?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/payments/route53-resolver-endpoint")
    "elb"              = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git//?ref=v6.8.0"
    "baseline"         = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//?ref=v3.0.1"
  }

  ec2_types = {
    # SWIFT
    "ap01.swift" = "t3a.medium"
    "ap02.swift" = "t3a.medium"
    "ap03.swift" = "t3a.large"
  }

  rds_types = {
  }

  ips = {
    "db-syslog"            = "10.226.114.72/32"
    "cyberark"             = ["10.0.0.0/8"]
    "aval-common-test"     = ["10.225.103.0/24", "10.225.102.0/24"]
    "kms-windows"          = ["10.191.2.57/32", "10.191.2.107/32"]
    "ad"                   = ["10.225.109.0/27", "10.191.2.192/27", "10.227.50.128/25"]
    "connect-direct-crisp" = ["10.241.150.33/32", "10.241.7.95/32"]
    "connect-direct-rbi"   = ["10.0.136.74/32"]
    "ibm-mq-rbi"           = ["10.0.150.226/32"]
    "ibm-mq-crisp"         = ["10.241.150.23/32"]
    "mgwt-crisp"           = ["10.241.149.137/32"]
    "zabbix"               = ["10.225.102.4/32"]
    "mcduck.noc-dc1"       = ["10.191.3.99/32"]
  }

  dbs = {}

  pools = {
  }

}
