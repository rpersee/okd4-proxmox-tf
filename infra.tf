provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true
  ssh { # required to upload snippets
    agent = true
  }
}

locals {
  proxmox_datastore = coalesce(var.proxmox_datastore, length(local.filtered_datastores) > 0 ? local.filtered_datastores[0] : "local")
  filtered_datastores = [
    for idx in range(length(data.proxmox_virtual_environment_datastores.all.datastore_ids)) :
    data.proxmox_virtual_environment_datastores.all.datastore_ids[idx] if(
      data.proxmox_virtual_environment_datastores.all.active[idx] == true &&
      contains(data.proxmox_virtual_environment_datastores.all.content_types[idx], "iso") &&
      data.proxmox_virtual_environment_datastores.all.datastore_ids[idx] != "local"
    )
  ]
}

data "proxmox_virtual_environment_datastores" "all" {
  node_name = var.proxmox_node
}

resource "proxmox_virtual_environment_file" "coreos_qcow2" {
  depends_on   = [docker_container.coreos_bootimage]
  content_type = "iso"
  datastore_id = local.proxmox_datastore
  node_name    = var.proxmox_node

  source_file {
    # append extension to bypass Proxmox VE API validation code
    file_name = "${basename(local.coreos_boot_image)}.img"
    path      = local.coreos_boot_image
  }
}

# resource "proxmox_virtual_environment_vm" "sno" {
#   name      = "sno-${var.ocp_cluster_name}"
#   node_name = var.proxmox_node
#   cpu {
#     cores = 6
#     type = "x86-64-v2-AES"
#   }
#   memory {
#     dedicated = 8192
#     floating  = 16384
#   }
#   disk {
#     datastore_id = "data"
#     file_id      = proxmox_virtual_environment_file.coreos_qcow2.id
#     interface    = "virtio0"
#     iothread     = true
#     discard      = "on"
#     size         = 120
#   }
#   initialization {
#     ip_config {
#       ipv4 {
#         address = "dhcp"
#       }
#     }
#     datastore_id = "data"
#     user_data_file_id = proxmox_virtual_environment_file.ignition_snippet.id
#   }
#   network_device {
#     bridge = "vmbr0"
#   }
#   serial_device {}
# }
