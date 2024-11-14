# CoreOS variables ================================================
variable "coreos_architecture" {
  default = "x86_64"
}

variable "coreos_platform" {
  default = "ibmcloud" # Proxmox VE is currently not supported
  # use IBM Cloud as a workaround: https://github.com/coreos/ignition/pull/1790
}

variable "coreos_image_format" {
  default = "qcow2.xz"
}

# Proxmox VE variables ================================================
variable "proxmox_endpoint" {
  type        = string
  description = "The endpoint for the Proxmox Virtual Environment API (example: https://host:port)"
}

variable "proxmox_password" {
  type        = string
  sensitive   = true
  description = "The password for the Proxmox Virtual Environment API"
}

variable "proxmox_username" {
  type        = string
  sensitive   = true
  description = "The username and realm for the Proxmox Virtual Environment API (example: root@pam)"
}

variable "proxmox_node" {
  description = "Proxmox node name"
  default     = "localhost"
}

variable "proxmox_datastore" {
  description = "Proxmox datastore name"
  default     = null
}

# OpenShift Container Platform variables ================================================
variable "ocp_sno_hostname" {
  description = "The hostname for the single-node OpenShift cluster."
  type        = string
  default     = "sno"
}

variable "ocp_cluster_name" {
  description = "The cluster name that you specified in your DNS records."
  type        = string
  default     = "ocp4"
}

variable "ocp_base_domain" {
  description = "The base domain to which the cluster should belong."
  type        = string
  default     = "home.arpa"
}

variable "ocp_network_type" {
  description = "The type of network to install."
  type        = string
  default     = "OVNKubernetes"
}

variable "ocp_cluster_network_cidr" {
  description = "The IP address pools for pods."
  type        = string
  default     = "10.128.0.0/14"
}

variable "ocp_cluster_network_host_prefix" {
  description = "The prefix size to allocate to each node from the CIDR."
  type        = number
  default     = 23
}

variable "ocp_machine_network_cidr" {
  description = "The IP address pool for machines."
  type        = string
  default     = "192.168.1.0/24"
} # should match the CIDR that the preferred NIC resides in

variable "ocp_service_network_cidr" {
  description = "The IP address pool for services."
  type        = string
  default     = "172.30.0.0/16"
}

variable "ocp_pull_secret" {
  description = "The secret to use when pulling images."
  type        = string
  default     = "{\"auths\":{\"fake\":{\"auth\":\"aWQ6cGFzcwo=\"}}}"
}

variable "ocp_ssh_key" {
  description = "The public Secure Shell (SSH) key to provide access to instances."
  type        = string
  default     = null
}

variable "ocp_installation_disk" {
  description = "The target disk drive for coreos-installer."
  type        = string
  default     = "/dev/vda"
}

variable "ocp_net_config" {
  description = "The network configuration for the SNO deployment."
  type = object({
    address_cidr = string
    gateway      = string
    nameserver   = string
  })
  default = {
    address_cidr = "192.168.1.140/24"
    gateway      = "192.168.1.1"
    nameserver   = "192.168.1.254"
  }
}