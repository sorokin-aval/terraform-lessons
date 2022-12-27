# Custacc
include {
  path = find_in_parent_folders()
}

iam_role = local.account_vars.iam_role

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
  #  config_path = "../../core-infrastructure/vpc-info/"
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.9.0"
  # source = local.account_vars.locals.sources["sg"]
}

locals {
  #  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  app_vars     = read_terragrunt_config(find_in_parent_folders("application.hcl"))
  #  tags_map     = local.common_tags.locals
}

inputs = {
  name            = basename(get_terragrunt_dir())
  use_name_prefix = false
  description     = "Security group for Active Directory"
  vpc_id          = dependency.vpc.outputs.vpc_id.id
  #  tags            = local.tags_map
  tags = merge(local.app_vars.locals.tags, {})

  egress_ipv6_cidr_blocks = []
  egress_cidr_blocks      = local.account_vars.locals.ips["ad"]
  egress_rules            = ["ldap-tcp", "ldaps-tcp", "dns-udp", "ntp-udp", "all-icmp"]

  egress_with_cidr_blocks = [
    {
      from_port   = 389
      to_port     = 389
      protocol    = "udp"
      description = "LDAP UDP"
    },
    {
      from_port   = 88
      to_port     = 88
      protocol    = "tcp"
      description = "Kerberos"
    },
    {
      from_port   = 464
      to_port     = 464
      protocol    = "tcp"
      description = "Kerberos Password Change"
    },
    {
      from_port   = 135
      to_port     = 135
      protocol    = "tcp"
      description = "RPC"
    },
    {
      from_port   = 137
      to_port     = 138
      protocol    = "udp"
      description = "netbios"
    },
    {
      from_port   = 139
      to_port     = 139
      protocol    = "tcp"
      description = "NetBIOS Session Service"
    },
    {
      from_port   = 445
      to_port     = 445
      protocol    = "tcp"
      description = "SMB"
    },
    {
      from_port   = 500
      to_port     = 500
      protocol    = "udp"
      description = "Ipsec VPN Tunel"
    },
    {
      from_port   = 3268
      to_port     = 3269
      protocol    = "tcp"
      description = "LDAP connection to Global Catalog"
    },
    {
      from_port   = 5722
      to_port     = 5722
      protocol    = "tcp"
      description = "Microsoft DFS Replication Service"
    },
    {
      from_port   = 5985
      to_port     = 5985
      protocol    = "tcp"
      description = "WBEM WS-Management HTTP"
    },
    {
      from_port   = 9389
      to_port     = 9389
      protocol    = "tcp"
      description = "Active Directory Web Services"
    },
    {
      from_port   = 1688
      to_port     = 1688
      protocol    = "tcp"
      description = "KMS Windows Activation"
    },
    {
      from_port   = 49152
      to_port     = 65535
      protocol    = "tcp"
      description = "Randomly allocated high TCP ports"
    }
  ]
}