# Azure Serverless Platform Configuration

resource_group_name = "rg-serverless-dev"
location             = "eastus"

# Storage Configuration
storage_account_name  = "stguploaddev"
function_storage_name = "stgfuncdev"
container_name        = "uploads"

# Cosmos DB Configuration
cosmos_account_name   = "cosmos-serverless-dev"
cosmos_database_name  = "ProcessedData"
cosmos_container_name = "FileProcessingResults"

# Function App Configuration
function_app_name        = "func-blob-processor-dev"
app_service_plan_name    = "plan-serverless-dev"
event_grid_topic_name    = "eventgrid-topic-dev"
key_vault_name           = "kv-serverless-dev"

# Tags
tags = {
  Environment = "Development"
  Project     = "Serverless-Platform"
  Owner       = "DevTeam"
  CostCenter  = "Engineering"
}
