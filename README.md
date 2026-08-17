# Azure Serverless Event-Driven Platform

A lightweight, easy-to-understand project demonstrating a serverless event-driven architecture using Azure services.

## 🚀 Architecture Overview

```
User Upload File
       │
       ▼
┌─────────────────┐
│  Azure Blob     │  (File Storage)
│  Storage        │
└────────┬────────┘
         │ (BlobCreated Event)
         ▼
┌─────────────────┐
│  Event Grid     │  (Event Router)
│  (Detects)      │
└────────┬────────┘
         │ (Triggers Function)
         ▼
┌─────────────────┐
│  Azure Function │  (Serverless Compute)
│  (Processes)    │
└────────┬────────┘
         │ (Store Results)
         ▼
┌─────────────────┐
│  Cosmos DB      │  (NoSQL Database)
│  (Results)      │
└─────────────────┘
```

## ✅ Data Flow

1. **Upload:** User uploads file to Azure Blob Storage
2. **Detect:** Event Grid detects BlobCreated event (instant)
3. **Process:** Azure Function automatically triggered
4. **Store:** Function processes file and stores result in Cosmos DB
5. **Query:** User queries Cosmos DB for processing results

## ✅ Key Concepts

| Component | Purpose | Why? |
|-----------|---------|------|
| **Blob Storage** | File storage | Scalable, cheap file storage |
| **Event Grid** | Event routing | Real-time event detection |
| **Azure Functions** | Serverless compute | No servers to manage, pay per execution |
| **Cosmos DB** | NoSQL database | Flexible schema, automatic scaling |


## ✅ Quick Start

### Step 1: Deploy Infrastructure
```bash
cd cloudshell/
bash deploy.sh
```

Creates:
- Storage Account
- Function App 
- Cosmos DB
- Event Grid 
- App Service Plan
- Key Vault

### Step 2: Configure Portal
Follow `portal/eventgrid-config.md`:
- Verify Event Grid subscription
- Check Function App settings
- View Cosmos DB structure

### Step 3: Test Platform
```bash
bash cloudshell/test-upload.sh
```

Uploads sample files and monitors execution.

### Step 4: Verify Results
1. Go to **Cosmos DB** → **Data Explorer**
2. Open **ProcessedData** → **FileProcessingResults**
3. View processing results

## ✅ What the Function Does

The Azure Function (`BlobProcessor`) performs these tasks:

```python
1. Receive Event Grid event about new file upload
2. Extract blob name from event
3. Read file content from storage
4. Calculate:
   - File size (bytes)
   - Word count (for text files)
   - Upload timestamp
5. Store document in Cosmos DB with:
   {
     "uploadId": "filename",
     "fileName": "filename",
     "fileSize": 1234,
     "wordCount": 567,
     "timestamp": "2024-05-24T12:00:00",
     "status": "Processed"
   }
6. Return success/error response
```
## Testing Scenarios

### Scenario 1: Single File Upload
```
Upload text file → Event triggered → Function processes → Result in Cosmos DB
Expected: Document with word count and file size
```

### Scenario 2: Batch Upload
```
Upload 5 files → Multiple events → 5 functions run in parallel → 5 results stored
Expected: Each file processed independently
```

### Scenario 3: Large File
```
Upload 10MB file → Event triggered → Function processes → Result in Cosmos DB
Expected: File size recorded, processing time noted
``
