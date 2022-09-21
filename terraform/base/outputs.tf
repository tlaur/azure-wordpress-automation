# Output resource group name
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

# Output web host VM public IP address
output "vm_public_ip_address" {
  value = azurerm_public_ip.serverpublicip.ip_address
}

# Output key vault ID
output "key_vault_id" {
  value = azurerm_key_vault.kv.id
}

# Output MySQL flexible server name
output "mysql_server_name" {
  value = azurerm_mysql_flexible_server.wpdbserver.name
}