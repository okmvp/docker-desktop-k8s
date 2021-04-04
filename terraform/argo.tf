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

  name      = "argo"
  chart     = "../helm/operator/argo/"
  dependency_update = true
  namespace = kubernetes_namespace.argo.metadata[0].name

  set {
    name  = "cd.server.ingress.hosts[0]"
    value = local.argo_host
  }

  set {
    name  = "cd.server.config.url"
    value = "http://${local.argo_host}"
  }

  set {
    name  = "apps.domain"
    value = var.domain
  }

  set {
    name  = "apps.metallb.addresses"
    value = var.metallb_addresses
  }

  set_sensitive {
    name  = "cd.configs.secret.argocdServerAdminPassword"
    value = data.external.argo.result.encpw
  }

  set {
    name  = "cd.configs.secret.argocdServerAdminPasswordMtime"
    value = data.external.argo.result.mtime
  }
}
