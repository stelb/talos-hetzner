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
  default     = "1.8.3"
}

variable "talos_cluster_name" {
  type        = string
  description = "name of the cluster"
}

variable "kubernetes_version" {
  type        = string
  description = "kubernetes image version"
  default     = "1.31"
}

variable "cilium_version" {
  type        = string
  description = "cilium version"
  default     = "1.16"
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

variable "schedule_on_controlplane" {
  type    = bool
  default = false
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
