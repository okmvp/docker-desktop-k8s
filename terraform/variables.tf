variable kubeconfig_path {
  type = string
  default = "~/.kube/config"
}

variable kubeconfig_context {
  type = string
  default = "docker-desktop"
}

variable domain {
  type = string
  default = "okmvp.internal"
}

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

variable metallb_addresses {
  type = string
  default = "192.168.0.0/24"
}
