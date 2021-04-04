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

  set_sensitive {
    name  = "cd.configs.secret.argocdServerAdminPassword"
    value = data.external.argo.result.encpw
  }

  set {
    name  = "cd.configs.secret.argocdServerAdminPasswordMtime"
    value = data.external.argo.result.mtime
  }
}

resource null_resource apps {
  depends_on = [
    helm_release.argo
  ]

  triggers = {
    manifest = data.template_file.apps.rendered
  }

  provisioner local-exec {
    command = self.triggers.manifest
  }
}

data template_file apps {
  template = <<-EOT
    kubectl \
        --kubeconfig ${var.kubeconfig_path} \
        --context ${var.kubeconfig_context} \
      apply \
        --validate=true \
        --wait=true \
        -f - <<EOF
    ---
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: apps
      namespace: ${kubernetes_namespace.argo.metadata[0].name}
    spec:
      project: default
      source:
        repoURL: ${var.apps_repository}
        targetRevision: ${var.apps_revision}
        path: apps/
        helm:
          parameters:
          - name:  domain
            value: ${var.domain}
          - name:  repository
            value: ${var.apps_repository}
          - name:  revision
            value: ${var.apps_revision}
          - name:  metallb.addresses
            value: https://${var.metallb_addresses}
          - name:  kafka.enabled
            value: "${var.kafka_enabled}"
          valueFiles:
          - values.yaml
          version: v2
      destination:
        server: https://kubernetes.default.svc
        namespace: argo
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
        - Validate=true
    EOF
  EOT
}
