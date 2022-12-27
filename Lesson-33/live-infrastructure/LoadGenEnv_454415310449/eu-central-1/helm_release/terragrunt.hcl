include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "git::https://gitlab.devops.aval/sre/terraform-modules.git//helm_release"
}

inputs = {
  name       = "argo-infra"
  namespace  = "kube-system"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  values     = file("argocd-values.yaml")
}
