resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"

  tags = var.tags
}

resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# Cosmos DB Account
resource "azurerm_cosmosdb_account" "cosmos" {
  name                = var.cosmos_account_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }

  tags = var.tags
}

resource "azurerm_cosmosdb_sql_database" "db" {
  name                = var.cosmos_database_name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_cosmosdb_sql_container" "container" {
  name                = var.cosmos_container_name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  database_name       = azurerm_cosmosdb_sql_database.db.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_key_path  = "/uploadId"
}

# App Service Plan (for Function App)
resource "azurerm_app_service_plan" "plan" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }

  tags = var.tags
}

resource "azurerm_storage_account" "function_storage" {
  name                     = var.function_storage_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

resource "azurerm_function_app" "func" {
  name                       = var.function_app_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key
  os_type                    = "linux"
  runtime_stack              = "python|3.9"
  version                    = "~4"

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"       = "python"
    "AzureWebJobsStorage"             = azurerm_storage_account.function_storage.primary_connection_string
    "STORAGE_ACCOUNT_CONNECTION"      = azurerm_storage_account.storage.primary_connection_string
    "COSMOS_DB_CONNECTION"            = azurerm_cosmosdb_account.cosmos.primary_sql_connection_string
    "COSMOS_DATABASE_NAME"            = azurerm_cosmosdb_sql_database.db.name
    "COSMOS_CONTAINER_NAME"           = azurerm_cosmosdb_sql_container.container.name
  }

  tags = var.tags

  depends_on = [
    azurerm_storage_account.function_storage
  ]
}

resource "azurerm_eventgrid_topic" "topic" {
  name                = var.event_grid_topic_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

resource "azurerm_eventgrid_event_subscription" "blob_to_function" {
  name              = "blob-upload-to-function"
  scope             = azurerm_storage_account.storage.id
  event_delivery_schema = "EventGridSchema"

  azure_function_endpoint {
    function_id = "${azurerm_function_app.func.id}/functions/BlobProcessor"
  }

  included_event_types = [
    "Microsoft.Storage.BlobCreated"
  ]

  subject_filter {
    subject_begins_with = "/blobServices/default/containers/${azurerm_storage_container.container.name}"
  }

  depends_on = [
    azurerm_function_app.func
  ]
}

resource "azurerm_key_vault" "vault" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get"
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set"
    ]
  }

  tags = var.tags
}

# Data source to get current Azure context
data "azurerm_client_config" "current" {}
