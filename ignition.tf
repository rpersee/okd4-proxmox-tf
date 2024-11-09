locals {
  default_ssh_keys = [for k, v in data.local_file.ssh_keys : v.content if contains([
    "id_ed25519.pub", "id_ecdsa.pub", "id_rsa.pub", "id_dsa.pub"
  ], basename(v.filename))]
  ocp_ssh_key = coalesce(var.ocp_ssh_key, local.default_ssh_keys[0])
  install_dir = abspath("${path.module}/sno")
}

data "local_file" "ssh_keys" {
  for_each = fileset(pathexpand("~/.ssh"), "*.pub")
  filename = format("%s/%s", pathexpand("~/.ssh"), each.value)
}

resource "local_file" "install_config" {
  filename = "${local.install_dir}/install-config.yaml"
  content = yamlencode({
    apiVersion = "v1"
    baseDomain = var.ocp_cluster_domain
    compute = [
      {
        name     = "worker"
        replicas = 0
      }
    ]
    controlPlane = {
      name     = "master"
      replicas = 1
    }
    metadata = {
      name = var.ocp_cluster_name
    }
    networking = {
      networkType = var.ocp_network_type
      clusterNetwork = [{
        cidr       = var.ocp_cluster_network_cidr
        hostPrefix = var.ocp_cluster_network_host_prefix
      }]
      machineNetwork = [{
        cidr = var.ocp_machine_network_cidr
      }]
      serviceNetwork = [
        var.ocp_service_network_cidr
      ]
    }
    platform = {
      none = {}
    }
    bootstrapInPlace = {
      installationDisk = var.ocp_installation_disk
    }
    pullSecret = var.ocp_pull_secret
    sshKey     = local.ocp_ssh_key
  })
}

resource "docker_container" "create_config" {
  depends_on = [local_file.install_config]
  image      = docker_image.openshift_install.image_id
  name       = "create-config"
  entrypoint = ["create-config.sh"]
  volumes {
    host_path      = "${abspath(path.module)}/scripts/create-config.sh"
    container_path = "/usr/local/bin/create-config.sh"
    read_only      = true
  }
  volumes {
    host_path      = local.install_dir
    container_path = "/data"
  }
  rm      = true
  command = ["/data"]
  provisioner "local-exec" {
    command = "docker logs -f ${self.name}"
  } # display script output in real-time
}

data "local_file" "sno_ignition" {
  depends_on = [docker_container.create_config]
  filename   = "${local.install_dir}/bootstrap-in-place-for-live-iso.ign"
}

resource "proxmox_virtual_environment_file" "ignition_snippet" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node

  source_raw {
    data      = data.local_file.sno_ignition.content
    file_name = "${var.ocp_cluster_name}-sno-config.ign"
  }
}