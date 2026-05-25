variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-serverless-platform"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "storage_account_name" {
  description = "Name of the storage account for file uploads"
  type        = string
  default     = "stgupload"
}

variable "function_storage_name" {
  description = "Name of the storage account for function app"
  type        = string
  default     = "stgfuncapp"
}

variable "container_name" {
  description = "Name of the blob container"
  type        = string
  default     = "uploads"
}

variable "cosmos_account_name" {
  description = "Name of the Cosmos DB account"
  type        = string
  default     = "cosmos-serverless"
}

variable "cosmos_database_name" {
  description = "Name of the Cosmos DB database"
  type        = string
  default     = "ProcessedData"
}

variable "cosmos_container_name" {
  description = "Name of the Cosmos DB container"
  type        = string
  default     = "FileProcessingResults"
}

variable "function_app_name" {
  description = "Name of the Azure Function App"
  type        = string
  default     = "func-blob-processor"
}

variable "app_service_plan_name" {
  description = "Name of the App Service Plan"
  type        = string
  default     = "plan-serverless"
}

variable "event_grid_topic_name" {
  description = "Name of the Event Grid Topic"
  type        = string
  default     = "eventgrid-topic"
}

variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
  default     = "kv-serverless"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "Dev"
    Project     = "Serverless"
    Owner       = "DevTeam"
  }
}
