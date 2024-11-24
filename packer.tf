data "talos_image_factory_extensions_versions" "this" {
  # get the latest talos version
  talos_version = var.talos_version
  filters = {
    names = [
      "iscsi-tools",
      "util-linux-tools",
    ]
  }
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
        }
      }
    }
  )
}

resource "terraform_data" "packer_image" {
  count            = (length(data.hcloud_images.talos_image) == 0) ? 1 : 0
  triggers_replace = [talos_image_factory_schematic.this.id, var.talos_version, var.talos_cluster_name]

  provisioner "local-exec" {
    when        = create
    working_dir = "${path.module}/packer/"
    #command     = "packer build ${local.image_source_build_params} ${local.image_target_build_params} -var region=${var.builder_region} -var project_id=${var.builder_project_id} -var zone=${var.builder_zone} -var network_project_id=${local.builder_network_project_id} -var network_name=${var.builder_network_name} -var subnet_name=${var.builder_subnet_name} image.pkr.hcl"
    command = "packer build -var cluster_name=${var.talos_cluster_name} -var version=${var.talos_version}  -var schematic_id=${talos_image_factory_schematic.this.id} talos_image.pkr.hcl"
  }
}