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

# Namecheap domain name details
variable "namecheap_domain_name" {
  type        = string
  description = "Domain name for which to update/set DNS records ('example.com'). Must be on Namecheap account for which API keys are provided for."
}

# Azure resource
variable "az_resource_group_name" {
  type        = string
  description = "Name of resource group where shared resources are deployed."
}

variable "az_webserver_public_ip" {
  type        = string
  description = "Name of web server public ip resource."
}

variable "az_key_vault_id" {
  type        = string
  description = "Name of key vault where secrets should be created."
}

variable "az_mysql_server_name" {
  type        = string
  description = "Name of MySQL flexible server instance where database should be created."
}

# Ansible variables
variable "ansible_vars_template_path" {
  type        = string
  default     = "ansible_variables.tftpl"
  description = "Path to Ansible variables configuration template file."
}

variable "ansible_vars_output_path" {
  type        = string
  default     = "ansible_variables.yml"
  description = "Path where to output Ansible variables file."
}

# Nginx configuration variables
variable "nginx_config_template_path" {
  type        = string
  default     = "nginx_configuration.tftpl"
  description = "Path to nginx configuration template file."
}

variable "nginx_config_output_path" {
  type        = string
  default     = "nginx_config"
  description = "Path where to output nginx configuration file."
}

# Wordpress configuration variables
variable "wordpress_config_template_path" {
  type        = string
  default     = "wordpress_configuration.tftpl"
  description = "Path to wordpress configuration template file."
}

variable "wordpress_config_output_path" {
  type        = string
  default     = "wordpress_config"
  description = "Path where to output wordpress configuration file."
}

# TLS certificate notifications email
variable "tls_cert_email" {
  type        = string
  description = "Email address where renewal reminders and other TLS certificate related notifications are sent."
}