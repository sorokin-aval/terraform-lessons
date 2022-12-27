include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://gitlab.devops.aval/sre/terraform-modules.git//eks?ref=v1.1.0"

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
  tags_map = local.common_tags.locals.common_tags

  cluster_name = "common-rancher"
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

  kubeconfig_output_path               = "~/.kube/config"
  cluster_name                         = local.cluster_name
  subnets_names                        = ["LZ-AVAL_COMMON_TEST-InternalA", "LZ-AVAL_COMMON_TEST-InternalB"]
  write_kubeconfig                     = true
  enable_irsa                          = true
  kubeconfig_aws_authenticator_command = "aws"
  kubeconfig_aws_authenticator_command_args = [
    "eks",
    "get-token",
    "--cluster-name",
    local.cluster_name
  ]

  cluster_version           = "1.21"
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  wait_for_cluster_timeout = 1200

  node_groups = {
    "workers" = {
      create_launch_template = true
      desired_capacity       = 1
      max_capacity           = 5
      min_capacity           = 1
      instance_types         = ["m5a.large"]
      disk_size              = 30
      k8s_labels = {
        pool = "workers"
      }
      ami_id = "ami-015906c480bba2ae8"
      capacity_type = "ON_DEMAND"
      additional_tags = {
        map-migrated = "d-server-00sztj0wdfksrf"
        "ea:shared-service" = "true"
        "ea:application-id" = "20629"
        "ea:application-name" = "AvaLaunch"
        "internet-faced" = "true"
      }
    }
  }

  eks_cluster_autoscaler_values = {
    "image.repository" = "k8s.gcr.io/autoscaling/cluster-autoscaler"
  }

  docker_registry                  = "k8s.gcr.io"
  helm_chart_version               = "4.0.1"
  nginx_websockets_enabled         = true
  ingress_version                  = "v1.0.0"
  ingress_cert_arn                 = "arn:aws:acm:eu-central-1:136812256255:certificate/063dee73-e2de-4031-a86a-bf83fcb1a989"
  tags                             = local.tags_map
}
