output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.storage.name
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.storage.id
}

output "container_name" {
  description = "Name of the blob container"
  value       = azurerm_storage_container.container.name
}

output "function_app_name" {
  description = "Name of the Function App"
  value       = azurerm_function_app.func.name
}

output "function_app_id" {
  description = "ID of the Function App"
  value       = azurerm_function_app.func.id
}

output "cosmos_account_name" {
  description = "Name of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.cosmos.name
}

output "cosmos_database_name" {
  description = "Name of the Cosmos DB database"
  value       = azurerm_cosmosdb_sql_database.db.name
}

output "cosmos_container_name" {
  description = "Name of the Cosmos DB container"
  value       = azurerm_cosmosdb_sql_container.container.name
}

output "event_grid_topic_name" {
  description = "Name of the Event Grid Topic"
  value       = azurerm_eventgrid_topic.topic.name
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.vault.name
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}
