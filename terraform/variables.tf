variable kubeconfig_path {
  type = string
  default = "~/.kube/config"
}

variable kubeconfig_context {
  type = string
  default = "docker-desktop"
}

variable kubepv_root {
  type = string
  default = "~/work/workdata/docker-desktop/k8s-pv"
}

variable domain {
  type = string
  default = "okmvp.internal"
}


################################################################
##
##  Applications
##

##--------------------------------------------------------------
##  Argo

variable apps_repository {
  type = string
  default = "https://github.com/okmvp/docker-desktop-k8s.git"
}

variable apps_revision {
  type = string
  default = "main"
}

variable argo_admin_password {
  type = string
}

variable argo_admin_modified {
  type = string
  default = "2021-01-01T00:00:00Z"
}

##--------------------------------------------------------------
##  Ingress

variable ingress_type {
  type = string
  default = "nginx"
}

##--------------------------------------------------------------
##  Metal-LB

variable metallb_addresses {
  type = string
  default = "192.168.0.0/24"
}

##--------------------------------------------------------------
##  Elastic Stack

variable elasticsearch_data_size {
  type = string
  default = "4Gi"
}

##--------------------------------------------------------------
##  Kafka

variable kafka_enabled {
  type = bool
  default = false
}

variable zookeeper_data_size {
  type = string
  default = "1Gi"
}

variable zookeeper_log_size {
  type = string
  default = "4Gi"
}

variable kafka_data_size {
  type = string
  default = "4Gi"
}

