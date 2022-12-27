# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.

locals {
  aws_account_id = "121056973450"
  vpc            = "vpc-0a09c4cc246243dfc"
  environment    = "test"
  domain         = "test.payments.rbua"
  new_domain     = "test-payments.rbua"
  pca            = "arn:aws:acm-pca:eu-central-1:416957951464:certificate-authority/cb7a9ed0-af05-4593-a013-81c8858aa8ba"
  core_subdomain = "test-03"
  disable_api_termination = false
  tags = merge(read_terragrunt_config(find_in_parent_folders("group.hcl")).locals.tags, {
    "security:environment" = "Test"
  })

  sources = {
    "host"             = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-host.git//?ref=v1.2.0" : find_in_parent_folders("ua-tf-aws-payments-host")
    "sg"               = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git//"
    "acm"              = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-acm-certificate.git//?ref=v1.0.0" : find_in_parent_folders("ua-tf-aws-acm-certificate")
    "vpc-info"         = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//vpc_info?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/vpc_info")
    "route53-alb"      = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/route53-alb?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/payments/route53-alb")
    "route53-endpoint" = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/route53-resolver-endpoint?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/payments/route53-resolver-endpoint")
    "aws-alb"          = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git//?ref=v7.0.0"
    "aws-s3-bucket"    = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git//?ref=v3.3.0"
    "target-group"     = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-lb-target-groups//?ref=v1.0.0"
    "baseline"         = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//?ref=v3.0.1"
  }

  certificate_arn = "arn:aws:acm:eu-central-1:121056973450:certificate/33588329-c75b-46e3-841f-7e48b23d4360"

  default_alb_certificate = "arn:aws:acm:eu-central-1:121056973450:certificate/193f5205-c0a6-4bc3-9197-b6252301c8d5"

  sg = {
    "dns" = "sg-0507514f97a82a74a"
  }

  ec2_types = {
    "bastion" = "t2.micro"
    # IS-Card
    "cnp-ap01.is-card"       = "t3a.small"
    "connector-ap01.is-card" = "t3a.small"
    "tpiimini-ap01.is-card"  = "t3a.medium"
    "db01.is-card"           = "r5a.large"
    # Norkom
    "golden-ap01.norkom" = "r5a.2xlarge"
    "golden-ap02.norkom" = "r5a.2xlarge"
    "db01.norkom"        = "r5.4xlarge"
    # VPOS / PTE
    "was-ap01.pte" = "r5a.large"
    "was-ap02.pte" = "r5a.large"
    "was-ap03.pte" = "r5a.large"
    "db01.pte"     = "r5b.large"
    "db01.vpos"    = "r5b.large"
    # PTE WF
    "wf-ap01.pte" = "r5a.large"
    "wf-db01.pte" = "r5b.large"
    # TM
    "shovel-ap01.tm"      = "t3a.small"
    "sortoutfile-ap01.tm" = "t3a.micro"
    "web-ap01.tm"         = "t3a.small"
    "db01.tm"             = "r5b.4xlarge"
    # EmailSender
    "ap01.emailsender" = "t3a.small"
    # SMTP
    "ap01.smtp" = "t2.micro"
  }

  ips = {
    "db-syslog"            = "10.226.114.72/32"
    "zabbix"               = ["10.225.102.4/32"]
    "pos-gateway"          = ["10.244.254.144/32"]
    "tpii-advice-host"     = ["10.244.254.157/32"]
    "autoquery"            = ["10.244.254.154/32"]
    "ad"                   = ["10.225.109.0/27", "10.191.2.192/27", "10.227.50.128/25"]
    "kms-windows"          = ["10.191.2.57/32", "10.191.2.107/32"]
    "cyberark"             = ["10.0.0.0/8"]
    "broker"               = ["10.226.119.162/32"]
    "ibm-mb"               = ["10.226.119.162/32"] # test.esb.rbua
    "osa12x.test-dmz"      = ["10.191.254.15/32"]
    "ose12x.todb"          = ["10.191.204.100/32"]
    "test.aval"            = ["10.191.199.200/32", "10.191.199.201/32", "10.191.199.202/32"]
    "arc_sight"            = ["10.226.114.0/25"]
    "b-tm.todb"            = ["10.191.204.122/32"]
    "sheriff.tsdb"         = ["10.191.205.13/32"]
    "ps-hsm"               = ["10.191.22.163/32"]
    "biffit-lb"            = ["10.226.115.64/26", "10.226.115.128/26"]
    "on-premise-databases" = ["127.0.0.1/32"]
    "amftpro-in-data"      = ["127.0.0.2/32"]
    "data-stage"           = ["10.191.194.99/32"]
    "hnas"                 = ["10.226.108.132/32", "10.226.109.25/32"] # amznfsxpzzq563m.ms.aval
    "satellite"            = ["10.191.2.105/32"]                       # satellite.noc-dc1.kv.aval
    "rhui3"                = ["3.120.254.163/32"]
    "lucky2"               = ["10.191.196.63/32"] # lucky2.test.kv.aval
    "nagios"               = ["10.225.102.104/32"]
    "zuko"                 = ["10.191.4.155/32"] # zuko.app.kv.aval
    "nifi"                 = ["10.225.121.0/24"]
    "rinfo-app"            = ["10.226.108.69/32", "10.226.108.163/32", "10.191.32.5/32", "10.191.32.6/32", "10.225.106.83/32", "10.191.199.55/32", "10.191.194.122/32", "10.191.194.14/32", "10.225.106.83/32"]
    "rinfo-dev"            = ["10.226.129.0/26"]
    "rinfo-app-on-premise" = ["10.185.30.42/32", "10.185.30.45/32"]
    "data-catalog"         = ["10.223.39.128/26", "10.223.39.196/32"]
    "darkstar"             = ["10.191.5.121/32"] # darkstar.app.kv.aval
    "latino"               = ["10.191.5.122/32"] # latino.app.kv.aval
    "celer"                = ["10.191.4.12/32"]  # celer.app.kv.aval
    "kiosk"                = ["10.226.106.0/26", "10.226.106.64/26"]
    "on-premise-system"    = ["10.191.4.0/24", "10.191.5.0/24"]
    "aval-common-test"     = ["10.225.103.0/24", "10.225.102.0/24"]
    "control-m"            = ["127.0.0.1/32"]
    "uadho-wctm901"        = ["127.0.0.1/32"]
    "comm-vault"           = ["127.0.0.1/32"]
    "mirinda"              = ["127.0.0.1/32"]
    "idm"                  = ["127.0.0.1/32"]
    "kiosk-app"            = ["127.0.0.1/32"]
    "vip"                  = ["127.0.0.1/32"]
    "gamma"                = ["127.0.0.1/32"]
    "blue-prism"           = ["127.0.0.1/32"]
    "debt-manager"         = ["127.0.0.1/32"]
    "soda"                 = ["127.0.0.1/32"]
    "arcsight"             = ["127.0.0.1/32"]
    "mbank"                = ["127.0.0.1/32"]
    "yupi"                 = ["10.191.199.130/32", "10.191.199.184/32"]
    "general-is-card"      = ["127.0.0.11/32"]
    "general-tm-1"         = ["127.0.0.21/32"]
    "general-tm-2"         = ["127.0.0.22/32"]
    "cisaod"               = ["127.0.0.1/32"]
    "barracuda"            = ["127.0.0.1/32"]
    "tuna"                 = ["127.0.0.1/32"]
    "aws-wfile"            = ["127.0.0.1/32"]
    "dfs-wfile"            = ["127.0.0.1/32"]
    "door"                 = ["127.0.0.1/32"]
    "arcsight-esm"         = ["127.0.0.1/32"]
    "newtm-in-data"        = ["127.0.0.1/32"]
    "yakus"                = ["127.0.0.1/32"] # yakus.app.kv.aval
    "kafka-dmz"            = ["127.0.0.1/32"]
    "autoquery-vienna"     = ["127.0.0.1/32"]
    "pos-gateway-vienna"   = ["127.0.0.1/32"]
    "iscardb.todb"         = ["127.0.0.1/32"]
    "mft-vienna"           = ["127.0.0.1/32"]
    "mft-kyiv"             = ["127.0.0.1/32"]
    "yakus"                = ["127.0.0.1/32"]
    "cda-deploy"           = ["10.191.194.80/32"]
    "uadho-wtech"          = ["127.0.0.1/32"]
    "dbKioskDblinks"       = ["127.0.0.1/32"]
    "test-qa"              = ["10.190.133.0/24", "10.190.247.0/24"]
    "vip.inet-dmz"         = ["127.0.0.1/32"]
    "iq.sdb"               = ["127.0.0.1/32"]
    "rightrock-vip.odb"    = ["127.0.0.1/32"]
    "sheriff2019.sdb"      = ["127.0.0.1/32"]
    "dwhx.todb.kv.aval"    = ["10.191.195.100/32"]
    "gdwhprod.odb.kv.aval" = ["127.0.0.1/32"]
    "silver.odb.kv.aval"   = ["127.0.0.1/32"]
    "gold.odb.kv.aval"     = ["127.0.0.1/32"]
    "ibrahim.b2"           = ["10.191.7.82/32"]
    "awsec2-wfile01"       = ["10.226.149.84/32"]
    "sheriff-aws"          = ["127.0.0.1/32"]
    "uadho-wfile01"        = ["10.191.2.30/32"]
    "kafka"                = ["10.225.123.202/32", "10.225.122.247/32", "10.225.123.28/32"]
    "nifi-prod"            = ["127.0.0.1/32"]
    "mcduck.noc-dc1"       = ["10.191.3.99/32"]
    "floyd.todb"           = ["10.191.195.115/32"]
    "db3.odb"              = ["127.0.0.1/32"]
    "uadho-wfile"          = ["10.191.2.30/32", "10.191.2.40/32", "10.191.2.33/32", "10.191.2.229/32", "10.191.2.230/32", "10.191.2.70/32", "10.191.2.58/32", "10.191.2.176/32"]
    "cyberark-subnet"      = ["10.191.242.32/28"]
    "datastage"            = ["10.225.112.68/32"]
    "tenable"              = ["127.0.0.1/32"]
    "satellite-c"          = ["127.0.0.1/32"]
    "dm-odb02"             = ["127.0.0.1/32"]
  }

  dbs = {
    "tmaster" = ["10.191.12.85/32"] # tmaster.odb.kv.aval
    "iscard"  = ["10.191.56.8/32"]  # iscard.odb.kv.aval

  }

  pools = {
    "ho-pool-treasury"    = ["10.190.124.192/26"]
    "ho-pool-payments"    = ["10.190.131.96/27"]
    "ho-pool-card"        = ["10.190.50.128/25"]
    "ho-pool-dba"         = ["10.190.62.128/26"]
    "ho-pool-card-aws"    = ["10.226.45.0/24"]
    "ho-pool-ho-dir-aws"  = ["10.226.48.0/20"]
    "ho-pool-cps"         = ["10.190.51.128/26"]
    "ho-pool-sft"         = ["10.190.131.128/26"]
    "cbtp-pool"           = ["10.190.154.0/25"]
    "ho-pool-etl"         = ["10.190.49.0/26"]
    "ho-pool-le"          = ["10.190.155.96/27"]
    "ho-pool-ho-dir"      = ["10.190.40.0/23", "10.190.42.0/23", "10.190.44.0/23", "10.190.46.0/23"]
    "ho-pool-opc10"       = ["10.190.56.0/22", "10.190.114.0/23"]
    "ho-pool-itanalitics" = ["10.190.127.0/24"]
    "ho-pool-ns"          = ["127.0.0.1/32"]
    "ho-pool-devpay"      = ["10.190.135.0/25"]
  }

  aws_accounts = {
    "rbua-custacc-internal"                    = ["127.0.0.1/32"]
    "rbua-cbs-transfer"                        = ["127.0.0.1/32"]
    "rbua-cbs-internal"                        = ["127.0.0.1/32"]
    "rbua-cbs-restricted"                      = ["10.227.52.192/26", "10.227.53.0/26", "10.227.53.64/26"]
    "rbua-custacc-internal"                    = ["127.0.0.1/32"]
    "rbua-appstream-prod"                      = ["127.0.0.1/32"]
    "payments-test-05-internal"                = ["10.226.142.0/27", "10.226.142.32/27", "10.226.142.64/27"]
    "payments-test-03-internal"                = ["10.226.123.0/28", "10.226.123.16/28", "10.226.123.32/28"]
    "payments-prod-09-internal"                = ["127.0.0.1/32"]
    "payments-prod-09-restricted"              = ["127.0.0.1/32"]
    "payments-prod-09-transfer"                = ["127.0.0.1/32"]
    "cbs-dev-01"                               = ["10.227.44.192/26"]
    "channels-intnoncritical-prod-02-transfer" = ["127.0.0.1/32"]
    "avalaunch-dev-mig-2k3h-internal"          = ["127.0.0.1/32"]
  }

}
