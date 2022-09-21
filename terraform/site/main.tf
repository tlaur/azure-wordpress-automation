terraform {
  required_version = ">= 1.2.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.13.0"
    }
    namecheap = {
      source  = "namecheap/namecheap"
      version = ">= 2.1.0"
    }
  }
}

data "azurerm_mysql_flexible_server" "wpdbserver" {
  name                = var.az_mysql_server_name
  resource_group_name = var.az_resource_group_name
}

resource "namecheap_domain_records" "records" {
  domain     = var.namecheap_domain_name
  mode       = "OVERWRITE"
  email_type = "NONE"

  record {
    hostname = "www"
    type     = "A"
    address  = var.az_webserver_public_ip
    ttl      = 60
  }

  record {
    hostname = "@"
    type     = "ALIAS"
    address  = "www.${var.namecheap_domain_name}"
    ttl      = 60
  }
}

resource "azurerm_mysql_flexible_database" "db" {
  name                = split(".", var.namecheap_domain_name)[0]
  resource_group_name = var.az_resource_group_name
  server_name         = var.az_mysql_server_name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

resource "azurerm_key_vault_secret" "mysql_db_admin_name" {
  name         = "mysql-db-${split(".", var.namecheap_domain_name)[0]}-admin-username"
  value        = random_pet.mysql_db_admin_username.id
  key_vault_id = var.az_key_vault_id
}

resource "azurerm_key_vault_secret" "mysql_db_admin_pass" {
  name         = "mysql-db-${split(".", var.namecheap_domain_name)[0]}-admin-password"
  value        = random_password.mysql_db_admin_password.result
  key_vault_id = var.az_key_vault_id
}

resource "random_pet" "mysql_db_admin_username" {
  length    = 2
  separator = "_"
}

resource "random_password" "mysql_db_admin_password" {
  length      = 16
  special     = true
  min_lower   = 2
  min_upper   = 2
  min_numeric = 2
  min_special = 2
}

# Ansible configuration file
resource "local_file" "ansible_variables_file" {
  filename = var.ansible_vars_output_path
  content = templatefile(var.ansible_vars_template_path,
    {
      site_url                 = var.namecheap_domain_name
      site_db_name             = azurerm_mysql_flexible_database.db.name
      site_db_admin_name       = random_pet.mysql_db_admin_username.id
      site_db_admin_pass       = random_password.mysql_db_admin_password.result
      cert_notifications_email = var.tls_cert_email
    }
  )
}

# Nginx configuration file
resource "local_file" "nginx_configuration_file" {
  filename = var.nginx_config_output_path
  content = templatefile(var.nginx_config_template_path,
    {
      domain_name = var.namecheap_domain_name
    }
  )
}

# WordPress configuration file and salts
resource "local_file" "wordpress_configuration_file" {
  filename = var.wordpress_config_output_path
  content = templatefile(var.wordpress_config_template_path,
    {
      db_name             = azurerm_mysql_flexible_database.db.name
      db_user             = random_pet.mysql_db_admin_username.id
      db_password         = random_password.mysql_db_admin_password.result
      db_host             = data.azurerm_mysql_flexible_server.wpdbserver.fqdn
      wp_auth_key         = random_password.wp_salts["auth_key"].result
      wp_secure_auth_key  = random_password.wp_salts["secure_auth_key"].result
      wp_logged_in_key    = random_password.wp_salts["logged_in_key"].result
      wp_nonce_key        = random_password.wp_salts["nonce_key"].result
      wp_auth_salt        = random_password.wp_salts["auth_salt"].result
      wp_secure_auth_salt = random_password.wp_salts["secure_auth_salt"].result
      wp_logged_in_salt   = random_password.wp_salts["logged_in_salt"].result
      wp_nonce_salt       = random_password.wp_salts["nonce_salt"].result
    }
  )
}

resource "random_password" "wp_salts" {
  for_each = toset(
    ["auth_key", "secure_auth_key", "logged_in_key",
      "nonce_key", "auth_salt", "secure_auth_salt",
    "logged_in_salt", "nonce_salt"]
  )
  length      = 64
  special     = true
  min_lower   = 12
  min_upper   = 12
  min_numeric = 12
  min_special = 12
}