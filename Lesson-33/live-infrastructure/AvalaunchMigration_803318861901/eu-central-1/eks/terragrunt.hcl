include {
  path = find_in_parent_folders()
}
iam_role = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//eks?ref=eks_v1.5.0"

  before_hook "before_hook" {
    commands = ["apply"]
    execute  = ["bash", "-c", "mkdir -p ~/.kube"]
  }
}

locals {
  # Automatically load common tags from parent hcl
  common_tags    = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars   = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common tags for reuse
  env      = local.account_vars.locals.environment
  tags_map = merge(local.common_tags.locals.common_tags, { map-migrated = "d-server-03mza8iokjfofq" })

  aws_account_id = local.account_vars.locals.aws_account_id

  cluster_name = "avalaunch-${local.env}"

  ami_id = "ami-0d79b2b95a112898b"
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

  cluster_name                              = local.cluster_name
  aws_account_id                            = local.aws_account_id
  subnets_names                             = ["CGNATSubnet1", "CGNATSubnet2", "CGNATSubnet3"]
  write_kubeconfig                          = true
  kubeconfig_output_path                    = "./config"
  enable_irsa                               = true
  kubeconfig_aws_authenticator_command      = "aws"
  kubeconfig_aws_authenticator_command_args = [
    "eks",
    "get-token",
    "--cluster-name",
    local.cluster_name
  ]

  map_roles = [
    {
      rolearn  = "arn:aws:iam::${local.aws_account_id}:role/Admin"
      username = "Admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${local.aws_account_id}:role/Jenkins-DeploymentRole-Slave"
      username = "Admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${local.aws_account_id}:role/terraform-role"
      username = "Admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${local.aws_account_id}:role/AmazonEKSDomainProvisionGithubRunnerRole"
      username = "Admin"
      groups   = ["system:masters"]
    }
  ]

  cluster_version           = "1.21"
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  wait_for_cluster_timeout = 900

  node_groups = {
    "infra" = {
      create_launch_template = true
      max_capacity           = 50
      min_capacity           = 1
      instance_types         = ["m5.2xlarge"]
      disk_size              = 20
      k8s_labels = {
        pool         = "infrastructure"
        node-purpose = "infra"
      }
      ami_id        = local.ami_id
      capacity_type = "ON_DEMAND"
      additional_tags = {
        map-migrated = "d-server-03jgfdddbgetgn"
        "ea:shared-service" = "true"
        "ea:application-id" = "20629"
        "ea:application-name" = "AvaLaunch"
        "internet-faced" = "true"
      }
    }
    "compute" = {
      create_launch_template = true
      max_capacity           = 50
      min_capacity           = 1
      instance_types         = ["m5.2xlarge"]
      disk_size              = 100
      k8s_labels = {
        pool         = "compute"
        node-purpose = "compute"
      }
      ami_id        = local.ami_id
      capacity_type = "ON_DEMAND"
      additional_tags = {
        map-migrated = "d-server-03pmn5w1gsnja0"
        "ea:shared-service" = "true"
        "ea:application-id" = "20629"
        "ea:application-name" = "AvaLaunch"
        "internet-faced" = "true"
      }
    }
    "data" = {
      create_launch_template = true
      max_capacity           = 15
      min_capacity           = 1
      instance_types         = ["c5a.2xlarge"]
      disk_size              = 50
      k8s_labels = {
        pool         = "data"
        node-purpose = "data"
      }
      ami_id        = local.ami_id
      capacity_type = "ON_DEMAND"
      additional_tags = {
        map-migrated = "d-server-03io6471taxili"
        "ea:shared-service" = "true"
        "ea:application-id" = "20629"
        "ea:application-name" = "AvaLaunch"
        "internet-faced" = "true"
      }
    }
  }

  tags = local.tags_map

  enable_argo_cd                        = true
  argo_cd_gitops_repo                   = "https://code.rbi.tech/raiffeisen/ua-avalaunch-infrastructure-manifests.git"
  argo_cd_hostname                      = "argo-infra.prod.avalaunch.aval"
  argo_cd_application_path              = "aws-avalaunch-prod"
  argo_cd_repo_credentials_secret       = "argo-infra-github"
  argo_cd_oidc_secret                   = "argo-infra-oidc"
}
