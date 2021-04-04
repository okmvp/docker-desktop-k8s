locals {
  kafka_namespace = "kafka"
}

resource kubernetes_namespace kafka {
  metadata {
    name = local.kafka_namespace
  }
}


################################################################
##
##  Kubernetes Persistent Volumes
##

##--------------------------------------------------------------
##  zookeeper

resource kubernetes_persistent_volume_claim zookeeper {
  metadata {
    # name: volumeclaimtemplates-name-statefulset-name-replica-index
    name = "datadir-kafka-cp-zookeeper-0"
    namespace = kubernetes_namespace.kafka.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "${var.zookeeper_data_size}Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.zookeeper.metadata[0].name
  }
}

resource kubernetes_persistent_volume zookeeper {
  metadata {
    name = "zookeeper-0"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    capacity = {
      storage = "${var.zookeeper_data_size}Gi"
    }
    persistent_volume_source {
      host_path {
        path = pathexpand("${var.kubepv_root}/zookeeper/data")
      }
    }
  }
}

resource kubernetes_persistent_volume_claim zookeeper_log {
  metadata {
    # name: volumeclaimtemplates-name-statefulset-name-replica-index
    name = "datalogdir-kafka-cp-zookeeper-0"
    namespace = kubernetes_namespace.kafka.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "${var.zookeeper_log_size}Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.zookeeper_log.metadata[0].name
  }
}

resource kubernetes_persistent_volume zookeeper_log {
  metadata {
    name = "zookeeper-log-0"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    capacity = {
      storage = "${var.zookeeper_log_size}Gi"
    }
    persistent_volume_source {
      host_path {
        path = pathexpand("${var.kubepv_root}/zookeeper/log")
      }
    }
  }
}

##--------------------------------------------------------------
##  kafka

resource kubernetes_persistent_volume_claim kafka {
  metadata {
    # name: volumeclaimtemplates-name-statefulset-name-replica-index
    name = "datadir-0-kafka-cp-kafka-0"
    namespace = kubernetes_namespace.kafka.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "${var.kafka_data_size}Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.kafka.metadata[0].name
  }
}

resource kubernetes_persistent_volume kafka {
  metadata {
    name = "kafka-0-0"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    capacity = {
      storage = "${var.kafka_data_size}Gi"
    }
    persistent_volume_source {
      host_path {
        path = pathexpand("${var.kubepv_root}/kafka/data")
      }
    }
  }
}
