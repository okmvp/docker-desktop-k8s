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
    helm_release.argo,
    kubernetes_persistent_volume_claim.elastic,
    kubernetes_persistent_volume_claim.zookeeper,
    kubernetes_persistent_volume_claim.zookeeper_log,
    kubernetes_persistent_volume_claim.kafka,
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
      labels:
        argo.okmvp.internal/category: operator
    spec:
      project: default
      source:
        repoURL: ${var.apps_repository}
        targetRevision: ${var.apps_revision}
        path: apps/
        helm:
          parameters:
          # Global
          - name:  domain
            value: ${var.domain}
          - name:  repository
            value: ${var.apps_repository}
          - name:  revision
            value: ${var.apps_revision}
          # Network / Ingress
          - name:  network.ingress.type
            value: ${var.ingress_type}
          # Network / Metal-LB
          - name:  network.metallb.addresses
            value: ${var.metallb_addresses}
          # Data / Elasticsearch
          - name:  data.elascticsearch.persistence.enabled
            value: "true"
          - name:  data.elasticsearch.persistence.dataDirSize
            value: ${var.elasticsearch_data_size}
          # Data / Kafka
          - name:  data.kafka.enabled
            value: "${var.kafka_enabled}"
          - name:  data.kafka.persistence.enabled
            value: "true"
          - name:  data.kafka.persistence.zookeeper.dataDirSize
            value: ${var.zookeeper_data_size}
          - name:  data.kafka.persistence.zookeeper.dataLogDirSize
            value: ${var.zookeeper_log_size}
          - name:  data.kafka.persistence.kafka.dataDirSize
            value: ${var.kafka_data_size}
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
