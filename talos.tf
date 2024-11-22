

locals {
  hccm_secret = yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "hcloud"
      namespace = "kube-system"
    }
    data = {
      network = base64encode(var.hcloud_private_network.name)
      token   = base64encode(var.hcloud_token)
    }
  })

  endpoint_ip = hcloud_server.talos_cp[0].ipv4_address

  talos_config_cp_patches = yamlencode({
    cluster = {
      # etcd = {
      #   advertisedSubnets = [
      #     "!${var.hcloud_private_network.cidr}"
      #   ]
      # }
      # kubernetes version
      apiServer = {
        image = (var.kubernetes_version != "") ? "registry.k8s.io/kube-apiserver:v${var.kubernetes_version}" : null
      }
      controllerManager = {
        image = (var.kubernetes_version != "") ? "registry.k8s.io/kube-controller-manager:v${var.kubernetes_version}" : null
      }
      proxy = {
        image = (var.kubernetes_version != "") ? "registry.k8s.io/kube-proxy:v${var.kubernetes_version}" : null
      }
      scheduler = {
        image = (var.kubernetes_version != "") ? "registry.k8s.io/kube-scheduler:v${var.kubernetes_version}" : null
      }
    }
  })
  talos_config_patches = yamlencode({
    cluster = {
      allowSchedulingOnControlPlanes = var.schedule_on_controlplane
      network = {
        cni = {
          name = "none"
        }
      }
      proxy = {
        disabled = true
      }
      externalCloudProvider = {
        enabled = true
      }
      discovery = {
        enabled = true
      }
      # etcd = {
      #   advertisedSubnets = [
      #     "${var.hcloud_private_network.cidr}"
      #   ]
      # }
      extraManifests = [
        "https://raw.githubusercontent.com/hetznercloud/hcloud-cloud-controller-manager/main/deploy/ccm-networks.yaml",
        "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/experimental-install.yaml"
      ]
      inlineManifests = [
        {
          name     = "cilium"
          contents = data.helm_template.cilium.manifest
        },
        {
          name     = "hccm secret"
          contents = local.hccm_secret
        }
      ]
    }
    machine = {
      kubelet = {
        image = (var.kubernetes_version != "") ? "ghcr.io/siderolabs/kubelet:v${var.kubernetes_version}" : null
        nodeIP = {
          validSubnets = [
            "${var.hcloud_private_network.cidr}"
          ]
        }
      }
    }
  })

  # for longhorn and small storage needs, hetzner volumes are at least 10G
  talos_disk_patch = yamlencode({
    machine = {
      kubelet = {
        extraMounts = [
          {
            destination = "/var/mnt/storage"
            type        = "bind"
            source      = "/var/mnt/storage"
            options     = ["bind", "rshared", "rw"]
          }
        ]
      }
      disks = [{
        device     = "/dev/sdb"
        partitions = [{ mountpoint = "/var/mnt/storage" }]
      }]
    }
  })
}


# create secrets
resource "talos_machine_secrets" "this" {}

data "talos_client_configuration" "this" {
  cluster_name         = var.talos_cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [local.endpoint_ip]
}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.talos_cluster_name
  cluster_endpoint = "https://${local.endpoint_ip}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches = [
    local.talos_config_patches,
    local.talos_config_cp_patches,
    local.talos_disk_patch
  ]
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each                    = { for s in hcloud_server.talos_cp : s.name => s }
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value.ipv4_address
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.controlplane
  ]
  node                 = local.endpoint_ip
  client_configuration = talos_machine_secrets.this.client_configuration
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.talos_cluster_name
  cluster_endpoint = "https://${local.endpoint_ip}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches   = [local.talos_config_patches, local.talos_disk_patch]
}

resource "talos_machine_configuration_apply" "worker" {
  for_each                    = { for s in hcloud_server.talos_wk : s.name => s }
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value.ipv4_address
}

data "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.endpoint_ip
  #  wait                 = true
}

# actually there should be a check with talos_cluster_health, but fails for me with internal network





