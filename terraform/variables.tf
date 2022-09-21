# Environment configuration variables
variable "project_name" {
  type        = string
  description = "Project name. Used in resource naming and tagging."
}

variable "environment_type" {
  type        = string
  description = "Environment type (dev, stg, test, prod). Used in resource naming and tagging."

  validation {
    condition     = can(regex("^(dev|stg|test|prod)$", var.environment_type))
    error_message = "Invalid environment value. Value must be 'dev', 'stg', 'test', or 'prod'"
  }
}

# Azure configuration variables
variable "az_tenant_id" {
  type        = string
  description = "Azure tenant ID."
}

variable "az_subscription_id" {
  type        = string
  description = "Azure subscription ID."
}

variable "az_infra_app_id" {
  type        = string
  sensitive   = true
  description = "Application ID (Client ID) of service principal used to execute deployment."
}

variable "az_infra_app_secret" {
  type        = string
  sensitive   = true
  description = "Client secret for service principal used to execute deployment."
}

variable "az_deployment_region" {
  type        = string
  description = "Azure deployment region."
}

# Webhost VM configuration variables
variable "webhost_vm_size" {
  type        = string
  default     = "Standard_B1ls"
  description = "Webhost virtual machine size. Refer to https://docs.microsoft.com/en-us/azure/virtual-machines/sizes "
}

variable "webhost_vm_hostname" {
  type        = string
  default     = "webhost"
  description = "Hostname of webhost virtual machine instance. Defaults to 'webhost'."
}

variable "webhost_vm_admin_username" {
  type        = string
  default     = "admin"
  description = "Admin login name for webhost virtual machine instance. Defaults to 'admin'."
}

variable "webhost_vm_admin_ssh_key_path" {
  type        = string
  description = "Local path of public SSH key for admin user log in."
}

variable "webhost_vm_image_publisher" {
  type        = string
  default     = "Canonical"
  description = "Webhost VM image publisher on Azure. Defaults to 'Canonical'"
}

variable "webhost_vm_image_offer" {
  type        = string
  default     = "UbuntuServer"
  description = "Webhost VM image offer on Azure. Defaults to 'UbuntuServer'"
}

variable "webhost_vm_image_sku" {
  type        = string
  default     = "16.04-LTS"
  description = "Webhost VM image SKU on Azure. Defaults to '16.04-LTS'"
}

variable "webhost_vm_image_version" {
  type        = string
  default     = "latest"
  description = "Webhost VM image version on Azure. Defaults to 'latest'"
}

# MySQL flexible server configuration. Used for website databases.
variable "mysql_server_sku" {
  type        = string
  default     = "B_Standard_B1s"
  description = "MySQL flexible server sku name. Refer to https://docs.microsoft.com/en-us/azure/mysql/flexible-server/concepts-service-tiers-storage "
}

variable "mysql_server_storage_size" {
  type        = number
  default     = 20
  description = "MySQL flexible server provisioned storage size (in GB). Minimum 20 GB."
}

variable "mysql_server_version" {
  type        = string
  default     = "5.7"
  description = "Version of MySQL to use. Possible values are '5.7' and '8.0.21'"
}

variable "mysql_server_backup_retention_length" {
  type        = number
  default     = 7
  description = "MySQL flexible server backup duration in days. Defaults to 7."
}

variable "mysql_server_admin_username" {
  type        = string
  default     = ""
  description = "MySQL flexible server admin username. If empty, one will be randomly generated."
}

variable "mysql_server_admin_password" {
  type        = string
  default     = ""
  sensitive   = true
  description = "MySQL flexible server admin user password. If empty, one will be randomly generated."
}

# Namecheap API configuration
variable "namecheap_user_name" {
  type        = string
  description = "Namecheap user account login name."
}

variable "namecheap_api_user" {
  type        = string
  description = "Namecheap API user account login name. Should correspond to user account login name."
}

variable "namecheap_api_key" {
  type        = string
  sensitive   = true
  description = "Namecheap secret API key."
}

# Ansible configuration variables
variable "ansible_inventory_template_path" {
  type        = string
  default     = ".\\ansible_inventory.tmpl"
  description = "Path to ansible inventory template file."
}

variable "ansible_inventory_output_path" {
  type        = string
  default     = ""
  description = "Path where to output ansible inventory file."
}