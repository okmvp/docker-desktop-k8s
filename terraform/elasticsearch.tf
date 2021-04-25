locals {
  elasticsearch_namespace = "elasticsearch"
}

resource kubernetes_namespace elastic {
  metadata {
    name = local.elasticsearch_namespace
  }
}


################################################################
##
##  Local Directories for Kafka
##

locals {
  elasticsearch_data_path = pathexpand("${var.kubepv_root}/elasticsearch/data")
}

resource null_resource elastic_local_directories {
  triggers = {
    args = join(" ", [
      local.elasticsearch_data_path,
    ])
  }

  provisioner local-exec {
    command = <<-EOF
      mkdir -p ${self.triggers.args}
    EOF
  }

  provisioner local-exec {
    when    = destroy
    command = <<-EOF
      rm -rf ${self.triggers.args}
    EOF
  }
}


################################################################
##
##  Kubernetes Persistent Volumes
##

##--------------------------------------------------------------
##  elastic

resource kubernetes_persistent_volume_claim elastic {
  metadata {
    # name: volumeclaimtemplates-name-statefulset-name-replica-index
    name = "elasticsearch-elasticsearch-0"
    namespace = kubernetes_namespace.elastic.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.elasticsearch_data_size
      }
    }
    volume_name = kubernetes_persistent_volume.elastic.metadata[0].name
    storage_class_name = "local-storage"
  }
  wait_until_bound = true
}

resource kubernetes_persistent_volume elastic {
  depends_on = [
    null_resource.elastic_local_directories
  ]

  metadata {
    name = "elasticsearch-0"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    capacity = {
      storage = var.elasticsearch_data_size
    }
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key = "kubernetes.io/hostname"
            operator = "In"
            values = ["docker-desktop"]
          }
        }
      }
    }
    persistent_volume_reclaim_policy = "Recycle"
    persistent_volume_source {
      local {
        path = local.elasticsearch_data_path
      }
    }
    storage_class_name = "local-storage"
    volume_mode = "Filesystem"
  }
}

