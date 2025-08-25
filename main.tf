
/////////////////////////////////////////////////////////////////
// Resource Group
/////////////////////////////////////////////////////////////////


resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}


/////////////////////////////////////////////////////////////////
// Key Vault
/////////////////////////////////////////////////////////////////

// AKV name
resource "random_string" "this" {
  length  = 12
  numeric = true
  lower   = true
  upper   = false
  special = false
}


// AKV
module "base_akv" {
  source                          = "git::git@github.com:schrieksoft/module-akv.git?ref=main"
  name                            = "snapcd-base-${random_string.this.result}"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.this.name
  tenant_id                       = var.tenant_id
  soft_delete_retention_days      = 7
  purge_protection_enabled        = false
  sku_name                        = "standard"
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false
  enable_rbac_authorization       = true
  administrator_object_ids        = [var.administrator_object_id]

  providers = {
    azurerm = azurerm.default
  }

}


/////////////////////////////////////////////////////////////////
// MSSQL Server
/////////////////////////////////////////////////////////////////


// Server name
resource "random_string" "mssql_server_name" {
  length  = 19
  numeric = true
  lower   = true
  upper   = false
  special = false
}


// Server
resource "azurerm_mssql_server" "this" {
  name                = "snapcd-${random_string.mssql_server_name.result}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  version             = "12.0"
  minimum_tls_version = "1.2"

  dynamic "azuread_administrator" {
    for_each = {
      "administrators" : var.administrator_object_id,
    }

    content {
      azuread_authentication_only = true
      login_username              = azuread_administrator.key
      object_id                   = azuread_administrator.value
    }
  }
}

# // Virtual Network Rule (Allow traffic from cluster)
# resource "azurerm_mssql_virtual_network_rule" "apps" {
#   name                                 = azurerm_mssql_server.this.name
#   server_id                            = azurerm_mssql_server.this.id
#   subnet_id                            = var.cluster_apps_subnet_id
#   ignore_missing_vnet_service_endpoint = false
# }

resource "azurerm_mssql_firewall_rule" "all_ips" {
  // count            = var.mssql_server_allow_all_ips ? 1 : 0
  name             = "${azurerm_mssql_server.this.name}-all"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}
