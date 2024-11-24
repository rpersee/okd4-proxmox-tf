# okd4-proxmox-tf
OpenShift community OKD4 on Proxmox with Terraform

- [Requirements](#requirements)
  - [Deployment machine](#deployment-machine)
  - [DNS and load-balancing](#dns-and-load-balancing)

## Requirements
### Deployment machine
Terraform and client tooling for OpenShift must be installed on the deployment machine.  
Follow [OKD documentation](https://docs.okd.io/4.17/installing/installing_sno/install-sno-installing-sno.html#generating-the-install-iso-manually_install-sno-installing-sno-with-the-assisted-installer) to install `oc` and `openshift-install` or use the [`setup_tools.yml`](/setup_tools.yml) Ansible playbook.  

### DNS and load-balancing
*During bootstrapping*, the OpenShift Internal API is used by the cluster nodes to fetch the Ignition configuration files from the bootstrap node:
- You need to configure a load balancer to direct requests for `api-int.<cluster_name>.<base_domain>:22623` to the bootstrap and master nodes
- While the Ignition configuration for the bootstrap node is standalone, the configuration for the master and worker nodes contains a [remote merge config directive](https://docs.fedoraproject.org/en-US/fedora-coreos/remote-ign/)
