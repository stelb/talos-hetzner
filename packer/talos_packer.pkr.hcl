packer {
  required_plugins {
    hcloud = {
      version = ">= 1.2"
      source  = "github.com/hetznercloud/hcloud"
    }
  }
}

variable "talos_version" {
  type    = string
  default = "v1.8.3"
}

locals {
  # link created with image factory: https://factory.talos.dev
  # Cloud Server / 1.8.3 / Hetzner / <no extensions right now> / <no customizing>
  image = "https://factory.talos.dev/image/376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba/v1.8.3/hcloud-amd64.raw.xz"
}

# smallest possible for building
source "hcloud" "talos" {
  rescue       = "linux64"
  image        = "debian-11"
  location     = "fsn1"
  server_type  = "cx22"
  ssh_username = "root"

  snapshot_name = "talos system disk ${var.talos_version}"
  snapshot_labels = {
    type    = "infra",
    os      = "talos",
    version = "${var.talos_version}",
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
