

terraform {
  required_providers {
    talos = {
      source = "siderolabs/talos"
      #version = "0.4.0"
    }
    hetznerdns = {
      source  = "timohirt/hetznerdns"
      version = "2.2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }
    http = { source = "hashicorp/http"
      version = "3.4.5"
    }
  }
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

provider "hetznerdns" {
  # Configuration options
}

provider "helm" {
  # $KUBE_CONFIG_PATH
}

provider "http" {}
