resource "proxmox_virtual_environment_container" "dns" {
  description = "DNS service for OCP cluster"
  node_name = var.proxmox_node

  initialization {
    hostname = "dns-${var.ocp_cluster_name}"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys = [local.ocp_ssh_key]
    #   password = random_password.dns_container_password.result
      password = "centos"
    }
  }

  network_interface {
    name = "veth0"
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.centos_9_stream_lxc_img.id
    type             = "centos"
  }
}

resource "proxmox_virtual_environment_download_file" "centos_9_stream_lxc_img" {
  content_type = "vztmpl"
  datastore_id = local.proxmox_datastore
  node_name    = var.proxmox_node
  url          = "http://download.proxmox.com/images/system/centos-9-stream-default_20240828_amd64.tar.xz"
}

# resource "random_password" "dns_container_password" {
#   length           = 16
#   override_special = "_%@"
#   special          = true
# }

# output "dns_container_password" {
#   value     = random_password.dns_container_password.result
#   sensitive = true
# }
