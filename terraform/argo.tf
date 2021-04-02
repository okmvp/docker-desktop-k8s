locals {
  argo_host = "argo.${var.domain}"
}

resource kubernetes_namespace argo {
  metadata {
    name = "argo"
  }
}

data external argo {
  program = [
    "${path.module}/scripts/argo.sh",
    var.argo_admin_password,
    var.argo_admin_modified,
  ]
}

resource helm_release argo {
  lifecycle {
    ignore_changes = [
        set,
        set_sensitive,
    ]
  }

  name       = "argo"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm/"
  version    = "2.17.5"
  namespace  = kubernetes_namespace.argo.metadata[0].name

  values = [
    file("${path.module}/helm-chart/argo/values.yaml"),
  ]

  set {
    name  = "fullnameOverride"
    value = "argo-argocd"
  }

  set {
    name  = "server.config.url"
    value = "http://${local.argo_host}"
  }

  set {
    name  = "server.ingress.hosts[0]"
    value = local.argo_host
  }

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = data.external.argo.result.encpw
  }

  set {
    name  = "configs.secret.argocdServerAdminPasswordMtime"
    value = data.external.argo.result.mtime
  }
}

resource kubernetes_manifest argo {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata"   = {
      "name"      = "argo"
      "namespace" = kubernetes_namespace.argo.metadata[0].name
    }
    "spec" = {
      "project"     = "default"
      "source"      = {
        "repoURL"        = "https://github.com/okmvp/docker-desktop-k8s.git"
        "targetRevision" = "main"
        "path"           = "helm/operator/argo/"
        "helm"           = {
          "parameters" = []
          "valueFiles" = [
            "values.yaml",
          ]
          "version"    = "v2"
        } 
      }
      "destination" = {
        "server"    = "https://kubernetes.default.svc"
        "namespace" = kubernetes_namespace.argo.metadata[0].name
      }
      "syncPolicy"  = {
        "syncOptions" = [
          "Validate=true",
        ]
      }
    }
  }
}
