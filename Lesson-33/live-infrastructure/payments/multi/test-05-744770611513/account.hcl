# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.

locals {
  aws_account_id    = "744770611513"
  vpc               = "vpc-06ffdaa354246964a"
  environment       = "test"
  domain            = "test-payments.rbua"
  directory_service = "d-99671b1f03" # The ID of the Directory Service
  pca               = "arn:aws:acm-pca:eu-central-1:416957951464:certificate-authority/cb7a9ed0-af05-4593-a013-81c8858aa8ba"
  core_subdomain    = "test-05"
  disable_api_termination = false
  iam_role          = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
  tags              = merge( read_terragrunt_config(find_in_parent_folders("group.hcl")).locals.tags, {
    "security:environment" = "Test"
  } )

  sources = {
    "host"             = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-host.git//?ref=v1.2.0" : find_in_parent_folders("ua-tf-aws-payments-host")
    "sg"               = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git//"
    "rds"              = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git//"
    "acm"              = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-acm-certificate.git//?ref=v1.0.0" : find_in_parent_folders("ua-tf-aws-acm-certificate")
    "vpc-info"         = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//vpc_info?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/vpc_info")
    "route53-alb"      = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/route53-alb?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/payments/route53-alb")
    "route53-endpoint" = get_env("TERRAGRUNT_MODULE", "git") != "local" ? "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules//payments/route53-resolver-endpoint?ref=payments/main" : find_in_parent_folders("ua-avalaunch-terraform-modules/payments/route53-resolver-endpoint")
    "aws-alb"          = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git//?ref=v7.0.0"
    "aws-s3-bucket"    = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git//?ref=v3.3.0"
    "target-group"     = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-payments-lb-target-groups//?ref=v1.0.1"
    "route53-records"  = "github.com/terraform-aws-modules/terraform-aws-route53.git//modules/records?ref=v2.9.0"
    "baseline"         = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-baseline.git//?ref=v3.0.1"
    "aurora"           = "git::https://github.com/terraform-aws-modules/terraform-aws-rds-aurora.git//?ref=v7.6.0"
    "commvault"        = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-commvault-backup.git//"
  }

  default_alb_certificate = "arn:aws:acm:eu-central-1:744770611513:certificate/1293c40a-8b2c-4e08-a852-e19e3d82436a"

  ec2_types = {
    # PTELE
    "was-ap01.ptele" = "r5a.large"
    "was-ap02.ptele" = "r5a.large"
    "db01.ptele"     = "r5a.large"
    # STP
    "was-ap01.stp" = "r5.large"
    "was-ap02.stp" = "r5.large"
    "db01.stp"     = "r5.large"
    # was-sake
    "ap01.was-sake" = "m6i.large"
    # Smartclearing
    "was-ap01.smartclearing" = "r5.large"
    "was-ap02.smartclearing" = "r5.large"
    "db01.smartclearing"     = "r5.large"
    # Balance 2
    "ap01.balance2" = "t2.small"
    # Camunda
    "ap01.camunda"         = "t3a.small"
    "ap02.camunda"         = "t3a.small"
    "cockpit-ap01.camunda" = "t3a.small"
    # BCPay/NLO
    "ap01.glassfish" = "r5.large"
    # Avtokassa
    "ap01.avtokassa"         = "t3a.small"
    "ap02.avtokassa"         = "t3a.small"
    "db01.avtokassa"         = "r5.xlarge"
    "restore-db01.avtokassa" = "r5.xlarge"
    # Keeper
    "db01.keeper" = "m6a.large"
    "db02.keeper" = "m6a.large"
    "ap01.keeper" = "t3a.medium"
    # Trust
    "was-ap01.trust" = "t3.medium"
    "was-ap02.trust" = "t3.medium"  
    "tampa01.trust"  = "t3.medium"
    # Inex
    "db01.inex" = "r5b.large"
    "ap01.inex" = "t3.medium"
    "ap02.inex" = "t3.medium"
    # DD
    "db01.dd" = "r5.large"
    "ap01.dd" = "t2.micro"
    # Satelit
    "ap01.satelit" = "t3.nano"
    # TBO
    "ap01.tbo" = "t2.micro"
    # Smartvista
    "ap01.smartvista" = "t3.medium"
    "db01.smartvista" = "r5b.large"
  }

  rds_types = {
    "rds-voyager"        = "db.m5.large"
    "rds-camunda"        = "db.t4g.2xlarge"
    "rds-trust"          = "db.r5.large"
    "rds-tbo"            = "db.m5.large"
    "aurora-unistatment" = "db.t3.large"
  }

  rds_multi_az = {
    "rds-voyager"       = false
    "rds-camunda"       = false
    "rds-trust"         = false
    "rds-tbo"           = false
  }


  ips = {
    "db-syslog"            = "10.226.114.72/32"
    "zabbix"               = ["10.225.102.4/32"]
    "v-cardtr.tmydb"       = ["10.191.207.38/32"]
    "unistatement1.mydb"   = ["10.191.15.36/32"]
    "unistatement2.mydb"   = ["10.191.15.37/32"]
    "on-premise-databases" = ["127.0.0.1/32"]
    "satellite"            = ["10.191.2.105/32"] # satellite.noc-dc1.kv.aval
    "cyberark"             = ["10.0.0.0/8"]
    "aval-common-test"     = ["10.225.103.0/24", "10.225.102.0/24"]
    "ad"                   = ["10.225.109.0/27", "10.191.2.192/27", "10.227.50.128/25"]
    "kms-windows"          = ["10.191.2.57/32", "10.191.2.107/32"]
    "ad-test"              = ["10.191.199.200/32", "10.191.199.201/32", "10.191.199.202/32"]
    "broker"               = ["10.226.119.162/32"]
    "test-app-pw"          = ["10.226.119.128/26"]
    "arcsight"             = ["10.226.114.0/24"]
    "hnas"                 = ["10.226.108.132/32", "10.226.109.25/32"] # amznfsxpzzq563m.ms.aval
    "ms-share"             = ["10.191.2.30/32"]
    "tanker.noc-dc1"       = ["10.226.41.0/24"]
    "dman1-2"              = ["10.191.4.224/32", "10.191.4.225/32"]
    "bigpoint.ms.aval"     = ["10.191.2.184/32"]
    "oracle-db-stp"        = ["10.225.112.110/32"]
    "balance-in-data"      = ["10.226.108.234/32"]
    "comm-vault"           = ["10.191.2.184/32"]
    "comm-vault-ro"        = ["10.227.54.8/32"]
    "lepte-in-data"        = ["127.0.0.1/32"]
    "mirinda"              = ["127.0.0.1/32"]
    "zuko"                 = ["127.0.0.1/32"]
    "soda"                 = ["127.0.0.1/32"]
    "lucky2"               = ["10.191.196.63/32"]
    "ose12x"               = ["10.191.204.100/32"]
    "rbua-vdi-it"          = ["127.0.0.1/32"]
    "data-internal-b"      = ["127.0.0.1/32"]
    "r-bm.todb"            = ["10.191.204.117/32"]
    "sheriff.tsdb"         = ["10.191.205.13/32"]
    "new-redbull.test"     = ["10.191.196.6/32"]
    "door"                 = ["10.191.50.39/32"]
    "oslo"                 = ["10.191.196.118/32"] # oslo.test.kv.aval
    "monaco"               = ["10.191.196.71/32"]  # monaco.test.kv.aval
    "bamboo"               = ["10.191.199.35/32"]  # bamboo.test.kv.aval
    "spscrum"              = ["10.191.196.149/32"] # spscrum.test.kv.aval
    "drive-g"              = ["10.191.2.0/23"]     # drive g: access
    "awsec2-wfile01"       = ["10.226.149.84/32"]
    "uadho-wfile01"        = ["10.191.2.30/32"]
    "data-catalog"         = ["127.0.0.1/32"]
    "swiftz"               = ["10.191.194.228/32"] # swifty.test.kv.aval
    "nexus.test.kv.aval"   = ["127.0.0.1/32"]
    "dfs"                  = ["10.191.2.229/32"]
    "ndu"                  = ["10.0.56.7/32"]
    "nbu-http"             = ["172.22.200.30/32"]
    "nbu-https"            = ["172.22.2.146/32"]
    "oracle-db-autocd"     = ["127.0.0.1/32"]
    "mcduck.noc-dc1"       = ["10.191.3.99/32"]
    "oracle-db-inex"       = ["10.225.112.104/32"]
    "rba-users-nets"       = ["10.184.0.0/15", "10.190.64.0/19", "10.190.96.0/20"]
    "cyberark-subnet"      = ["10.191.242.32/28"]
    "yupi"                 = ["10.191.199.130/32"] # yupi.test.kv.aval
    "avalaunch-k8s-nat"    = ["10.225.121.76/32", "10.225.121.184/32", "10.225.122.19/32"]
    "cert-authority"       = ["10.226.113.0/26", "10.226.113.64/26"]
    "b2x"                  = ["10.191.204.88/32"] # b2x.todb.kv.aval
    "sierra"               = ["10.191.196.137/32"] # sierra.test.kv.aval
    "uadho-wfile"          = ["10.191.2.30/32", "10.191.2.40/32", "10.191.2.33/32", "10.191.2.229/32", "10.191.2.230/32", "10.191.2.70/32", "10.191.2.58/32", "10.191.2.176/32"]
    "dfs-wfile"            = ["10.191.135.20/32", "10.191.135.100/32"]
    "oracle_db_blpt"       = ["10.225.112.125/32"]
    "mbank"                = ["127.0.0.1/32"]
    "debt-sale"            = ["127.0.0.1/32"]
    "tampa-on-premise"     = ["10.191.5.129/32"] # tampa.ms.aval
    "gdwh"                 = ["10.191.195.100/32"] # dwhx.todb.kv.aval
    "data-stage"           = ["127.0.0.1/32"]
    "ldap-kdc"             = ["10.226.41.113/32", "10.191.2.112/32"]
    "ms-sql-report-server" = ["127.0.0.1/32"]
    "vic-sdb"              = ["127.0.0.1/32"]
    "esb-tap01"            = ["10.226.118.141/32"]
    "was2jb"               = ["10.226.107.0/26"]
    "kafka"                = ["10.225.123.202/32", "10.225.122.247/32", "10.225.123.28/32"]
    "oracle_db_mpcs"       = ["10.226.108.237/32"]
    "b2admin"              = ["127.0.0.1/32"]
    "novell"               = ["10.226.40.73/32"]
    "oracle_db_blpt"       = ["10.225.112.125/32"]
    "mboser"               = ["127.0.0.1/32"]
    "a4665275478l-host1"   = ["10.190.71.43/32"]
    "a4665275477k-host1"   = ["10.190.71.42/32"]
  }

  dbs = {
    "hollywood-manhattan" = ["10.191.14.28/32", "10.191.14.27/32"] # hollywood.msdb.kv.aval, manhattan.msdb.kv.aval
    "rightpool-odb"       = ["10.191.12.119/32"]
    "imperator"           = ["10.191.14.11/32"]
    "bpm"                 = ["10.191.207.6/32"] # bpm-db.tmydb.kv.aval
  }

  pools = {
    "ho-pool-dba"          = ["10.190.62.128/26"]
    "ho-pool-payments"     = ["10.190.131.96/27"]
    "ho-pool-vpps"         = ["10.190.51.192/26"]
    "ho-pool-card-aws"     = ["127.0.0.1/32"]
    "ho-pool-devchannels"  = ["10.190.133.0/24"]
    "ho-pool-broker"       = ["10.190.49.0/26"]
    "ho-pool-opc10"        = ["10.190.114.0/23", "10.190.56.0/22"]
    "ho-pool-ho-dir"       = ["10.190.40.0/23", "10.190.42.0/23", "10.190.44.0/23", "10.190.46.0/23"]
    "ho-pool-osebsoftware" = ["127.0.0.1/32"]
    "ho-pool-ns"           = ["127.0.0.1/32"]
    "ho-pool-app-admin"    = ["10.190.51.0/25"]
    "ho-pool-card"         = ["10.190.50.128/25"]
    "ho-pool-test"         = ["10.190.122.0/24"]
    "ho-pool-treasury"     = ["10.190.124.192/26"]
    "ho-pool-dbaho"        = ["10.190.49.0/26"]
    "ho-pool-devpay"       = ["10.190.135.0/25"]
  }

  aws_accounts = {
    "payments-test-05-transfer"                = ["10.226.142.160/27", "10.226.142.128/27", "10.226.142.96/27"]
    "payments-test-05-internal"                = ["10.226.142.0/27", "10.226.142.32/27", "10.226.142.64/27"]
    "payments-test-03-transfer"                = ["10.226.123.48/28", "10.226.123.64/28", "10.226.123.80/28"]
    "payments-test-03-internal"                = ["10.226.123.0/28", "10.226.123.16/28", "10.226.123.32/28"]
    "payments-prod-09-transfer"                = ["127.0.0.1/32"]
    "payments-prod-09-internal"                = ["127.0.0.1/32"]
    "payments-prod-08-transfer"                = ["127.0.0.1/32"]
    "cbs-prod-01-transfer"                     = ["127.0.0.1/32"]
    "data-dev-02-internal"                     = ["127.0.0.1/32"]
    "channels-intnoncritical-prod-02-transfer" = ["127.0.0.1/32"]
    "channels-intnoncritical-prod-02-internal" = ["127.0.0.1/32"]
    "channels-intcritical-prod-01-internal"    = ["127.0.0.1/32"]
    "cbs-prod-01-restricted"                   = ["127.0.0.1/32"]
    "technology-prod-internal"                 = ["127.0.0.1/32"]
    "aval-auth-test-transfer"                  = ["10.225.109.32/28", "10.225.109.48/28"]
    "backup-dev-xn83-internal"                 = ["10.225.116.0/26", "10.225.116.64/26"]
    "avalaunch-dev-mig-2k3h-internal"          = ["127.0.0.1/32"]
    "avalaunch-dev-mig-2k3h-restricted"        = ["127.0.0.1/32"]
    "avalaunch-dev-mzwc-internal"              = ["10.225.121.0/25", "10.225.121.128/25", "10.225.122.0/25"]
    "custacc-prod-01-internal"                 = ["127.0.0.1/32"]
    "cbs-prod-01-internal"                     = ["127.0.0.1/32"]
    "nwu-dev-restricted"                       = ["10.226.96.128/25", "10.226.97.0/25", "10.226.97.128/25"]
    "channels-intnoncritical-test-02-transfer" = ["10.226.104.128/26", "10.226.104.192/26"]
    "channels-intnoncritical-test-02-internal" = ["10.226.104.0/26", "10.226.104.64/26"]
  }

}
