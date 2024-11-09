provider "docker" {
  host = "unix:///var/run/docker.sock"
}

locals {
  assets_directory = abspath("${path.module}/assets")
  coreos_boot_image = format("%s/fedora-coreos-latest-%s.%s.%s", local.assets_directory,
  var.coreos_platform, var.coreos_architecture, split(".", var.coreos_image_format)[0])
}

resource "docker_image" "openshift_install" {
  name = "openshift-install"
  build {
    context    = path.module
    dockerfile = "${path.module}/Dockerfile"
  }
}

resource "docker_container" "coreos_bootimage" {
  image      = docker_image.openshift_install.image_id
  name       = "coreos-bootimage"
  entrypoint = ["coreos-bootimage.sh"]
  volumes {
    host_path      = "${abspath(path.module)}/scripts/coreos-bootimage.sh"
    container_path = "/usr/local/bin/coreos-bootimage.sh"
    read_only      = true
  }
  volumes {
    host_path      = local.assets_directory
    container_path = "/assets/"
  }
  working_dir = "/assets/"
  rm          = true
  command     = [var.coreos_architecture, var.coreos_platform, var.coreos_image_format]
  provisioner "local-exec" {
    command = "docker logs -f ${self.name}"
  } # display script output in real-time
}
