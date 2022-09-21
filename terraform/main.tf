terraform {
  required_version = ">= 1.2.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.13.0"
    }
    namecheap = {
      source  = "namecheap/namecheap"
      version = "= 2.1.0"
    }
  }
}

provider "azurerm" {
  features {}

  tenant_id       = var.az_tenant_id
  subscription_id = var.az_subscription_id
  client_id       = var.az_infra_app_id
  client_secret   = var.az_infra_app_secret
}

provider "namecheap" {
  user_name = var.namecheap_user_name
  api_user  = var.namecheap_api_user
  api_key   = var.namecheap_api_key
}

locals {
  # Common resource suffixes
  resource_suffix       = "${var.project_name}-${var.environment_type}"
  resource_suffix_short = "${var.project_name}${var.environment_type}"

  # Azure resource names
  key_vault_name                             = "kv-${local.resource_suffix}"
  private_dns_zone_name                      = "${local.resource_suffix_short}.mysql.database.azure.com"
  private_dns_zone_virtual_network_link_name = "dnszonevnetlink"
  resource_group_name                        = "rg-${local.resource_suffix}"
  vnet_name                                  = "vnet-${local.resource_suffix}"
  vnet_vm_nic_name                           = "nic-${local.webhost_vm_name}"
  vnet_vm_public_ip_name                     = "pip-${local.webhost_vm_name}"
  vnet_vm_subnet_name                        = "snet-webservers-${var.environment_type}"
  vnet_db_subnet_name                        = "snet-db-${var.environment_type}"
  webhost_vm_name                            = "vm-${local.resource_suffix}"
  webhost_vm_os_disk_name                    = "osdisk-${local.webhost_vm_name}"
  mysql_server_name                          = "mysql-${local.resource_suffix}"
}

module "shared" {
  source = "./base"

  # Project settings
  project_name     = var.project_name
  environment_type = var.environment_type

  # Azure configuration
  az_deployment_region          = var.az_deployment_region
  webhost_vm_admin_ssh_key_path = var.webhost_vm_admin_ssh_key_path
  webhost_vm_hostname           = var.webhost_vm_hostname
  webhost_vm_admin_username     = var.webhost_vm_admin_username
  webhost_vm_image_publisher    = var.webhost_vm_image_publisher
  webhost_vm_image_offer        = var.webhost_vm_image_offer
  webhost_vm_image_sku          = var.webhost_vm_image_sku
  webhost_vm_image_version      = var.webhost_vm_image_version


  # Resource names
  resource_group_name     = local.resource_group_name
  webhost_vm_name         = local.webhost_vm_name
  webhost_vm_os_disk_name = local.webhost_vm_os_disk_name
  vnet_name               = local.vnet_name
  vnet_vm_nic_name        = local.vnet_vm_nic_name
  vnet_vm_public_ip_name  = local.vnet_vm_public_ip_name
  vnet_vm_subnet_name     = local.vnet_vm_subnet_name
  vnet_db_subnet_name     = local.vnet_db_subnet_name
  mysql_server_name       = local.mysql_server_name
  key_vault_name          = local.key_vault_name

  # Ansible configuration
  ansible_inventory_template_path = "./base/templates/ansible_inventory.tftpl"
  ansible_inventory_output_path   = "../.config/hosts"
}

module "site_your-domain-name" {
  source = "./site"

  # Namecheap configuration
  namecheap_user_name   = var.namecheap_user_name
  namecheap_api_user    = var.namecheap_api_user
  namecheap_api_key     = var.namecheap_api_key
  namecheap_domain_name = "your-domain-name.com"

  # Azure configuration
  az_resource_group_name = module.shared.resource_group_name
  az_webserver_public_ip = module.shared.vm_public_ip_address
  az_key_vault_id        = module.shared.key_vault_id
  az_mysql_server_name   = module.shared.mysql_server_name

  # Ansible configuration variables
  ansible_vars_template_path = "./site/templates/ansible_variables.tftpl"
  ansible_vars_output_path   = "../.config/your-domain-name.com/ansible_variables.yml"

  # Nginx configuration
  nginx_config_template_path = "./site/templates/nginx_configuration.tftpl"
  nginx_config_output_path   = "../.config/your-domain-name.com/nginx_config"

  # WordPress configuration
  wordpress_config_template_path = "./site/templates/wordpress_configuration.tftpl"
  wordpress_config_output_path   = "../.config/your-domain-name.com/wordpress_config.php"

  # TLS certificate notifications email
  tls_cert_email = "your.email@domain.com"
}
