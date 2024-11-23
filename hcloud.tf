
data "hcloud_image" "talos_image" {
  with_selector = "type=infra,os=talos,version=${var.talos_version}"
}

resource "hcloud_network" "private_net" {
  name     = var.hcloud_private_network.name
  ip_range = var.hcloud_private_network.cidr
}

resource "hcloud_placement_group" "worker" {
  name = "worker-${var.talos_cluster_name}"
  type = "spread"
}

resource "hcloud_placement_group" "controlplane" {
  name = "controlplane-${var.talos_cluster_name}"
  type = "spread"
}

resource "hcloud_network_subnet" "private_subnet" {
  network_id   = hcloud_network.private_net.id
  type         = "cloud"
  network_zone = var.hcloud_network_zone
  ip_range     = var.hcloud_private_network.cidr
}

resource "hcloud_server" "talos_cp" {
  count              = var.talos_num_cp
  name               = format("cp%02d", count.index + 1)
  image              = data.hcloud_image.talos_image.id
  server_type        = var.hcloud_server_type_cp
  datacenter         = var.hcloud_datacenter
  firewall_ids       = [hcloud_firewall.fw_extern.id]
  placement_group_id = hcloud_placement_group.controlplane.id
  network {
    network_id = hcloud_network.private_net.id
  }

  labels = {
    "app" : "talos"
    "cluster" : var.talos_cluster_name
    "type" : "controlplane"
  }
  depends_on = [hcloud_network.private_net]
}

resource "hcloud_volume" "master" {
  # no fs or partitions on disk!
  for_each  = { for s in concat(hcloud_server.talos_cp, hcloud_server.talos_wk) : s.name => s }
  name      = format("%s-%s", var.talos_cluster_name, each.value.name)
  size      = 10
  server_id = each.value.id
  automount = false
}

resource "hcloud_server" "talos_wk" {
  count = var.talos_num_wk
  name  = format("wk%02d", count.index + 1)

  image              = data.hcloud_image.talos_image.id
  server_type        = var.hcloud_server_type_wk
  datacenter         = var.hcloud_datacenter
  firewall_ids       = [hcloud_firewall.fw_extern.id]
  placement_group_id = hcloud_placement_group.worker.id
  network {
    network_id = hcloud_network.private_net.id
  }

  labels = {
    "app" : "talos"
    "cluster" : var.talos_cluster_name
    "type" : "worker"
  }
  depends_on = [hcloud_network.private_net]
}

resource "hcloud_firewall_attachment" "fw_cluster" {
  firewall_id = hcloud_firewall.fw_cluster.id
  server_ids  = concat(hcloud_server.talos_cp[*].id, hcloud_server.talos_wk[*].id)
}

resource "hcloud_rdns" "rdns_v4" { # reverse dns
  for_each   = { for s in concat(hcloud_server.talos_cp, hcloud_server.talos_wk) : s.name => s }
  server_id  = each.value.id
  ip_address = each.value.ipv4_address
  dns_ptr    = format("%s.%s", each.value.name, local.full_domain)
}
resource "hcloud_rdns" "rdns_v6" { # reverse dns
  for_each   = { for s in concat(hcloud_server.talos_cp, hcloud_server.talos_wk) : s.name => s }
  server_id  = each.value.id
  ip_address = each.value.ipv6_address
  dns_ptr    = format("%s.%s", each.value.name, local.full_domain)
}

