#!/bin/bash

# Azure Serverless Event-Driven Platform
# Deployment Script

set -e

echo "=========================================="
echo "Azure Serverless Event-Driven Platform"
echo "Deployment Script"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
RESOURCE_GROUP="rg-serverless-dev"
LOCATION="eastus"
FUNCTION_NAME="BlobProcessor"

echo -e "${YELLOW}Step 1: Initializing Terraform${NC}"
cd terraform/
terraform init

echo ""
echo -e "${YELLOW}Step 2: Planning Deployment${NC}"
terraform plan -out=tfplan

echo ""
echo -e "${YELLOW}Step 3: Applying Configuration${NC}"
terraform apply tfplan

echo ""
echo -e "${GREEN}Infrastructure Deployed Successfully!${NC}"
echo ""

# Get outputs
STORAGE_ACCOUNT=$(terraform output -raw storage_account_name)
FUNCTION_APP=$(terraform output -raw function_app_name)
COSMOS_ACCOUNT=$(terraform output -raw cosmos_account_name)

echo "📊 Deployment Summary:"
echo "├── Storage Account: $STORAGE_ACCOUNT"
echo "├── Function App: $FUNCTION_APP"
echo "├── Cosmos Account: $COSMOS_ACCOUNT"
echo "└── Resource Group: $RESOURCE_GROUP"
echo ""

# Return to root directory
cd ..

echo -e "${YELLOW}Step 4: Creating Function Code Structure${NC}"
mkdir -p function-code/$FUNCTION_NAME

echo ""
echo -e "${YELLOW}Step 5: Deploying Function Code${NC}"
cd function-code/

# Create function.json
cat > $FUNCTION_NAME/function.json << 'EOF'
{
  "scriptFile": "blob_processor.py",
  "bindings": [
    {
      "name": "event",
      "type": "eventGridTrigger",
      "direction": "in"
    }
  ]
}
EOF

# Create blob_processor.py
cat > $FUNCTION_NAME/blob_processor.py << 'EOF'
import azure.functions as func
import json
import os
from datetime import datetime
from azure.cosmos import CosmosClient
from azure.storage.blob import BlobClient

def main(event: func.EventGridEvent):
    """
    Azure Function triggered by Event Grid
    Processes blob uploads and stores results in Cosmos DB
    """
    try:
        # Parse event
        result = json.loads(event.get_json())
        subject = result['subject']
        event_type = result['eventType']
        
        # Extract blob information
        blob_name = subject.split('/')[-1]
        storage_account = os.environ['STORAGE_ACCOUNT_CONNECTION']
        container_name = 'uploads'
        
        # Get blob content
        blob_url = f"https://{os.environ.get('STORAGE_ACCOUNT')}.blob.core.windows.net/{container_name}/{blob_name}"
        
        # Process the file
        file_size = get_blob_size(blob_url, storage_account)
        word_count = count_words_in_blob(blob_url, storage_account)
        
        # Prepare document for Cosmos DB
        doc = {
            'uploadId': blob_name,
            'fileName': blob_name,
            'fileSize': file_size,
            'wordCount': word_count,
            'timestamp': datetime.utcnow().isoformat(),
            'eventType': event_type,
            'status': 'Processed'
        }
        
        # Store in Cosmos DB
        store_to_cosmos(doc)
        
        return func.HttpResponse(
            json.dumps({
                'status': 'success',
                'message': f'File {blob_name} processed successfully',
                'data': doc
            }),
            status_code=200,
            mimetype='application/json'
        )
        
    except Exception as e:
        import traceback
        error_msg = f"Error processing blob: {str(e)}\n{traceback.format_exc()}"
        
        return func.HttpResponse(
            json.dumps({
                'status': 'error',
                'message': error_msg
            }),
            status_code=500,
            mimetype='application/json'
        )

def get_blob_size(blob_url, connection_string):
    """Get the size of the blob"""
    try:
        blob_client = BlobClient.from_connection_string(
            conn_str=connection_string,
            container_name='uploads',
            blob_name=blob_url.split('/')[-1]
        )
        properties = blob_client.get_blob_properties()
        return properties.size
    except:
        return 0

def count_words_in_blob(blob_url, connection_string):
    """Count words in blob content (for text files)"""
    try:
        blob_client = BlobClient.from_connection_string(
            conn_str=connection_string,
            container_name='uploads',
            blob_name=blob_url.split('/')[-1]
        )
        download_stream = blob_client.download_blob()
        content = download_stream.readall().decode('utf-8', errors='ignore')
        word_count = len(content.split())
        return word_count
    except:
        return 0

def store_to_cosmos(document):
    """Store document in Cosmos DB"""
    cosmos_connection = os.environ['COSMOS_DB_CONNECTION']
    database_name = os.environ['COSMOS_DATABASE_NAME']
    container_name = os.environ['COSMOS_CONTAINER_NAME']
    
    # Parse connection string
    client = CosmosClient.from_connection_string(cosmos_connection)
    database = client.get_database_client(database_name)
    container = database.get_container_client(container_name)
    
    # Create item
    container.create_item(body=document)
EOF

# Create requirements.txt
cat > $FUNCTION_NAME/requirements.txt << 'EOF'
azure-functions
azure-cosmos
azure-storage-blob
EOF

echo "✅ Function code created"
echo ""

echo -e "${YELLOW}Step 6: Deploying Function to Azure${NC}"
# Use Azure CLI to deploy function
FUNCTION_APP_NAME=$(cd ../terraform && terraform output -raw function_app_name)

func azure functionapp publish $FUNCTION_APP_NAME --python --build remote 2>/dev/null || echo "⚠️  Function deployment requires local Azure Functions Core Tools"

cd ..

echo ""
echo -e "${GREEN}=========================================="
echo "Deployment Complete!"
echo "==========================================${NC}"
echo ""
echo "📋 Next Steps:"
echo "  1. Go to Azure Portal → Function App"
echo "  2. Verify Event Grid subscription is active"
echo "  3. Upload test files to storage account"
echo "  4. Monitor function executions"
echo "  5. Check Cosmos DB for results"
echo ""
echo "🧪 Manual Function Deployment:"
echo "  cd function-code"
echo "  func azure functionapp publish $FUNCTION_APP_NAME --python --build remote"
echo ""
echo "📁 Test Upload:"
echo "  az storage blob upload \\"
echo "    --account-name $STORAGE_ACCOUNT \\"
echo "    --container-name uploads \\"
echo "    --name test.txt \\"
echo "    --file test.txt"
echo ""
