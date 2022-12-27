include {
  path = find_in_parent_folders()
}
iam_role = local.account_vars.iam_role

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-tf-aws-eks.git?ref=v1.0.2"
}

locals {
  # Automatically load common tags from parent hcl
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common tags for reuse
  env            = local.account_vars.locals.environment
  tags_map       = local.common_tags.locals.common_tags
  aws_account_id = local.account_vars.locals.aws_account_id
  cluster_name   = "${local.env}-avalaunch"
  node_config    = file("./userdata.toml")
}

inputs = {
  cluster_name              = local.cluster_name
  eks_subnets_names_filter  = "LZ-AVAL_AvalaunchSandbox_DEV_03-Internal*"
  enable_irsa               = true
  manage_aws_auth_configmap = true

## Workaround to not recreate resources when updating EKS module up to 18.x.x
  prefix_separator                   = ""
  iam_role_name                      = local.cluster_name
  cluster_security_group_name        = local.cluster_name
  cluster_security_group_description = "EKS cluster security group."

  cluster_addons = {
    aws-ebs-csi-driver = {
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
      addon_version            = "v1.11.4-eksbuild.1"
    }
    coredns = {
      resolve_conflicts        = "OVERWRITE"
      addon_version            = "v1.8.7-eksbuild.1"
    }
  }

  cluster_version           = "1.22"
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  wait_for_cluster_timeout  = 900

  enable_karpenter = true

  enable_cluster_autoscaler    = false
  cluster_autoscaler_namespace = "infra-tools"

  enable_aws_loadbalancer_controller    = true
  aws_loadbalancer_controller_namespace = "infra-tools"

  enable_argo_cd                  = true
  argo_cd_namespace               = "kube-system"
  argo_cd_gitops_repo             = "https://code.rbi.tech/raiffeisen/ua-avalaunch-infrastructure-manifests.git"
  argo_cd_hostname                = "argo-infra.sandbox.avalaunch.aval"
  argo_cd_application_path        = "aws-sandbox"
  argo_cd_repo_credentials_secret = "argo-infra-github"
  argo_cd_oidc_secret             = "argo-infra-oidc"
  argo_cd_oidc_issuer             = "https://dex.sandbox.avalaunch.aval"

  tags = local.tags_map

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::${local.aws_account_id}:role/Admin"
      username = "Admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
      username = "Admin"
      groups   = ["system:masters"]
    },
  ]

  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_allow_access_alb_controller = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      source_cluster_security_group = true
      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
    }
    ingress_allow_access_nginx_ingress = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 8443
      to_port                       = 8443
      source_cluster_security_group = true
      description                   = "Allow access from control plane to webhook port of Nginx ingress controller"
    }
  }

  eks_managed_node_group_defaults = {
    ami_type = "BOTTLEROCKET_x86_64"
    platform = "bottlerocket"
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 2
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          delete_on_termination = true
        }
      }
      xvdb = {
        device_name = "/dev/xvdb"
        ebs = {
          volume_size           = 50
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 125
          delete_on_termination = true
        }
      }
    }
    enable_bootstrap_user_data = true
    bootstrap_extra_args = local.node_config
    iam_role_additional_policies = [
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]
    update_config = {
      max_unavailable_percentage = 50
    }
}

  eks_managed_node_groups = {
    infra = {
      desired_size   = 2
      max_size       = 2
      min_size       = 2
      instance_types = ["t3.medium", "t3.large", "t3a.medium", "t3a.large"]
      capacity_type  = "SPOT"
      labels = {
        pool         = "infrastructure"
        node-purpose = "infra"
      }
      tags = {
        map-migrated          = "d-server-02l2kprf5cnmt1"
        "ea:shared-service"   = "true"
        "ea:application-id"   = "20629"
        "ea:application-name" = "AvaLaunch"
        "internet-faced"      = "true"
      }
    }
  }
}
