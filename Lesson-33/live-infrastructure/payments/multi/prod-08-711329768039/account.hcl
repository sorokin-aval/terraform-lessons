# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.

locals {
  aws_account_id = "711329768039"
  vpc            = "vpc-0758f74c8554224a8"
  environment    = "prod"
  domain         = "payments.rbua"
  new_domain     = "payments.rbua"
  pca            = "arn:aws:acm-pca:eu-central-1:416957951464:certificate-authority/cb7a9ed0-af05-4593-a013-81c8858aa8ba"
  core_subdomain = "prod-08"
  tags = merge(read_terragrunt_config(find_in_parent_folders("group.hcl")).locals.tags, {
    "security:environment" = "Prod"
  })

  sources = {
    "host"             = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-host.git//" : find_in_parent_folders("ua-tf-aws-payments-host")
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

  certificate_arn = "arn:aws:acm:eu-central-1:711329768039:certificate/1180ef11-13a2-470a-bc75-dbac78a45b69"

  default_alb_certificate = "arn:aws:acm:eu-central-1:711329768039:certificate/191c5c60-f401-419c-a169-540bf9133f1a"

  sg = {
    "dns" = ""
  }

  ec2_types = {
    "bastion" = "t2.micro"
    "cv-ma01" = "m5zn.3xlarge"
    # IS-Card
    "cnp-ap01.is-card"              = "t3a.medium"
    "cnp-ap02.is-card"              = "t3a.medium"
    "cnp-vienna-ap01.is-card"       = "t3a.medium"
    "cnp-vienna-ap02.is-card"       = "t3a.medium"
    "connector-ap01.is-card"        = "t3a.medium"
    "connector-ap02.is-card"        = "t3a.medium"
    "connector-vienna-ap01.is-card" = "t3a.medium"
    "connector-vienna-ap02.is-card" = "t3a.medium"
    "tpiimini-ap01.is-card"         = "t3a.large"
    "tpiimini-ap02.is-card"         = "t3a.large"
    "tpiimini-vienna-ap01.is-card"  = "t3a.large"
    "tpiimini-vienna-ap02.is-card"  = "t3a.large"
    "db01.is-card"                  = "r5.4xlarge"
    "db02.is-card"                  = "r5b.4xlarge"
    "db03.is-card"                  = "r5b.4xlarge"
    # Norkom
    "golden-ap01.norkom" = "r5a.4xlarge"
    "golden-ap02.norkom" = "r5a.2xlarge"
    "db01.norkom"        = "r5.8xlarge"
    "db02.norkom"        = "r5.8xlarge"
    # VPOS / PTE
    "was-ap01.pte" = "r5a.xlarge"
    "was-ap02.pte" = "r5a.xlarge"
    "was-ap03.pte" = "r5a.xlarge"
    "db01.pte"     = "r5.4xlarge"
    "db02.pte"     = "r5.4xlarge"
    "db01.vpos"    = "r5.2xlarge"
    "db02.vpos"    = "r5.2xlarge"
    # PTELE
    "was-ap01.ptele" = "r5a.large"
    "was-ap02.ptele" = "r5a.large"
    "db01.ptele"     = "r5a.large"
    # TM
    "shovel-ap01.tm"      = "t3a.medium"
    "sortoutfile-ap01.tm" = "t3a.small"
    "web-ap01.tm"         = "t3a.medium"
    "technolog-ap01.tm"   = "t3.medium"
    "technolog-ap02.tm"   = "t3.medium"
    "mft-ap01.tm"         = "t3.medium"
    "mft-ap02.tm"         = "t3.medium"
    "db01.tm"             = "r5b.8xlarge"
    "db02.tm"             = "r5.8xlarge"
    # EmailSender
    "ap01.emailsender" = "t3a.medium"
    # SMTP
    "ap01.smtp" = "t2.micro"

  }

  ips = {
    "vip-inet-dmz"         = ["10.191.253.141/32"]
    "db-syslog"            = "10.226.114.72/32"
    "zabbix"               = ["10.225.102.4/32"]
    "dbre-vdi-pool"        = ["10.190.62.128/26"]
    "pos-gateway"          = ["10.244.254.139/32"]
    "pos-gateway-vienna"   = ["10.7.98.102/32"]
    "tpii-advice-host"     = ["10.244.254.166/32"]
    "tpii-advice-vienna"   = ["10.7.97.130/32"]
    "autoquery"            = ["10.244.254.143/32", "10.244.254.151/32"]
    "autoquery-vienna"     = ["10.7.98.115/32"]
    "ad"                   = ["10.225.109.0/27", "10.191.2.192/27", "10.227.50.128/25"]
    "kms-windows"          = ["10.191.2.57/32", "10.191.2.107/32"]
    "cyberark"             = ["10.0.0.0/8"]
    "broker"               = ["10.226.118.52"]                                                                # delete after adding ibm zone to the account
    "ibm-mb"               = ["10.226.102.14/32", "10.226.102.39/32", "10.226.119.23/32", "10.226.118.52/32"] # esb.ibm.rbua LB
    "osa12x.test-dmz"      = ["10.191.254.15/32"]
    "ose12x.todb"          = ["10.191.204.100/32"]
    "test.aval"            = ["10.191.199.200/32", "10.191.199.201/32", "10.191.199.202/32"]
    "arcsight"             = ["10.226.114.0/25"]
    "arcsight-esm"         = ["10.191.8.64/26"]
    "b-tm.todb"            = ["10.191.204.122/32"]
    "sheriff.tsdb"         = ["10.191.205.13/32"]
    "ps-hsm"               = ["10.185.2.23/32", "10.191.22.167/32"]
    "biffit-lb"            = ["10.226.105.64/26", "10.226.105.128/26"]
    "on-premise-databases" = ["10.191.12.0/24", "10.191.56.0/27"]
    "amftpro-in-data"      = ["10.225.112.123/32"]
    "data-stage"           = ["10.191.4.233/32"]
    "hnas"                 = ["10.226.108.132/32", "10.226.109.25/32"] # amznfsxpzzq563m.ms.aval
    "satellite"            = ["10.191.2.105/32"]                       # satellite.noc-dc1.kv.aval
    "comm-vault"           = ["10.191.2.184/32", "10.226.122.0/24", "10.223.45.0/26", "10.224.227.64/26", "10.225.106.253/32"]
    "mft-vienna"           = ["10.7.98.112/32"]
    "rhui3"                = ["3.120.254.163/32"]
    "cisaod"               = ["10.191.12.8/32", "10.225.112.30/32"] # cisaod.odb.kv.aval
    "barracuda"            = ["10.191.20.6/32"]                     # barracuda.ms.aval
    "tuna"                 = ["10.191.20.17/32"]                    # tuna.ms.aval
    "yakus"                = ["10.191.5.150/32"]                    # yakus.app.kv.aval
    "door"                 = ["10.191.50.39/32"]                    # door.slb.kv.aval
    "nagios"               = ["10.225.102.104/32"]
    "aws-wfile"            = ["10.226.41.69/32"]  # aws-wfile02.ms.aval# awsec2-wfile01.ms.aval
    "dfs-wfile"            = ["10.191.2.0/24", "10.191.135.20/32", "10.191.135.100/32"]
    "aval-common-test"     = ["10.225.103.0/24", "10.225.102.0/24"] # 136812256255
    "uadho-wctm901"        = ["10.191.135.80/32"]                   # uadho-wctm901.ms.aval
    "zuko"                 = ["10.191.4.155/32", "10.191.4.175/32"] # zuko.app.kv.aval, zuko1.app.kv.aval
    "mirinda"              = ["10.191.4.133/32", "10.191.4.134/32"] # mirinda{1,2}.app.kv.aval
    "mft-kyiv"             = ["10.244.254.198/32"]
    "nifi"                 = ["10.225.121.0/24"]
    "data-catalog"         = ["10.223.39.128/26", "10.223.39.196/32"]
    "rinfo-app"            = ["10.226.108.69/32", "10.226.108.163/32", "10.191.32.0/24"]
    "rinfo-dev"            = ["127.0.0.1/32"]
    "rinfo-app-on-premise" = ["10.185.30.42/32", "10.185.30.45/32"]
    "darkstar"             = ["10.191.5.121/32"]   # darkstar.app.kv.aval
    "latino"               = ["10.191.5.122/32"]   # latino.app.kv.aval
    "celer"                = ["10.191.4.12/32"]    # celer.app.kv.aval
    "control-m"            = ["10.226.130.254/32"] # tech01.ctm.cbs.rbua
    "kiosk"                = ["10.226.106.0/26", "10.226.106.64/26"]
    "on-premise-system"    = ["10.191.4.0/24", "10.191.5.0/24"]
    "kafka-dmz"            = ["10.225.126.128/25", "10.225.127.0/25", "10.225.127.128/25"]
    "idm"                  = ["10.226.112.160/27", "10.226.112.192/27"]
    "vip"                  = ["10.46.1.154/32", "10.191.4.121/32"]
    "mbank"                = ["10.44.0.18/32", "10.191.4.122/32"]
    "kiosk-app"            = ["10.191.4.81/32"]
    "gamma"                = ["10.191.5.245/32"]
    "blue-prism"           = ["10.190.130.0/26", "10.191.149.128/25", "10.226.40.128/25", "10.227.38.0/24"]
    "soda"                 = ["10.191.5.99/32"]
    "debt-manager"         = ["10.191.0.0/28"]
    "newtm-in-data"        = ["10.225.112.13/32"]
    "yupi"                 = ["127.0.0.1/32"]
    "iscardb.todb"         = ["10.191.204.127/32"]
    "iq.sdb"               = ["10.191.13.6/32"]
    "rightrock-vip.odb"    = ["10.191.12.216/32"]
    "lucky2"               = ["127.0.0.1/32"]
    "cda-deploy"           = ["10.191.195.136/32"]
    "uadho-wtech"          = ["10.191.49.192/26"]
    "dbKioskDblinks"       = ["10.226.108.254/32", "10.226.122.104/32"]
    "test-qa"              = ["127.0.0.1/32"]
    "vip.inet-dmz"         = ["10.191.253.141/32"]
    "sheriff2019.sdb"      = ["10.191.13.10/32"]
    "dwhx.todb.kv.aval"    = ["127.0.0.1/32"]
    "gdwhprod.odb.kv.aval" = ["10.191.12.54/32"]
    "silver.odb.kv.aval"   = ["10.191.12.205/32"]
    "gold.odb.kv.aval"     = ["10.191.12.202/32"]
    "sheriff-aws"          = ["10.226.106.172/32", "10.226.106.204/32"]
    "ibrahim.b2"           = ["127.0.0.1/32"]
    "awsec2-wfile01"       = ["10.226.149.84/32"]
    "uadho-wfile01"        = ["10.191.2.30/32"]
    "nifi-prod"            = ["10.225.125.118/32", "10.225.125.51/32", "10.225.125.58/32"]
    "kafka"                = ["127.0.0.1/32"]
    "mcduck.noc-dc1"       = ["10.191.3.99/32"]
    "floyd.todb"           = ["127.0.0.1/32"]
    "db3.odb"              = ["10.226.130.32/32"]
    "uadho-wfile"          = ["10.191.2.30/32", "10.191.2.40/32", "10.191.2.33/32", "10.191.2.229/32", "10.191.2.230/32", "10.191.2.70/32", "10.191.2.58/32", "10.191.2.176/32"]
    "datastage"            = ["127.0.0.1/32"]
    "tenable"              = ["10.191.22.192/27"]
    "satellite-c"          = ["10.225.103.114/32"]
    "dm-odb02"             = ["10.226.119.91/32"] # dm-odb02.ibm.rbua

    "general-is-card" = [
      "10.190.114.112/32",
      "10.190.115.19/32",
      "10.190.40.158/32",
      "10.190.50.142/32",
      "10.190.58.198/32",
      "10.190.64.233/32",
      "10.191.1.3/32",
      "10.191.1.4/32",
      "10.191.12.205/32",
      "10.191.12.208/32",
      "10.191.12.211/32",
      "10.191.252.32/28",
      "10.191.32.64/27",
      "10.191.49.201/32",
      "10.191.5.202/32",
      "10.191.8.0/26",
      "10.225.112.68/32",
      "10.225.125.125/32",
      "10.225.125.228/32",
      "10.225.126.117/32",
      "10.226.106.118/32",
      "10.226.106.58/32",
      "10.226.122.12/32",
      "10.226.122.21/32",
      "10.226.122.39/32",
      "10.226.122.41/32"
    ]
    "general-tm-1" = [
      "10.190.114.113/32",
      "10.190.114.120/32",
      "10.190.114.13/32",
      "10.190.114.149/32",
      "10.190.114.210/32",
      "10.190.114.211/32",
      "10.190.114.36/32",
      "10.190.114.50/32",
      "10.190.115.19/32",
      "10.190.247.153/32",
      "10.190.40.193/32",
      "10.190.40.94/32",
      "10.190.42.130/32",
      "10.190.42.151/32",
      "10.190.43.19/32",
      "10.190.43.35/32",
      "10.190.44.113/32",
      "10.190.44.177/32",
      "10.190.44.212/32",
      "10.190.44.34/32",
      "10.190.44.86/32",
      "10.190.44.87/32",
      "10.190.44.88/32",
      "10.190.45.33/32",
      "10.190.45.6/32",
      "10.190.46.116/32",
      "10.190.46.230/32",
      "10.190.46.233/32",
      "10.190.46.234/32",
      "10.190.46.247/32",
      "10.190.46.58/32",
      "10.190.46.91/32",
      "10.190.47.32/32",
      "10.190.50.132/32",
      "10.190.50.143/32",
      "10.190.56.156/32",
      "10.190.56.167/32",
      "10.190.56.213/32",
      "10.190.56.37/32",
      "10.190.56.60/32",
      "10.190.56.88/32",
      "10.190.57.134/32",
      "10.190.57.140/32",
      "10.190.57.147/32",
      "10.190.57.188/32",
      "10.190.57.203/32",
      "10.190.57.22/32",
      "10.190.57.251/32",
      "10.190.57.254/32",
      "10.190.58.118/32",
      "10.190.58.126/32",
      "10.190.58.139/32",
      "10.190.58.188/32",
      "10.190.58.197/32",
      "10.190.58.205/32",
      "10.190.58.214/32",
    ]
    "general-tm-2" = [
      "10.190.58.231/32",
      "10.190.58.25/32",
      "10.190.64.233/32",
      "10.191.252.32/28",
      "10.191.32.5/32",
      "10.191.32.6/32",
      "10.191.4.102/32",
      "10.191.4.132/32",
      "10.191.49.234/32",
      "10.191.5.104/32",
      "10.191.5.153/32",
      "10.191.5.201/32",
      "10.191.5.244/32",
      "10.191.5.6/32",
      "10.191.5.60/32",
      "10.191.5.99/32",
      "10.191.56.3/32",
      "10.191.8.12/32",
      "10.191.8.15/32",
      "10.191.8.33/32",
      "10.225.112.68/32",
      "10.225.125.125/32",
      "10.225.125.228/32",
      "10.225.126.117/32",
      "10.226.105.80/32",
      "10.226.106.118/32",
      "10.226.106.58/32",
      "10.226.112.179/32",
    ]
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
    "ho-pool-etl"         = ["10.190.49.0/26"]
    "ho-pool-sft"         = ["10.190.131.128/26"]
    "cbtp-pool"           = ["127.0.0.1/32"]
    "ho-pool-le"          = ["127.0.0.1/32"]
    "ho-pool-ho-dir"      = ["10.190.40.0/23", "10.190.42.0/23", "10.190.44.0/23", "10.190.46.0/23"]
    "ho-pool-opc10"       = ["10.190.56.0/22", "10.190.114.0/23"]
    "ho-pool-itanalitics" = ["127.0.0.1/32"]
    "ho-pool-ns"          = ["10.190.63.0/26"]
    "ho-pool-devpay"      = ["127.0.0.1/32"]
  }

  aws_accounts = {
    "rbua-custacc-internal"                    = ["10.226.138.0/25", "10.226.138.128/25", "10.226.139.0/26"]
    "rbua-cbs-transfer"                        = ["10.226.131.128/26", "10.226.131.192/27", "10.226.131.224/27"] # rbua-cbs-prod-01
    "rbua-cbs-internal"                        = ["10.226.130.192/26", "10.226.131.0/26", "10.226.131.64/26"]    # rbua-cbs-prod-01
    "rbua-cbs-restricted"                      = ["10.226.130.0/26", "10.226.130.64/26", "10.226.130.128/26"]    # rbua-cbs-prod-01
    "rbua-custacc-internal"                    = ["10.226.138.0/25", "10.226.138.128/25", "10.226.139.0/26"]     # rbua_custacc_prod_01
    "rbua-payments-internal"                   = ["10.226.152.0/27", "10.226.152.32/27", "10.226.152.64/27"]
    "rbua-appstream-prod"                      = ["10.226.160.0/20"]
    "payments-prod-08-transfer"                = ["10.226.122.48/28", "10.226.122.64/28", "10.226.122.80/28"]
    "payments-prod-08-internal"                = ["10.226.122.0/28", "10.226.122.16/28", "10.226.122.32/28"]
    "payments-prod-09-internal"                = ["10.226.152.0/27", "10.226.152.32/27", "10.226.152.64/27"]
    "payments-prod-09-transfer"                = ["10.226.152.96/27", "10.226.152.128/27", "10.226.152.160/27"]
    "payments-prod-09-restricted"              = ["10.226.152.192/27", "10.226.152.224/27", "10.226.153.0/27"]
    "cbs-dev-01"                               = ["127.0.0.1/32"]
    "channels-intnoncritical-prod-02-transfer" = ["10.226.106.128/26", "10.226.106.192/26"]
    "avalaunch-dev-mig-2k3h-internal"          = ["10.225.125.0/25", "10.225.125.128/25", "10.225.126.0/25"]
  }
}
