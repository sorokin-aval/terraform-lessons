include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "git::https://gitlab.devops.aval/sre/terraform-modules.git//helm_release"
}

inputs = {
  name       = "argo"
  namespace  = "kube-system"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  values     = file("argocd-values.yaml")
  config_path = "/home/ssm-user/kubeconfig_dev-avalaunch-data"
}
