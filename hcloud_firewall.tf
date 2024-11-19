# create basic firewall for talos

resource "hcloud_firewall" "fw_extern" {
  name = "fw_extern"

  # basic networking
  rule { # icmp
    description = "allow icmp"
    direction   = "in"
    protocol    = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # management
  rule { # talos api
    description = "allow talosctl"
    direction   = "in"
    protocol    = "tcp"
    port        = "50000-50001"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule { # kube api
    description = "allow kube api"
    direction   = "in"
    protocol    = "tcp"
    port        = "6443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule { # kubespan
    description = "allow kubespan"
    direction   = "in"
    protocol    = "udp"
    port        = "51820"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # services
  rule { # http
    description = "allow http"
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule { # https
    description = "allow https"
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_firewall" "fw_cluster" {
  name = "fw_cluster"
  rule { # cilium
    description = "allow 10250 for cilium"
    direction   = "in"
    protocol    = "tcp"
    port        = "10250"
    source_ips = [
      for s in concat(hcloud_server.talos_cp, hcloud_server.talos_cp) : "${s.ipv4_address}/32" #format("%s/32", s.ipv4_address)
    ]
  }
}
