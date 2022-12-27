dependency "vpc" {
  config_path = find_in_parent_folders("vpc-info")
}

terraform {
  source = local.account_vars.sources_sg
}

locals {
  name         = "SG-RBUA-${local.account_vars.environment_letter}-LIAInstanceLoadTest"
  tags_map     = read_terragrunt_config(find_in_parent_folders("tags.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

iam_role = local.account_vars.iam_role

inputs = {
  name        = local.name
  description = "Security group for the Load-Test instance"
  vpc_id      = dependency.vpc.outputs.vpc_id.id
  tags        = local.tags_map

  ingress_with_cidr_blocks = [
    {
      name        = "Zabbix"
      from_port   = 10050
      to_port     = 10050
      protocol    = "tcp"
      description = "Access to application from Zabbix servers"
      cidr_blocks = local.account_vars.common_infra_subnets
    },
    {
      name        = "Zabbix"
      from_port   = 10051
      to_port     = 10051
      protocol    = "tcp"
      description = "Access to application from Zabbix servers"
      cidr_blocks = local.account_vars.common_infra_subnets
    },
    {
      name        = "RDP"
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      description = "Access from support private pool"
      cidr_blocks = local.account_vars.support_access_subnets
    },
    {
      name        = "Zabbix Ping"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      description = "Allow ICMP"
      cidr_blocks = local.account_vars.common_infra_subnets
    }
  ]
  egress_with_cidr_blocks = [
    {
      name        = "Oracle DB NLB"
      from_port   = 1521
      to_port     = 1521
      protocol    = "tcp"
      description = "Access to Oracle DB NLB"
      cidr_blocks = local.account_vars.tier2_subnets
    },
    {
      name        = "Oracle DB NLB SSL"
      from_port   = 1575
      to_port     = 1575
      protocol    = "tcp"
      description = "Access to Oracle DB NLB SSL"
      cidr_blocks = local.account_vars.tier2_subnets
    },
    {
      name        = "Zabbix"
      from_port   = 10051
      to_port     = 10051
      protocol    = "tcp"
      description = "Access to Zabbix server"
      cidr_blocks = local.account_vars.common_infra_subnets
    },
    {
      name        = "AppDynamics, Google reCaptcha, etc."
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS for AppDynamics, Google reCaptcha, etc."
      cidr_blocks = "0.0.0.0/0"
    },
    {
      name        = "TSP over HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow TSP over HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      name        = "AD"
      from_port   = 389
      to_port     = 389
      protocol    = "udp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 389
      to_port     = 389
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 49152
      to_port     = 65535
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 53
      to_port     = 53
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 500
      to_port     = 500
      protocol    = "udp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 464
      to_port     = 464
      protocol    = "udp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 464
      to_port     = 464
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 9389
      to_port     = 9389
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 88
      to_port     = 88
      protocol    = "udp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 88
      to_port     = 88
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 137
      to_port     = 138
      protocol    = "udp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 53
      to_port     = 53
      protocol    = "udp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 5722
      to_port     = 5722
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 139
      to_port     = 139
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 1688
      to_port     = 1688
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 3268
      to_port     = 3269
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 49152
      to_port     = 65535
      protocol    = "udp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 636
      to_port     = 636
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 636
      to_port     = 636
      protocol    = "udp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 135
      to_port     = 135
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 445
      to_port     = 445
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 5985
      to_port     = 5986
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 123
      to_port     = 123
      protocol    = "tcp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD"
      from_port   = 123
      to_port     = 123
      protocol    = "udp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "AD ICMP"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      description = "Access to domain controller"
      cidr_blocks = local.account_vars.ad_onprem_subnets
    },
    {
      name        = "RPC"
      from_port   = 49152
      to_port     = 65535
      protocol    = "tcp"
      description = "RPC ports for RDP to support private pool"
      cidr_blocks = local.account_vars.support_access_subnets
    },
    {
      name        = "RPC"
      from_port   = 49152
      to_port     = 65535
      protocol    = "tcp"
      description = "RPC ports for private subnets"
      cidr_blocks = local.account_vars.account_subnets
    },
    {
      name        = "Internal CSK"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow access to Internal CSK"
      cidr_blocks = local.account_vars.security_subnets
    },
    {
      name        = "Internal CSK Back"
      from_port   = 8082
      to_port     = 8082
      protocol    = "tcp"
      description = "Allow access to Internal CSK Back"
      cidr_blocks = local.account_vars.security_subnets
    },
    {
      name        = "RBAProxy"
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      description = "Access to RBUA Proxy"
      cidr_blocks = local.account_vars.rba_proxy_subnets
    }
  ]
}
