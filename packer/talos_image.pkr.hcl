packer {
  required_plugins {
    hcloud = {
      version = ">= 1.6"
      source  = "github.com/hetznercloud/hcloud"
    }
  }
}

variable "version" {
  type = string
}

variable "schematic_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

locals {
  image = "https://factory.talos.dev/image/${var.schematic_id}/${var.version}/hcloud-amd64.raw.xz"
}

# smallest possible for building
source "hcloud" "talos" {
  rescue       = "linux64"
  image        = "debian-11"
  location     = "fsn1"
  server_type  = "cx22"
  ssh_username = "root"

  snapshot_name = "talos system disk ${var.version} ${var.cluster_name}"
  snapshot_labels = {
    type    = "infra",
    os      = "talos",
    version = "${var.version}",
    cluster = "${var.cluster_name}"
  }
}

build {
  sources = ["source.hcloud.talos"]

  provisioner "shell" {
    inline = [
      "apt-get install -y wget xz-utils",
      "wget -O /tmp/talos.raw.xz ${local.image}",
      "xz -d -c /tmp/talos.raw.xz | dd of=/dev/sda && sync",
    ]
  }
}
