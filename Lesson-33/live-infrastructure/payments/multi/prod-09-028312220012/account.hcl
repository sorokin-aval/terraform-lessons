# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.

locals {
  aws_account_id    = "028312220012"
  vpc               = "vpc-0b6d3e809584389cc"
  environment       = "prod"
  domain            = "payments.rbua"
  directory_service = "d-99671b1f02" # The ID of the Directory Service
  pca               = "arn:aws:acm-pca:eu-central-1:416957951464:certificate-authority/cb7a9ed0-af05-4593-a013-81c8858aa8ba"
  core_subdomain    = "prod-09"
  tags           = merge( read_terragrunt_config(find_in_parent_folders("group.hcl")).locals.tags, {
    "security:environment" = "Prod"
  } )

  sources = {
    "host"             = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-host.git//?ref=main" : find_in_parent_folders("ua-tf-aws-payments-host")
    "sg"               = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git//"
    "rds"              = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git//"
    "acm"              = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-acm-certificate.git//?ref=v1.0.0" : find_in_parent_folders("ua-tf-aws-acm-certificate")
    "vpc-info"         = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//vpc_info?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/vpc_info")
    "route53-alb"      = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/route53-alb?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/payments/route53-alb")
    "route53-endpoint" = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/route53-resolver-endpoint?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/payments/route53-resolver-endpoint")
    "aws-alb"          = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git//?ref=v7.0.0"
    "aws-s3-bucket"    = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git//?ref=v3.3.0"
    "target-group"     = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-lb-target-groups//?ref=v1.0.1"
    "route53-records"  = "git::https://github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=v2.9.0"
    "baseline"         = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//?ref=v3.0.1"
    "aurora"           = "git::https://github.com/terraform-aws-modules/terraform-aws-rds-aurora.git//?ref=v7.6.0"
  }

  default_alb_certificate = "arn:aws:acm:eu-central-1:028312220012:certificate/a7f36e30-f1d2-4b69-a154-f9f23db55cc1"

  sg = {
    "dns" = ""
  }

  ec2_types = {
    "cv-ma01" = "m5zn.3xlarge"
    # PTELE
    "was-ap01.ptele" = "r5a.large"
    "was-ap02.ptele" = "r5a.large"
    "db01.ptele"     = "r5a.xlarge"
    "db02.ptele"     = "r5a.xlarge"
    # STP
    "was-ap01.stp" = "r5.xlarge"
    "was-ap02.stp" = "r5.xlarge"
    "db01.stp"     = "r5b.large"
    "db02.stp"     = "r5b.large"
    # was-sake
    "ap01.was-sake" = "m6i.large"
    # Smartclearing
    "was-ap01.smartclearing" = "r5.large"
    "was-ap02.smartclearing" = "r5.large"
    "db01.smartclearing"     = "r5.large"
    "db02.smartclearing"     = "r5.large"
    # Balance 2
    "ap01.balance2" = "t2.medium"
    "ap02.balance2" = "t2.medium"
    # Camunda
    "ap01.camunda"         = "t3a.medium"
    "ap02.camunda"         = "t3a.medium"
    "cockpit-ap01.camunda" = "t3a.medium"
    # BCPay/NLO
    "ap01.glassfish" = "r5.xlarge"
    "ap02.glassfish" = "r5.xlarge"
    # Avtokassa
    "ap01.avtokassa" = "t3a.medium"
    "ap02.avtokassa" = "t2.medium"
    "db01.avtokassa" = "r5.xlarge"
    "db02.avtokassa" = "r5.xlarge"
    # CardOp
    "cardop-ap01.tmis" = "t3a.medium"
    # Keeper
    "db01.keeper" = "c6a.xlarge"
    "db02.keeper" = "c6a.xlarge"
    "ap01.keeper" = "t3a.large"
    "ap02.keeper" = "t3a.large"
    # Alfa
    "db01.alfa" = "r5.xlarge"
    "db02.alfa" = "r5.xlarge"
    # Kafka-send
    "ap01.kafka-send" = "t3a.large"
    "ap02.kafka-send" = "t3a.large"
    # Trust
    "was-ap01.trust" = "r5.large"
    "was-ap02.trust" = "r5.large"
    "tampa01.trust"  = "t3.medium"
    # Inex
    "ap01.inex" = "r5.large"
    "ap02.inex" = "r5.large"
    "db01.inex" = "r5b.xlarge"
    "db02.inex" = "r5b.xlarge"
    # Camunda
    "db03.camunda" = "r6a.xlarge"
    # Unistatment
    "db03.unistatement" = "r6a.xlarge"
    # CLC
    "db03.clc" = "r6a.xlarge"
    # DD
    "db01.dd" = "r5.large"
    "db02.dd" = "r5.large"
    "ap01.dd" = "t2.small"
    "ap02.dd" = "t2.small"
    # Baseyka
    "db01.baseyka" = "c6a.xlarge"
    # Voyager
    "db01.voyager" = "c6a.xlarge"
    # Smartvista
    "ap01.smartvista" = "r5.large"
    "ap02.smartvista" = "r5.large"
    "db01.smartvista" = "r5b.large"
    "db02.smartvista" = "r5b.large"
    # MPСS
    "db01.mpcs" = "r5.2xlarge"
    "db02.mpcs" = "r5.2xlarge"    
  }

  rds_types = {
    "rds-trust"          = "db.r5.large"
    "rds-voyager"        = "db.m5.large"
    "rds-tbo"            = "db.m5.large"
    "aurora-unistatment" = "db.t3.large"
    "rds-satelit"        = "db.t3.medium"
  }

  rds_multi_az = {
    "rds-trust"         = true
    "rds-voyager"       = true
  }

  ips = {
    "db-syslog"            = "10.226.114.72/32"
    "zabbix"               = ["10.225.102.4/32"]
    "v-cardtr.tmydb"       = ["10.191.207.38/32"]
    "unistatement1.mydb"   = ["10.191.15.36/32"]
    "unistatement2.mydb"   = ["10.191.15.37/32"]
    "on-premise-databases" = ["10.191.12.0/24", "10.191.56.0/27"]
    "satellite"            = ["10.191.2.105/32"] # satellite.noc-dc1.kv.aval
    "cyberark"             = ["10.0.0.0/8"]
    "aval-common-test"     = ["10.225.103.0/24", "10.225.102.0/24"] # 136812256255
    "ad"                   = ["10.225.109.0/27", "10.191.2.192/27", "10.227.50.128/25"]
    "kms-windows"          = ["10.191.2.57/32", "10.191.2.107/32"]
    "broker"               = ["10.226.102.14/32", "10.226.102.39/32", "10.226.119.23/32", "10.226.118.52/32"]
    "test-app-pw"          = ["127.0.0.1/32"]
    "arcsight"             = ["10.226.114.0/24"]
    "comm-vault"           = ["10.191.2.184/32", "10.223.45.0/26", "10.225.106.253/32", "10.226.152.47/32"] # removed PROD-08 unnecessary networks 10.226.122.0/24 10.224.227.64/26
    "comm-vault-ro"        = ["127.0.0.1/32"]
    "ad-test"              = ["127.0.0.1/32"]
    "hnas"                 = ["10.226.108.132/32", "10.226.109.25/32"] # amznfsxpzzq563m.ms.aval
    "ms-share"             = ["10.191.2.30/32"]
    "tanker.noc-dc1"       = ["10.226.41.0/24"]
    "dman1-2"              = ["10.191.4.224/32", "10.191.4.225/32"]
    "oracle-db-stp"        = ["10.225.112.110/32"]
    "balance-in-data"      = ["10.226.108.234/32"]
    "lepte-in-data"        = ["10.225.112.35/32"]
    "mirinda"              = ["10.191.4.133/32", "10.191.4.134/32", "10.191.4.233/32"]
    "zuko"                 = ["10.191.4.155/32"]
    "soda"                 = ["10.191.5.99/32"]
    "lucky2"               = ["10.191.196.63/32"]
    "ose12x"               = ["10.191.204.100/32"]
    "rbua-vdi-it"          = ["10.226.45.0/24"]
    "data-internal-b"      = ["10.225.112.64/26"]
    "r-bm.todb"            = ["127.0.0.1/32"]
    "sheriff.tsdb"         = ["127.0.0.1/32"]
    "new-redbull.test"     = ["127.0.0.1/32"]
    "door"                 = ["10.191.50.39/32"]
    "oslo"                 = ["127.0.0.1/32"]  # oslo.test.kv.aval
    "monaco"               = ["127.0.0.1/32"]  # monaco.test.kv.aval
    "bamboo"               = ["127.0.0.1/32"]  # bamboo.test.kv.aval
    "spscrum"              = ["127.0.0.1/32"]  # spscrum.test.kv.aval
    "drive-g"              = ["10.191.2.0/23"] # drive g: access
    "robin"                = ["10.226.106.172/32", "10.226.106.204/32"]
    "cisaod"               = ["10.225.112.30/32"]
    "mars"                 = ["10.191.50.91/32"]
    "awsec2-wfile01"       = ["10.226.149.84/32"]
    "uadho-wfile01"        = ["10.191.2.30/32"]
    "ibrahim.b2"           = ["127.0.0.1/32"]
    "data-catalog"         = ["10.223.39.128/26", "10.223.39.196/32"]
    "swiftz"               = ["10.191.48.251/32"] # swiftz.app.kv.aval
    "nexus.test.kv.aval"   = ["10.225.102.17/32"]
    "dfs"                  = ["10.191.2.229/32"]
    "oracle-db-alfa"       = ["10.225.112.20/32"]
    "commondoor"           = ["10.226.106.0/26", "10.226.106.64/26", "10.191.2.106/32", "10.191.2.38/32"]
    "gamma"                = ["10.191.5.245/32"]
    "kiosk"                = ["10.191.4.81/32"]
    "multipool"            = ["10.191.12.110/32"]
    "leftpool"             = ["10.191.12.121/32"]
    "rightpool"            = ["10.191.12.119/32"]
    "uadho-wtech"          = ["10.191.49.192/26"]
    "leftnew"              = ["10.191.4.154/32"]
    "left2new"             = ["10.191.4.160/32"]
    "ndu"                  = ["10.0.90.7/32"]
    "nbu-http"             = ["172.22.200.93/32"]
    "nbu-https"            = ["172.22.26.21/32","172.22.200.136/32"]
    "oracle-db-autocd"     = ["10.225.112.8/32"]
    "mcduck.noc-dc1"       = ["10.191.3.99/32"]
    "oracle-db-inex"       = ["10.225.112.104/32"]
    "rba-users-nets"       = ["10.184.0.0/15", "10.190.64.0/19", "10.190.96.0/20"]
    "cyberark-subnet"      = ["10.191.242.32/28"]
    "yupi"                 = ["127.0.0.1/32"] # yupi.test.kv.aval
    "avalaunch-k8s-nat"    = ["10.225.125.125/32", "10.225.125.228/32", "10.225.126.117/32"]
    "cert-authority"       = ["10.226.113.0/26", "10.226.113.64/26"]
    "psgq-on-premise"      = ["10.191.56.32/27"]
    "psgl-unistatement"    = ["10.191.15.0/24"]
    "uadho-wfile"          = ["10.191.2.30/32", "10.191.2.40/32", "10.191.2.33/32", "10.191.2.229/32", "10.191.2.230/32", "10.191.2.70/32", "10.191.2.58/32", "10.191.2.176/32"]
    "dfs-wfile"            = ["10.191.135.20/32", "10.191.135.100/32"]
    "oracle_db_blpt"       = ["10.225.112.125/32"]
    "debt-sale"            = ["10.226.126.220/32", "10.226.126.185/32"]
    "mbank"                = ["10.191.12.55/32"]
    "tampa-on-premise"     = ["10.191.5.129/32"] # tampa.ms.aval
    "gdwh"                 = ["10.191.12.54/32", "10.191.12.205/32", "10.191.12.202/32"] # gdwhprod.odb.kv.aval, silver.odb.kv.aval, gold.odb.kv.aval
    "data-stage"           = ["10.225.112.0/26", "10.225.112.64/26"]
    "oracle_db_svcg"       = ["10.225.112.76/32"]
    "ldap-kdc"             = ["10.226.41.113/32", "10.191.2.112/32"]
    "ms-sql-report-server" = ["10.191.14.27/32", "10.191.4.41/32"]
    "vic-sdb"              = ["10.226.118.125/32"]
    "esb-tap01"            = ["127.0.0.1/32"]
    "was2jb"               = ["127.0.0.1/32"]
    "kafka"                = ["127.0.0.1/32"]
    "oracle_db_mpcs"       = ["10.226.108.237/32"]
    "b2admin"              = ["10.190.61.192/26"]
    "novell"               = ["127.0.0.1/32"]
    "mboser"               = ["10.190.71.32/27"]
    "a4665275478l-host1"   = ["10.190.71.43/32"]
    "a4665275477k-host1"   = ["10.190.71.42/32"]
  }

  dbs = {
    "hollywood-manhattan" = ["10.191.14.28/32", "10.191.14.27/32"] # hollywood.msdb.kv.aval, manhattan.msdb.kv.aval
    "rightpool-odb"       = ["10.191.12.119/32"]
    "imperator"           = ["10.191.14.11/32"]
  }

  pools = {
    "ho-pool-dba"          = ["10.190.62.128/26"]
    "ho-pool-payments"     = ["10.190.131.96/27"]
    "ho-pool-vpps"         = ["10.190.51.192/26"]
    "ho-pool-card-aws"     = ["127.0.0.1/32"]
    "ho-pool-devchannels"  = ["127.0.0.1/32"]
    "ho-pool-broker"       = ["10.190.49.0/26"]
    "ho-pool-opc10"        = ["10.190.56.0/22", "10.190.114.0/23"]
    "ho-pool-ho-dir"       = ["10.190.40.0/23", "10.190.42.0/23", "10.190.44.0/23", "10.190.46.0/23"]
    "ho-pool-osebsoftware" = ["10.190.50.32/27"]
    "ho-pool-ns"           = ["10.190.63.0/26"]
    "ho-pool-app-admin"    = ["10.190.51.0/25"]
    "ho-pool-card"         = ["10.190.50.128/25"]
    "ho-pool-lits"         = ["10.190.130.160/27"]
    "ho-pool-treasury"     = ["10.190.124.192/26"]
    "ho-pool-test"         = ["127.0.0.1/32"]
    "ho-pool-dbaho"        = ["10.190.49.0/26"]
    "ho-pool-devpay"       = ["10.190.135.0/25"]
  }

  aws_accounts = {
    "payments-test-05-transfer"                = ["127.0.0.1/32"]
    "payments-test-03-transfer"                = ["127.0.0.1/32"]
    "payments-prod-09-transfer"                = ["10.226.152.160/27", "10.226.152.128/27", "10.226.152.96/27"]
    "payments-prod-09-internal"                = ["10.226.152.0/27", "10.226.152.32/27", "10.226.152.64/27"]
    "payments-prod-08-transfer"                = ["10.226.122.48/28", "10.226.122.64/28", "10.226.122.80/28"]
    "payments-prod-08-internal"                = ["10.226.122.0/28", "10.226.122.16/28", "10.226.122.32/28"]
    "payments-prod-08-restricted"              = ["10.226.122.96/28", "10.226.122.112/28", "10.226.122.128/28"]
    "cbs-prod-01-internal"                     = ["10.226.130.192/26", "10.226.131.0/26", "10.226.131.64/26"]
    "cbs-prod-01-transfer"                     = ["10.226.131.128/26", "10.226.131.192/27", "10.226.131.224/27"]
    "cbs-prod-01-restricted"                   = ["10.226.130.0/26", "10.226.130.64/26", "10.226.130.128/26"]
    "data-dev-02-internal"                     = ["10.225.112.64/26"]
    "channels-intnoncritical-prod-02-transfer" = ["10.226.106.128/26", "10.226.106.192/26"]
    "channels-intnoncritical-prod-02-internal" = ["10.226.106.0/26", "10.226.106.64/26"]
    "technology-prod-internal"                 = ["10.226.108.0/24"]
    "aval-auth-test-transfer"                  = ["10.225.109.32/28", "10.225.109.48/28"]
    "backup-dev-xn83-internal"                 = ["10.225.116.0/26", "10.225.116.64/26"]
    "channels-intcritical-prod-01-internal"    = ["10.226.103.0/26", "10.226.103.64/26"]
    "avalaunch-dev-mig-2k3h-internal"          = ["10.225.125.0/25", "10.225.125.128/25", "10.225.126.0/25"]
    "avalaunch-dev-mig-2k3h-restricted"        = ["10.225.126.128/25", "10.225.127.0/25", "10.225.127.128/25"]
    "legacy-prod-01-internal"                  = ["10.226.155.0/27", "10.226.155.32/27"]
    "cybersecurity-iam-prod-internal"          = ["10.226.112.160/27", "10.226.112.192/27"]
    "custacc-prod-01-internal"                 = ["10.226.138.0/25", "10.226.138.128/25", "10.226.139.0/26" ]
    "nwu-dev-restricted"                       = ["127.0.0.1/32"]
    "channels-intnoncritical-test-02-transfer" = ["127.0.0.1/32"]
    "channels-intnoncritical-test-02-internal" = ["127.0.0.1/32"]
  }

}
