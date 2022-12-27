include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://gitlab.devops.aval/sre/terraform-modules.git//eks?ref=eks_v1.3.0"

  before_hook "before_hook" {
    commands     = ["apply"]
    execute      = ["bash", "-c", "mkdir -p ~/.kube"]
  }
}

locals {
  # Automatically load common tags from parent hcl
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common tags for reuse
  env      = local.account_vars.locals.environment
  tags_map = local.common_tags.locals

  aws_account_id = local.account_vars.locals.aws_account_id

  cluster_name = "raifsite-${local.env}"
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
  aws_account_id                       = local.aws_account_id
  subnets_names                        = ["CGNATSubnet1", "CGNATSubnet2"]
  lb_subnets_names                     = ["LZ-AVAL_Raifsite_Dev_02-InternalA", "LZ-AVAL_Raifsite_Dev_02-InternalB"]
  write_kubeconfig                     = true
  kubeconfig_output_path               = "/home/ssm-user/.kube/config"
  enable_irsa                          = true
  kubeconfig_aws_authenticator_command = "aws"
  enable_ingress_nginx                 = true
  enable_cluster_autoscaler            = true
  kubeconfig_aws_authenticator_command_args = [
    "eks",
    "get-token",
    "--cluster-name",
    local.cluster_name
  ]

  cluster_version           = "1.21"
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  wait_for_cluster_timeout = 900

  node_groups = {
    "infra" = {
      create_launch_template = true
      desired_capacity       = 1
      max_capacity           = 5
      min_capacity           = 1
      instance_types         = ["m5.large"]
      disk_size              = 20
      k8s_labels = {
        pool = "infrastructure"
        node-purpose = "infra"
      }
      ami_id = "ami-0f9e536b26a8928fe"
      capacity_type = "ON_DEMAND"
    }
    "compute" = {
      create_launch_template = true
      desired_capacity       = 1
      max_capacity           = 5
      min_capacity           = 1
      instance_types         = ["m5.large"]
      disk_size              = 20
      k8s_labels = {
        pool = "compute"
        node-purpose = "compute"
      }
      ami_id = "ami-0f9e536b26a8928fe"
      capacity_type = "ON_DEMAND"
    }
    "data" = {
      create_launch_template = true
      desired_capacity       = 1
      max_capacity           = 5
      min_capacity           = 1
      instance_types         = ["m5.large"]
      disk_size              = 50
      k8s_labels = {
        pool = "data"
        node-purpose = "data"
      }
      ami_id = "ami-0f9e536b26a8928fe"
      capacity_type = "ON_DEMAND"
    }
  }

  eks_cluster_autoscaler_values = {
    "image.repository"  = "harbor.avalaunch.aval/autoscaling/cluster-autoscaler"
    "image.tag"         = "v1.21.0"
    "image.pullSecrets[0]" = "regcred"
  }
  use_same_docker_registry_for_lbc = false
  lbc_docker_registry              = "harbor.avalaunch.aval"

  ingress_docker_registry = "k8s.gcr.io"
  helm_chart_version      = "4.0.1"
  ingress_version         = "v1.0.0"
  ingress_replica_count   = 2
  ingress_cert_arn        = "arn:aws:acm:eu-central-1:115292379528:certificate/257b70cd-7979-4388-89d9-f8333bd18c82"
  
  tags = local.tags_map

  enable_external_dns = true
  create_zone_external_dns = true
  zone_name_external_dns = "raifsite.avalaunch.aval"

  enable_argo_cd = true
  argo_cd_gitops_repo = "https://gitlab.avalaunch.aval/argocd/infrastructure-manifests.git"
  argo_cd_hostname = "argo-infra.raifsite.avalaunch.aval"
  argo_cd_application_path = "aws-dev-raifsite"
  argo_cd_vault_repo_credentials_secret = "secret/argo/aws-raifsite-dev"
  argo_cd_vault_oidc_secret = "secret/argo/aws-raifsite-dev-oidc"
}
