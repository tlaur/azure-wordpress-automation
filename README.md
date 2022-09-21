Automated deployment of WordPress sites on Microsoft Azure with NameCheap domain hosting using Terraform and Ansible.

## Overview
This collection of scripts automates the deployment and maintenance of infrastructure for one or more WordPress sites. Terraform is used to deploy Azure resources including a MySQL flexible server, Virtual Machine (VM), and basic network configuration. Ansible is then used to configure the VM instance with Nginx, Wordpress, and an SSL/TLS certificate.

The configuration is designed to be simple, cheap, and give you a great degree of control over your WordPress environment. It is not really suitable for production applications, but could with a bit of extra work be modified to take advantage of for example VM Scale Sets and Load Balancing.

## Requirements
- [Microsoft Azure Account](https://azure.microsoft.com/) (or access to one)
- [Namecheap Account with API access set up](https://www.namecheap.com/support/api/intro/)
- [SSH Key Pair to use with Azure VM](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (v 1.2.4)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (v 2.12.8)

Versions indicated are minimum versions which have been confirmed working. The Azure configuration assumes the use of a service principal, but you may want to use [Azure CLI](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli) if you are just trying things out.

Please note that to install and run Ansible you will need a Linux or Mac environment. If you are on Windows you can use [Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/install)

## Install and usage
1. Clone the repository.

2. In the root terraform directory copy or rename terraform.tfvars.example to terraform.tfvars. Fill in the values with your credentials and desired deployment variables.

3. In the same directory open main.tf and replace the site_example module with details for your domain and website. Add site blocks for each website you want to install.

4. In the **terraform directory** of the repository run the following Terraform commands:
```
terraform init
```
```
terraform plan -out tfplan
```
```
terraform apply tfplan
```

5. Once Terraform has provisioned the necessary infrastructure run the following Ansible commands in the **repository root folder**:
```
ansible-playbook ansible/webserver_configuration.yml -i .config/hosts --key-file <path to SSH key>
```
```
ansible-playbook ansible/website_configuration.yml -i .config/hosts --key-file <path to SSH key> --extra-vars "@.config/<your-domain-name.com>/ansible_variables.yml"
```
**NOTE**: You may need to wait for DNS to propagate before running the website_configuration.yml playbook. You will receive errors if DNS has not propagated.

6. Go to your-domain-name.com and finish the WordPress installation process.

That's it.