terraform {
  required_version = ">= 1.2.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.13.0"
    }
  }
}

locals {
  # Common resource suffixes
  resource_suffix       = var.resource_suffix == "" ? "${var.project_name}-${var.environment_type}" : var.resource_suffix
  resource_suffix_short = var.resource_suffix_short == "" ? "${var.project_name}${var.environment_type}" : var.resource_suffix_short

  # Azure resource names
  key_vault_name                             = var.key_vault_name == "" ? "kv-${local.resource_suffix}" : var.key_vault_name
  private_dns_zone_name                      = var.private_dns_zone_name == "" ? "${local.resource_suffix_short}.mysql.database.azure.com" : var.private_dns_zone_name
  private_dns_zone_virtual_network_link_name = var.private_dns_zone_virtual_network_link_name == "" ? "dnszonevnetlink" : var.private_dns_zone_virtual_network_link_name
  resource_group_name                        = var.resource_group_name == "" ? "rg-${local.resource_suffix}" : var.resource_group_name
  vnet_name                                  = var.vnet_name == "" ? "vnet-${local.resource_suffix}" : var.vnet_name
  vnet_vm_nic_name                           = var.vnet_vm_nic_name == "" ? "nic-${local.webhost_vm_name}" : var.vnet_vm_nic_name
  vnet_vm_public_ip_name                     = var.vnet_vm_public_ip_name == "" ? "pip-${local.webhost_vm_name}" : var.vnet_vm_public_ip_name
  vnet_vm_subnet_name                        = var.vnet_vm_subnet_name == "" ? "snet-webservers-${var.environment_type}" : var.vnet_vm_subnet_name
  vnet_db_subnet_name                        = var.vnet_db_subnet_name == "" ? "snet-db-${var.environment_type}" : var.vnet_db_subnet_name
  webhost_vm_name                            = var.webhost_vm_name == "" ? "vm-${local.resource_suffix}" : var.webhost_vm_name
  webhost_vm_os_disk_name                    = var.webhost_vm_os_disk_name == "" ? "osdisk-${local.webhost_vm_name}" : var.webhost_vm_os_disk_name
  mysql_server_name                          = var.mysql_server_name == "" ? "mysql-${local.resource_suffix}" : var.mysql_server_name

}

data "azurerm_client_config" "azconfig" {}

# Main resource group
resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.az_deployment_region
}

# Webhost VM configuration
resource "azurerm_virtual_machine" "vm" {
  name                          = local.webhost_vm_name
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  network_interface_ids         = [azurerm_network_interface.nic.id]
  vm_size                       = var.webhost_vm_size
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = var.webhost_vm_image_publisher
    offer     = var.webhost_vm_image_offer
    sku       = var.webhost_vm_image_sku
    version   = var.webhost_vm_image_version
  }

  storage_os_disk {
    name              = local.webhost_vm_os_disk_name
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.webhost_vm_hostname
    admin_username = var.webhost_vm_admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file(var.webhost_vm_admin_ssh_key_path)
      path     = "/home/${var.webhost_vm_admin_username}/.ssh/authorized_keys"
    }
  }
}

# Networking configuration
resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "webservers" {
  name                 = local.vnet_vm_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azurerm_subnet" "db" {
  name                 = local.vnet_db_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.20.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "mysql_flex_server_delegation"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_network_interface" "nic" {
  name                = local.vnet_vm_nic_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "webvmipconfiguration"
    subnet_id                     = azurerm_subnet.webservers.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.serverpublicip.id
  }
}

resource "azurerm_public_ip" "serverpublicip" {
  name                = local.vnet_vm_public_ip_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_private_dns_zone" "privdnszone" {
  name                = local.private_dns_zone_name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnsvnetvmlink" {
  name                  = local.private_dns_zone_virtual_network_link_name
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.privdnszone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# WordPress MySQL flexible database server configuration
resource "azurerm_mysql_flexible_server" "wpdbserver" {
  name                = local.mysql_server_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  zone                = "1"

  sku_name               = var.mysql_server_sku
  version                = var.mysql_server_version
  administrator_login    = var.mysql_server_admin_username == "" ? random_pet.mysql_server_admin_username.id : var.mysql_server_admin_username
  administrator_password = var.mysql_server_admin_password == "" ? random_password.mysql_server_admin_password.result : var.mysql_server_admin_password
  backup_retention_days  = var.mysql_server_backup_retention_length
  delegated_subnet_id    = azurerm_subnet.db.id
  private_dns_zone_id    = azurerm_private_dns_zone.privdnszone.id

  depends_on = [azurerm_private_dns_zone_virtual_network_link.dnsvnetvmlink]
}

resource "random_pet" "mysql_server_admin_username" {
  length    = 3
  separator = "_"
}

resource "random_password" "mysql_server_admin_password" {
  length      = 16
  special     = true
  min_lower   = 2
  min_upper   = 2
  min_numeric = 2
  min_special = 2
}


# Key vault configuration
resource "azurerm_key_vault" "kv" {
  name                     = local.key_vault_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku_name                 = "standard"
  tenant_id                = data.azurerm_client_config.azconfig.tenant_id
  purge_protection_enabled = false

  access_policy {
    tenant_id = data.azurerm_client_config.azconfig.tenant_id
    object_id = data.azurerm_client_config.azconfig.object_id

    certificate_permissions = [
      "Get",
      "List",
      "Update",
      "Create",
      "Import",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "ManageContacts",
      "ManageIssuers",
      "GetIssuers",
      "ListIssuers",
      "SetIssuers",
      "DeleteIssuers",
      "Purge"
    ]

    key_permissions = [
      "Get",
      "List",
      "Update",
      "Create",
      "Import",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "Purge"
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "Purge"
    ]

    storage_permissions = [
      "Get",
      "Purge"
    ]
  }

}

resource "azurerm_key_vault_secret" "webhost_vm_admin_name" {
  name         = "webhost-vm-admin-username"
  value        = azurerm_virtual_machine.vm.os_profile.*.admin_username[0]
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "mysql_server_admin_name" {
  name         = "mysql-server-admin-username"
  value        = azurerm_mysql_flexible_server.wpdbserver.administrator_login
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "mysql_server_admin_pass" {
  name         = "mysql-server-admin-password"
  value        = azurerm_mysql_flexible_server.wpdbserver.administrator_password
  key_vault_id = azurerm_key_vault.kv.id
}


# Ansible inventory file
resource "local_file" "ansible_inventory_file" {
  filename = var.ansible_inventory_output_path
  content = templatefile(var.ansible_inventory_template_path,
    {
      webserver_ip             = azurerm_public_ip.serverpublicip.ip_address
      db_server_host           = azurerm_mysql_flexible_server.wpdbserver.fqdn
      db_server_admin_username = azurerm_mysql_flexible_server.wpdbserver.administrator_login
      db_server_admin_password = azurerm_mysql_flexible_server.wpdbserver.administrator_password
    }
  )
}