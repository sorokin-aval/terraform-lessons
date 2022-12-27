include "root" {
  path = find_in_parent_folders()
}
include "account" {
  path = find_in_parent_folders("account.hcl")
}
# Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
# for the component across all environments.
include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/global.hcl"
  expose = true
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//eks?ref=feature/eks-tf-1.1"

  before_hook "before_hook" {
    commands = ["apply"]
    execute  = ["bash", "-c", "mkdir -p ~/.kube"]
  }
}

locals {
  # Automatically load common tags from parent hcl
  common_tags    = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account        = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  project_vars   = read_terragrunt_config(find_in_parent_folders("project_vars.hcl"))
  tags_map       = local.project_vars.locals.project_tags
  project        = local.tags_map.Project
  # Extract out common tags for reuse
  env            = local.account.locals.environment
  aws_account_id = local.account.locals.aws_account_id
  cluster_name   = "${local.project}-${local.env}-02"
}
generate "kube-provider" {
  path      = "kube-provider.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    provider "kubernetes" {
      host                   = data.aws_eks_cluster.cluster.endpoint
      cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
      token                  = data.aws_eks_cluster_auth.cluster.token
    }
    data "aws_eks_cluster" "cluster" {
      name = module.eks.cluster_id
    }
    data "aws_eks_cluster_auth" "cluster" {
      name = module.eks.cluster_id
    }
  EOF
}

inputs = {
  create           = true
  cluster_name     = local.cluster_name
  aws_account_id   = local.aws_account_id
  subnets_names    = ["CGNATSubnet1", "CGNATSubnet2", "CGNATSubnet3"]
  lb_subnets_names = [
    "LZ-RBUA_DRAIF_Prod_01-InternalA", "LZ-RBUA_DRAIF_Prod_01-InternalB", "LZ-RBUA_DRAIF_Prod_01-InternalC"
  ]
  write_kubeconfig                          = true
  kubeconfig_output_path                    = "~/.kube"
  kubeconfig_name                           = local.cluster_name
  enable_irsa                               = true
  enable_ingress_nginx                      = true
  enable_cluster_autoscaler                 = true
  kubeconfig_aws_authenticator_command      = "aws"
  kubeconfig_aws_authenticator_command_args = [
    "eks",
    "get-token",
    "--cluster-name",
    local.cluster_name
  ]
  cluster_encryption_config = [
    {
      provider_key_arn = "arn:aws:kms:eu-central-1:100515202040:key/b8974795-2020-4a77-8935-11cdfac72a68",
      resources        = ["secrets"]
    }
  ]
  cluster_version           = "1.22"
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  wait_for_cluster_timeout  = 900

  # Additional map roles for aws-auth in EKS
  map_roles = [
    {
      rolearn  = "arn:aws:iam::418574960021:role/TerraformHost"
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:nodes", "system:bootstrappers", "system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::100515202040:role/rbua-data-prod-terraform"
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:nodes", "system:bootstrappers", "system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
      username = "Admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::100515202040:role/Admin"
      username = "Admin"
      groups   = ["system:masters"]
    },
  ]

  node_groups_defaults = {
    metadata_http_tokens = "required"
    disk_size            = 100
    disk_type            = "gp3"
    disk_throughput      = 200
    disk_iops            = 3000
  }

  node_groups = {
    "infra" = {
      create_launch_template = true
      desired_capacity       = 2
      desired_size           = 2
      max_capacity           = 5
      min_capacity           = 1
      instance_types         = ["t3.medium", "t3a.medium", "t2.medium"]
      k8s_labels             = {
        pool         = "infrastructure"
        node-purpose = "infra"
      }
      additional_tags = {
        "k8s.io/cluster-autoscaler/enabled"               = "true",
        "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
      }
      capacity_type = "ON_DEMAND"
      ami_id        = "ami-060f308d1d1d8e688"
    },
    "apps-spot-4C-16R" = {
      create_launch_template = true
      desired_capacity       = 1
      max_capacity           = 5
      min_capacity           = 1
      instance_types         = [
        "m4.xlarge", "m5a.xlarge", "m5ad.xlarge", "m5d.xlarge", "m5dn.xlarge", "m5.xlarge", "m5n.xlarge"
      ]
      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"
      k8s_labels           = {
        pool         = "apps-spot"
        node-purpose = "infra"
      }
      additional_tags = {
        "k8s.io/cluster-autoscaler/enabled"               = "true",
        "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
      }
      capacity_type = "SPOT"
      ami_id        = "ami-060f308d1d1d8e688"
    }

  }
  tags = local.tags_map
}
