locals {
  # DNS names, subdomain is optional   
  rel_domain = format("%s%s", var.talos_cluster_name,
  var.subdomain == "" ? "" : format(".%s", var.subdomain))

  full_domain = format("%s.%s", local.rel_domain, var.dns_zone)
}