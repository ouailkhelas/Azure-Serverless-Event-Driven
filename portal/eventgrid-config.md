# Portal Configuration Guide

## Overview

This guide walks through configuring and testing the serverless event-driven platform using Azure Portal.

---

## Step 1: Verify Deployed Resources

### In Azure Portal:
1. Go to **Resource Groups** → **rg-serverless-dev**
2. Verify these resources exist:
   - Storage Account (stguploaddev)
   - Function App (func-blob-processor-dev)
   - Cosmos DB Account (cosmos-serverless-dev)
   - Event Grid Topic
   - Key Vault
   - App Service Plan

---

## Step 2: Configure Event Grid Subscription

1. Go to **Storage Account** → **Events**
2. Click **+ Event Subscription**
3. Configure:
   - **Name:** blob-upload-to-function
   - **Event Schema:** Event Grid Schema
   - **System Topics:** Enabled
   - **Filter to Event Types:** Blob Created

4. **Endpoint Details:**
   - **Endpoint Type:** Azure Function
   - **Function:** BlobProcessor
   - **Function App:** func-blob-processor-dev
   - Click **Select an endpoint**

5. **Delivery:**
   - **Max events per batch:** 1
   - **Preferred batch size:** 1

6. Click **Create**

### Verify Subscription:
1. Go to **Storage Account** → **Events**
2. View **Event Subscriptions** tab
3. Should show:
   - blob-upload-to-function: Succeeded

---

## Step 3: Upload Sample Files

### Via Azure Portal:

1. Go to **Storage Account** → **Containers**
2. Click **uploads** container
3. Click **Upload**
4. Select files:
   - sample-document.txt
   - sample-data.json
   - sample-data.csv
5. Click **Upload**

### Via Azure CLI (Cloud Shell):

```bash
# Create test files
echo "This is test content" > test.txt

# Upload
az storage blob upload \
  --account-name stguploaddev \
  --container-name uploads \
  --name test.txt \
  --file test.txt
```

✅ Files uploaded successfully

---

## Step 4: Monitor Function Execution

### View Function Logs:

1. Go to **Function App** → **BlobProcessor**
2. Click **Code + Test**
3. View **Logs** at bottom
4. Should see execution messages

**Expected Output:**
```
File sample-document.txt processed successfully
Status: Processed
WordCount: 45
FileSize: 234
```

### Monitor Metrics:

1. Go to **Function App** → **Monitor**
2. View:
   - **Invocations:** Should increase with each file upload
   - **Execution Count:** Track function runs
   - **Execution Time:** Check performance
   - **Failures:** Monitor errors

**Key Metrics:**
- Response Time: < 2 seconds
- Success Rate: 100%
- Invocation Count: Matches file uploads

---

## Step 5: View Results in Cosmos DB

### Access Data Explorer:

1. Go to **Cosmos DB Account** → **Data Explorer**
2. Expand **ProcessedData** database
3. Expand **FileProcessingResults** container
4. Click **Items**
5. View uploaded documents

## Quick Reference

| Task | Location |
|------|----------|
| Upload files | Storage Account → Containers → uploads |
| View logs | Function App → Code + Test → Logs |
| Check results | Cosmos DB → Data Explorer → Items |
| Monitor metrics | Function App → Monitor → Metrics |
| View events | Event Grid Topic → Events |
| Check configuration | Function App → Configuration → App settings |
