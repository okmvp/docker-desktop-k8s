variable kubernetes_config_path {
  type = string
  default = "~/.kube/config"
}

variable kubernetes_config_context {
  type = string
  default = "docker-desktop"
}

variable domain {
  type = string
  default = "okmvp.internal"
}

variable argo_admin_password {
  type = string
}

variable argo_admin_modified {
  type = string
  default = "2021-01-01T00:00:00Z"
}

variable metallb_addresses {
  type = string
  default = "192.168.0.0/24"
}
