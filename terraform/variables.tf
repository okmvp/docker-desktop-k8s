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
}

variable argo_admin_password {
  type = string
}

variable argo_admin_modified {
  type = string
  default = "2021-01-01T00:00:00Z"
}
