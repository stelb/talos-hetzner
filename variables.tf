# TALOS
variable "talos_num_cp" {
  type        = number
  description = "number of controlplan servers"
}
variable "talos_num_wk" {
  type        = number
  description = "number of worker servers"
}
variable "talos_version" {
  type        = string
  description = "talos image version"
}
variable "talos_cluster_name" {
  type        = string
  description = "name of the cluster"
}
variable "subdomain" {
  type        = string
  description = "subdomain"
}

# HCLOUD
variable "hcloud_token" {
  sensitive = true
}
variable "hcloud_datacenter" {
  type = string
}
variable "hcloud_network_zone" {
  type = string
}
variable "hcloud_server_type_cp" {
  type = string
}
variable "hcloud_server_type_wk" {
  type = string
}
variable "hcloud_private_network" {
  type = object({
    name = string
    cidr = string
  })
  default = {
    name = "talos-private"
    cidr = "10.1.0.0/24"
  }
}


# cilium
variable "cilium_operator_replicas" {
  type    = number
  default = 2
}

# DNS
variable "dns_zone" {
  type = string
}


variable "kubeconfig" {
  type = string
}
