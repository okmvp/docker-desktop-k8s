terraform {
  backend local {
    path = "terraform.tfstate"
  }
}

provider kubernetes {
  config_path    = var.kubernetes_config_path
  config_context = var.kubernetes_config_context
}

provider helm {
  kubernetes {
    config_path    = var.kubernetes_config_path
    config_context = var.kubernetes_config_context
  }
}
