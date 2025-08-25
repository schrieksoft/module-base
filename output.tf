output "resource_group_name" {
  value = var.resource_group_name
}

output "location" {
  value = var.location
}

output "resource_group_id" {
  value = azurerm_resource_group.this.id
}

output "base_akv_id" {
  value = module.base_akv.id
}

output "base_akv_name" {
  value = module.base_akv.name
}

output "base_akv_url" {
  value = module.base_akv.vault_uri
}

output "mssql_server_fully_qualified_domain_name" {
  value = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "mssql_server_id" {
  value = azurerm_mssql_server.this.id
}
