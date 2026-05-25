#!/bin/bash

# Test Blob Upload and Function Execution

set -e

echo "=========================================="
echo "Serverless Platform - Test Blob Upload"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
RESOURCE_GROUP="${1:-rg-serverless-dev}"
STORAGE_ACCOUNT="${2:-stguploaddev}"
FUNCTION_APP="${3:-func-blob-processor-dev}"
CONTAINER_NAME="uploads"

echo -e "${BLUE}Configuration:${NC}"
echo "├── Resource Group: $RESOURCE_GROUP"
echo "├── Storage Account: $STORAGE_ACCOUNT"
echo "├── Function App: $FUNCTION_APP"
echo "└── Container: $CONTAINER_NAME"
echo ""

# Step 1: Verify storage account exists
echo -e "${YELLOW}Step 1: Verifying Storage Account${NC}"
if az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    echo "✅ Storage account found"
else
    echo "❌ Storage account not found"
    exit 1
fi
echo ""

# Step 2: Get storage account key
echo -e "${YELLOW}Step 2: Getting Storage Account Key${NC}"
STORAGE_KEY=$(az storage account keys list \
  --account-name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --query "[0].value" -o tsv)
echo "✅ Storage key retrieved"
echo ""

# Step 3: Create test files
echo -e "${YELLOW}Step 3: Creating Test Files${NC}"
mkdir -p ./test-files

# Test 1: Text file
cat > ./test-files/sample-document.txt << 'EOF'
This is a sample document for testing the serverless event-driven platform.
It contains multiple lines of text that will be processed by the Azure Function.
The function will count words and calculate file size.
Event Grid will trigger the function automatically when this file is uploaded.
Azure Cosmos DB will store the processing results.
EOF
echo "✅ Created sample-document.txt"

# Test 2: JSON file
cat > ./test-files/sample-data.json << 'EOF'
{
  "name": "Test Data",
  "description": "Sample JSON file for testing serverless platform",
  "items": [
    {"id": 1, "value": "Item 1"},
    {"id": 2, "value": "Item 2"},
    {"id": 3, "value": "Item 3"}
  ]
}
EOF
echo "✅ Created sample-data.json"

# Test 3: CSV file
cat > ./test-files/sample-data.csv << 'EOF'
Name,Email,Department
John Doe,john@example.com,Engineering
Jane Smith,jane@example.com,Sales
Bob Johnson,bob@example.com,Marketing
EOF
echo "✅ Created sample-data.csv"
echo ""

# Step 4: Upload test files
echo -e "${YELLOW}Step 4: Uploading Test Files${NC}"
for file in ./test-files/*; do
    filename=$(basename "$file")
    echo "Uploading: $filename"
    az storage blob upload \
      --account-name "$STORAGE_ACCOUNT" \
      --account-key "$STORAGE_KEY" \
      --container-name "$CONTAINER_NAME" \
      --name "$filename" \
      --file "$file" \
      --overwrite
    echo "✅ Uploaded: $filename"
done
echo ""

# Step 5: Monitor function execution
echo -e "${YELLOW}Step 5: Monitoring Function Execution${NC}"
echo "⏳ Waiting for function to process files (30 seconds)..."
sleep 30

# Step 6: Check function logs
echo -e "${YELLOW}Step 6: Checking Function Logs${NC}"
echo "Retrieving recent function invocations..."
az functionapp log tail \
  --name "$FUNCTION_APP" \
  --resource-group "$RESOURCE_GROUP" \
  --provider-filter "Provider=Function" \
  --max-lines 20 || echo "⚠️  Use Azure Portal to view detailed logs"
echo ""

# Step 7: List uploaded blobs
echo -e "${YELLOW}Step 7: Verifying Uploaded Files${NC}"
echo "Files in storage account:"
az storage blob list \
  --account-name "$STORAGE_ACCOUNT" \
  --account-key "$STORAGE_KEY" \
  --container-name "$CONTAINER_NAME" \
  --output table
echo ""

# Step 8: Check Cosmos DB results
echo -e "${YELLOW}Step 8: Checking Cosmos DB Results${NC}"
echo "Retrieving storage account connection string..."
COSMOS_ACCOUNT=$(az deployment group show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$(az deployment group list --resource-group "$RESOURCE_GROUP" --query '[0].name' -o tsv)" \
  --query "properties.outputs.cosmos_account_name.value" -o tsv 2>/dev/null || echo "cosmos-serverless-dev")

echo "Cosmos DB Account: $COSMOS_ACCOUNT"
echo "To view results in Cosmos DB:"
echo "  1. Go to Azure Portal"
echo "  2. Open Cosmos DB Account: $COSMOS_ACCOUNT"
echo "  3. Navigate to Data Explorer"
echo "  4. Open ProcessedData → FileProcessingResults"
echo "  5. View items in the container"
echo ""

echo -e "${GREEN}=========================================="
echo "Test Upload Complete!"
echo "==========================================${NC}"
echo ""
echo "📊 Summary:"
echo "├── 3 test files uploaded"
echo "├── Function triggered automatically"
echo "├── Results stored in Cosmos DB"
echo "└── Check Portal to verify"
echo ""
echo "🔍 View Results:"
echo "  Portal → Cosmos DB → Data Explorer → ProcessedData → FileProcessingResults"
echo ""
