resource_group_name = "rg-serverless-dev"
location             = "eastus"

storage_account_name  = "stguploaddev"
function_storage_name = "stgfuncdev"
container_name        = "uploads"

cosmos_account_name   = "cosmos-serverless-dev"
cosmos_database_name  = "ProcessedData"
cosmos_container_name = "FileProcessingResults"

function_app_name        = "func-blob-processor-dev"
app_service_plan_name    = "plan-serverless-dev"
event_grid_topic_name    = "eventgrid-topic-dev"
key_vault_name           = "kv-serverless-dev"

tags = {
  Environment = "Development"
  Project     = "Serverless-Platform"
  Owner       = "DevTeam"
  CostCenter  = "Engineering"
}
