include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://gitlab.devops.aval/sre/terraform-modules.git//eks?ref=eks_v1.2.4"

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

  cluster_name = "${local.env}-avalaunch-data"
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
  lb_subnets_names                     = ["LZ-AVAL_AvalaunchDevDATA_Dev_02-InternalA", "LZ-AVAL_AvalaunchDevDATA_Dev_02-InternalB"]
  write_kubeconfig                     = true
  kubeconfig_output_path               = "/home/ssm-user/"
  kubeconfig_name                      = local.cluster_name
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
      instance_types         = ["t3.medium"]
      disk_size              = 20
      k8s_labels = {
        pool = "infrastructure"
        node-purpose = "infra"
      }
      taints = [
        {
          key    = "pool"
          value  = "infrastructure"
          effect = "NO_SCHEDULE"
        }
      ]
      ami_id = "ami-0865a8c8bd94c0313"
      capacity_type = "ON_DEMAND"
    }
    "data" = {
      create_launch_template = true
      desired_capacity       = 1
      max_capacity           = 10
      min_capacity           = 1
      instance_types         = ["r5a.xlarge"]
      disk_size              = 20
      k8s_labels = {
        pool = "data"
        node-purpose = "data"
      }
      ami_id = "ami-0865a8c8bd94c0313"
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

# k8s.gcr.io/ingress-nginx/controller:v1.0.0"
  ingress_docker_registry = "harbor.avalaunch.aval"
  helm_chart_version      = "4.0.1"
  ingress_version         = "v1.0.0"
  ingress_deployment_kind = "Deployment"
  ingress_replica_count   = 2
  ingress_cert_arn        = "arn:aws:acm:eu-central-1:220153379415:certificate/a5ef2fe5-8556-4fd2-9959-301364e275b4"
  
  tags = local.tags_map

  enable_external_dns = true
  zone_name_external_dns = "data.dev-avalaunch.aval"
}
