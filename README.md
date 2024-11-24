# okd4-proxmox-tf
OpenShift community OKD4 on Proxmox with Terraform

- [Requirements](#requirements)
  - [Deployment machine](#deployment-machine)

## Requirements
### Deployment machine
Terraform and client tooling for OpenShift must be installed on the deployment machine.  
Follow [OKD documentation](https://docs.okd.io/4.17/installing/installing_sno/install-sno-installing-sno.html#generating-the-install-iso-manually_install-sno-installing-sno-with-the-assisted-installer) to install `oc` and `openshift-install` or use the [`setup_tools.yml`](/setup_tools.yml) Ansible playbook.  
