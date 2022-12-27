include { 
  path = find_in_parent_folders() 
}

iam_role = local.account_vars.iam_role

dependency "vpc" {
  config_path = find_in_parent_folders("core-infrastructure/vpc-info") 
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git//.?ref=v4.13.1"
}

locals {
  account_vars  = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  common_tags   = local.account_vars.locals.tags
  tags_map      = merge(local.common_tags)

  name = basename(get_terragrunt_dir())

  aws_cidr_blocks_arr = [
    "10.216.0.0/16",
    "10.223.0.0/16",
    "10.224.0.0/14",
    ]
  ad_cidr_blocks_arr = [
    "10.191.2.200/32", 
    "10.191.2.201/32",
    "10.191.2.202/32",
    "10.191.2.203/32",
    "10.191.2.205/32",
    "10.191.2.215/32",
    "10.191.2.225/32",
    "10.191.2.235/32",
    "10.227.50.190/32",
    "10.227.50.197/32",
    ]
  ad_cidr_blocks = join(",", local.ad_cidr_blocks_arr)

  ad_sg_rules =  [
    { protocol= "icmp", "from_port"=   -1, "to_port"=   -1, description="" },
    { protocol=  "tcp", "from_port"=   53, "to_port"=   53, description="DNS" },
    { protocol=  "udp", "from_port"=   53, "to_port"=   53, description="DNS" },
    { protocol=  "tcp", "from_port"=   88, "to_port"=   88, description="Kerberos" },
    { protocol=  "udp", "from_port"=   88, "to_port"=   88, description="Kerberos" },
    { protocol=  "tcp", "from_port"=  123, "to_port"=  123, description="NTP" },
    { protocol=  "udp", "from_port"=  123, "to_port"=  123, description="NTP" },
    { protocol=  "tcp", "from_port"=  135, "to_port"=  135, description="RPC" },
    { protocol=  "udp", "from_port"=  137, "to_port"=  138, description="NetBIOS" },
    { protocol=  "tcp", "from_port"=  139, "to_port"=  139, description="NetBIOS Session Service" },
    { protocol=  "tcp", "from_port"=  389, "to_port"=  389, description="LDAP" },
    { protocol=  "udp", "from_port"=  389, "to_port"=  389, description="LDAP" },
    { protocol=  "tcp", "from_port"=  445, "to_port"=  445, description="SMB" },
    { protocol=  "udp", "from_port"=  445, "to_port"=  445, description="SMB" },
    { protocol=  "tcp", "from_port"=  464, "to_port"=  464, description="Kerberos Password Change" },
    { protocol=  "udp", "from_port"=  464, "to_port"=  464, description="Kerberos Password Change" },
    { protocol=  "udp", "from_port"=  500, "to_port"=  500, description="Ipsec VPN Tunel" },
    { protocol=  "tcp", "from_port"=  636, "to_port"=  636, description="LDAP connection to Global Catalog" },
    { protocol=  "udp", "from_port"=  636, "to_port"=  636, description="LDAP connection to Global Catalog" },
    { protocol=  "tcp", "from_port"= 3268, "to_port"= 3269, description="Global Catalog" },
    { protocol=  "tcp", "from_port"= 5722, "to_port"= 5722, description="Microsoft DFS Replication Service" },
    { protocol=  "tcp", "from_port"= 5985, "to_port"= 5986, description="WBEM WS-Management HTTP" },
    { protocol=  "tcp", "from_port"= 9389, "to_port"= 9389, description="Active Directory Web Services" },
    { protocol=  "tcp", "from_port"=49152, "to_port"=65535, description="Randomly allocated high TCP ports" },
    { protocol=  "udp", "from_port"=49152, "to_port"=65535, description="Randomly allocated high TCP ports" },
  ]
}

inputs = {
  name = local.name
  description = "security group for ${local.name}"
  use_name_prefix = false
  vpc_id = dependency.vpc.outputs.vpc_id.id
  tags = local.tags_map

  # egress_cidr_blocks       = local.ad_cidr_blocks_arr
  # ingress_cidr_blocks       = concat(local.ad_cidr_blocks_arr, local.aws_cidr_blocks_arr)

  egress_cidr_blocks       = ["10.0.0.0/8"]
  ingress_cidr_blocks      = ["10.0.0.0/8"]
  # egress_rules           = ["ldap-tcp", "ldaps-tcp", "dns-udp", "ntp-udp", "all-icmp"]

  ingress_with_cidr_blocks = local.ad_sg_rules
  egress_with_cidr_blocks  = local.ad_sg_rules
}