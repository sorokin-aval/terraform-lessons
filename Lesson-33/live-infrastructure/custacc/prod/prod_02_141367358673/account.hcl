# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.

locals {
  env                 = basename(dirname(get_terragrunt_dir()))
  aws_account_id      = tostring(regex("[0-9]+$", basename(get_terragrunt_dir())))
  platform_ami        = "ami-075a19ab0b7fc6267"
  tags           = merge( read_terragrunt_config(find_in_parent_folders("group.hcl")).locals.tags, {
    "security:environment" = "Prod"
    "business:cost-center" = "653"
    "internet-faced"       = "false"
  } )

  sources = {
    "baseline"        = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//aws-baseline?ref=baseline_v2.9.1"
    "vpc_info"        = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-vpc-info.git//.?ref=v1.1.0"
    "sg"              = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git//"
    "key-pair"        = "git::https://github.com/terraform-aws-modules/terraform-aws-key-pair.git//.?ref=v2.0.0"
    "quotas"          = "git::https://github.com/cloudposse/terraform-aws-service-quotas.git//.?ref=v0.1.0"
    "efs"             = "git::https://github.com/cloudposse/terraform-aws-efs.git//.?ref=0.32.7"
    "host"            = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-platform-host.git//.?ref=v2.0.3"
    "route-rules"     = "git::https://github.com/terraform-aws-modules/terraform-aws-route53.git//modules/resolver-rule-associations?ref=v2.10.1"
  }

  ips = {
    "db-syslog"       = "10.226.114.72/32"
    "zabbix"          = ["10.225.102.0/23"]
    "ad"              = ["10.225.109.4/32", "10.225.109.20/32", "10.191.2.192/27"]
    "cyberark"        = ["10.0.0.0/8"]
    "dms_dc"          = ["10.191.4.128/32", "10.191.5.160/32", "10.191.4.135/32", "10.191.4.68/32", "10.191.4.185/32", "10.191.4.145/32", "10.191.5.189/32", "10.191.5.188/32", "10.191.4.143/32", "10.191.4.150/32", "10.191.4.180/32", "10.191.4.181/32", "10.191.4.123/32", "10.191.4.124/32"]
  }

  service_quotas = [
    {
      quota_code       = "L-0EA8095F"     # aka `Inbound or outbound rules per security group`
      service_code     = "vpc"
      value            = 125              # default `60`
    },
    {
      quota_code       = "L-2AFB9258"   # aka `Security groups per network interface`
      service_code     = "vpc"
      value            = 8              # default `5`
    }
  ]

  route53_resolver_rule_associations = {
    "infr"            = { resolver_rule_id = "rslvr-rr-47b864c9e8c843179" },
  }

  ec2 = {
   # DMS
    "canazein" = {
      "instance_type"      = "t3a.2xlarge"
      "availability_zone"  = "eu-central-1a"
      "ebs_size_gb"        = "50"
    }
    "mazzinn" = {
      "instance_type"      = "t3a.2xlarge"
      "availability_zone"  = "eu-central-1b"
      "ebs_size_gb"        = "50"
    }
    "apsw5" = {
      "instance_type"      = "t3a.2xlarge"
      "availability_zone"  = "eu-central-1a"
      "ebs_size_gb"        = "30"
      "root_size_gb"       = "8"
      "ebs_type"           = "gp3"
    }
    "apsw6" = {
      "instance_type"      = "t3a.2xlarge"
      "availability_zone"  = "eu-central-1b"
      "ebs_size_gb"        = "30"
      "root_size_gb"       = "8"
      "ebs_type"           = "gp3"
    }
  }
}
iam_role = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"