include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://gitlab.devops.aval/sre/terraform-modules.git//eks"

  after_hook "kubeconfig" {
    commands = ["apply"]
    execute  = ["bash", "-c", "mkdir -p ~/.kube && terraform output --raw kubeconfig > ~/.kube/config"]
  }

  after_hook "kube-system-label" {
    commands = ["apply"]
    execute  = ["bash", "-c", "kubectl --kubeconfig ~/.kube/config label ns kube-system name=kube-system --overwrite"]
  }

  after_hook "undefault-gp2" {
    commands = ["apply"]
    execute  = ["bash", "-c", "kubectl --kubeconfig ~/.kube/config patch storageclass gp2 -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"false\"}}}'"]
  }
}

locals {
  # Automatically load common tags from parent hcl
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common tags for reuse
  env      = local.account_vars.locals.environment
  tags_map = local.common_tags.locals

  cluster_name = "${local.env}-load-gen"
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

  cluster_name                         = local.cluster_name
  subnets_names                        = ["LZ-AVAL_AQA_TEST-InternalA", "LZ-AVAL_AQA_TEST-InternalB"]
  write_kubeconfig                     = true
  enable_irsa                          = true
  kubeconfig_aws_authenticator_command = "aws"
  kubeconfig_aws_authenticator_command_args = [
    "eks",
    "get-token",
    "--cluster-name",
    local.cluster_name
  ]

  cluster_version           = "1.20"
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  wait_for_cluster_timeout = 1800

  node_groups = {
    "load_worker" = {
      create_launch_template = true
      desired_capacity       = 1
      max_capacity           = 20
      min_capacity           = 1
      instance_types         = ["m5a.xlarge"]
      disk_size              = 15
      key_name = "EKS"
      k8s_labels = {
        pool = "load_worker"
      }
      additional_tags = {
        "k8s.io/cluster-autoscaler/enabled" = ""
      }
      ami_id = "ami-04bff9f9c203a11a3"
      capacity_type = "ON_DEMAND"
    },
    "infra_worker" = {
      create_launch_template = true
      desired_capacity       = 1
      max_capacity           = 3
      min_capacity           = 1
      instance_types         = ["m5a.xlarge"]
      disk_size              = 15
      key_name = "EKS"
      k8s_labels = {
        pool = "infra_worker"
      }
      additional_tags = {
        "k8s.io/cluster-autoscaler/enabled" = ""
      }
      ami_id = "ami-04bff9f9c203a11a3"
      capacity_type = "ON_DEMAND"
    }
  }
  tags = local.tags_map
}
