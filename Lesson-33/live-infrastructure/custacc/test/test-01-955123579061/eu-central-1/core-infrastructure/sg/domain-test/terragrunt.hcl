#custacc 2022-11-16
include {
  path = find_in_parent_folders()
}

# Hardcode!
dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info")
}

iam_role = local.account_vars.iam_role

terraform {
  source = local.account_vars.locals.sources["sg"]
#  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v4.9.0"
}

locals {

#  name = basename(get_terragrunt_dir())
  name = "Domain-test"
  description = "security group for access to TEST-AVAL domain"

    account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
    app_vars    = read_terragrunt_config(find_in_parent_folders("application.hcl"))

}

#object-group network Domain-CTRL-HO-tst
#network-object host 10.191.199.201
#network-object host 10.191.199.200
#network-object host 10.191.199.202
#icmp echo
#tcp-udp eq 53 (DNS)
#tcp-udp eq 88 (Kerberos)
#tcp-udp eq 464 (Kerberos Password Change)
#tcp-udp eq 123 (NTP)
#tcp-udp eq 636 (LDAPS)
#tcp eq 135 (rpc)
#udp range 137 138 (netbios)
#tcp eq 139 (SMB)
#tcp eq 445 (SMB)
#udp eq 500 (Ipsec VPN Tunel)
#tcp range 3268 3269 (LDAP connection to Global Catalog)
#tcp eq 5722 (Microsoft DFS Replication Service)
#tcp eq 5985 (WBEM WS-Management HTTP)
#tcp eq 9389 (Active Directory Web Services)
#tcp eq 1688 (Microsoft Key Management Service for KMS Windows Activation (Official))
#tcp-udp range 49152 65535 (SCCM)


inputs = {
  name = local.name
  description = local.description

  use_name_prefix = false
  vpc_id   = dependency.vpc.outputs.vpc_id.id
  tags   = local.app_vars.locals.tags


  egress_ipv6_cidr_blocks = []
  egress_cidr_blocks      = ["10.191.199.200/32", "10.191.199.201/32", "10.191.199.202/32"]
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
