locals {
  kafka_namespace = "kafka"
}

resource kubernetes_namespace kafka {
  count = var.kafka_enabled ? 1 : 0

  metadata {
    name = local.kafka_namespace
  }
}


################################################################
##
##  Local Directories for Kafka
##

locals {
  zookeeper_data_path = pathexpand("${var.kubepv_root}/zookeeper/data")
  zookeeper_log_path  = pathexpand("${var.kubepv_root}/zookeeper/log")
  kafka_data_path     = pathexpand("${var.kubepv_root}/kafka/data")
}

resource null_resource kafka_local_directories {
  count = var.kafka_enabled ? 1 : 0

  triggers = {
    args = join(" ", [
      local.zookeeper_data_path,
      local.zookeeper_log_path,
      local.kafka_data_path,
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
##  zookeeper

resource kubernetes_persistent_volume_claim zookeeper {
  count = var.kafka_enabled ? 1 : 0

  metadata {
    # name: volumeclaimtemplates-name-statefulset-name-replica-index
    name = "datadir-kafka-cp-zookeeper-0"
    namespace = kubernetes_namespace.kafka.0.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.zookeeper_data_size
      }
    }
    volume_name = kubernetes_persistent_volume.zookeeper.0.metadata[0].name
    storage_class_name = "local-storage"
  }
  wait_until_bound = true
}

resource kubernetes_persistent_volume zookeeper {
  count = var.kafka_enabled ? 1 : 0

  depends_on = [
    null_resource.kafka_local_directories
  ]

  metadata {
    name = "zookeeper-0"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    capacity = {
      storage = var.zookeeper_data_size
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
        path = local.zookeeper_data_path
      }
    }
    storage_class_name = "local-storage"
    volume_mode = "Filesystem"
  }
}

resource kubernetes_persistent_volume_claim zookeeper_log {
  count = var.kafka_enabled ? 1 : 0

  metadata {
    # name: volumeclaimtemplates-name-statefulset-name-replica-index
    name = "datalogdir-kafka-cp-zookeeper-0"
    namespace = kubernetes_namespace.kafka.0.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.zookeeper_log_size
      }
    }
    volume_name = kubernetes_persistent_volume.zookeeper_log.0.metadata[0].name
    storage_class_name = "local-storage"
  }
  wait_until_bound = true
}

resource kubernetes_persistent_volume zookeeper_log {
  count = var.kafka_enabled ? 1 : 0

  depends_on = [
    null_resource.kafka_local_directories
  ]

  metadata {
    name = "zookeeper-log-0"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    capacity = {
      storage = var.zookeeper_log_size
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
        path = local.zookeeper_log_path
      }
    }
    storage_class_name = "local-storage"
    volume_mode = "Filesystem"
  }
}

##--------------------------------------------------------------
##  kafka

resource kubernetes_persistent_volume_claim kafka {
  count = var.kafka_enabled ? 1 : 0

  metadata {
    # name: volumeclaimtemplates-name-statefulset-name-replica-index
    name = "datadir-0-kafka-cp-kafka-0"
    namespace = kubernetes_namespace.kafka.0.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.kafka_data_size
      }
    }
    volume_name = kubernetes_persistent_volume.kafka.0.metadata[0].name
    storage_class_name = "local-storage"
  }
  wait_until_bound = true
}

resource kubernetes_persistent_volume kafka {
  count = var.kafka_enabled ? 1 : 0

  depends_on = [
    null_resource.kafka_local_directories
  ]

  metadata {
    name = "kafka-0-0"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    capacity = {
      storage = var.kafka_data_size
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
        path = local.kafka_data_path
      }
    }
    storage_class_name = "local-storage"
    volume_mode = "Filesystem"
  }
}
