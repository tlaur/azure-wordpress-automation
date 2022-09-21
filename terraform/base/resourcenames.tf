# Change these to empty default.
# Make local values
# If variable is empty, use local. Otherwise use declared variable value.

# Common resource suffixes
variable "resource_suffix" {
  type        = string
  default     = ""
  description = "A common resource naming suffix."
}

variable "resource_suffix_short" {
  type        = string
  default     = ""
  description = "A shortened version of the common resource naming suffix without any spaces or dashes."
}

# Azure resource names
variable "resource_group_name" {
  type        = string
  default     = ""
  description = "Name of the resource group where project resources will be created in."
}

variable "webhost_vm_name" {
  type        = string
  default     = ""
  description = "Name of the webhost virtual machine instance."
}

variable "webhost_vm_os_disk_name" {
  type        = string
  default     = ""
  description = "Name of webhost virtual machine OS disk."
}

variable "mysql_server_name" {
  type        = string
  default     = ""
  description = "Name of MySQL flexible server instance."
}

variable "vnet_name" {
  type        = string
  default     = ""
  description = "Name of VNET which relevant project resources will be associated with."
}

variable "vnet_vm_subnet_name" {
  type        = string
  default     = ""
  description = "Name of subnet for webhost VM instance(s)."
}

variable "vnet_db_subnet_name" {
  type        = string
  default     = ""
  description = "Name of subnet for database server instance(s)."
}

variable "vnet_vm_nic_name" {
  type        = string
  default     = ""
  description = "Name of NIC associated with webhost VM."
}

variable "vnet_vm_public_ip_name" {
  type        = string
  default     = ""
  description = "Name of public IP resource associated with webhost VM NIC."
}

variable "key_vault_name" {
  type        = string
  default     = ""
  description = "Name of key vault used to store project secrets."
}

variable "private_dns_zone_name" {
  type        = string
  default     = ""
  description = "Name of private DNS zone used to secure webhost VM and DB traffic."
}

variable "private_dns_zone_virtual_network_link_name" {
  type        = string
  default     = ""
  description = "Name of private DNS zone and project VNET link."
}