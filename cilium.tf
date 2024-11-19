
data "helm_template" "cilium" {
  #depends_on = [local_file.kubeconfig]
  name         = "cilium"
  namespace    = "kube-system"
  chart        = "cilium"
  repository   = "https://helm.cilium.io/"
  version      = "1.16.0-rc.0"
  kube_version = "1.29"
  atomic       = true

  # features
  set {
    name  = "nodeIPAM.enabled"
    value = "true"
  }
  set {
    name  = "gatewayAPI.enabled"
    value = "true"
  }

  # node count specific
  set { # operator relicas
    name  = "operator.replicas"
    value = (var.talos_num_cp + var.talos_num_wk == 1) ? 1 : var.cilium_operator_replicas
  }

  # talos settings
  set { # ipam mode
    name  = "ipam.mode"
    value = "kubernetes"
  }
  set {
    name  = "kubeProxyReplacement"
    value = "true"
  }
  set {
    name  = "securityContext.capabilities.ciliumAgent"
    value = "{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}"
  }
  set {
    name  = "securityContext.capabilities.cleanCiliumState"
    value = "{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}"
  }
  set {
    name  = "cgroup.autoMount.enabled"
    value = "false"
  }
  set {
    name  = "cgroup.hostRoot"
    value = "/sys/fs/cgroup"
  }
  set {
    name  = "k8sServiceHost"
    value = "localhost"
  }
  set {
    name  = "k8sServicePort"
    value = "7445"
  }
}

# output "cilium_manifest" {
#   value     = data.helm_template.cilium.manifest
#   sensitive = true
# }
