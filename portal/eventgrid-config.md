# Azure Serverless Event-Driven Platform
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

✅ All resources should show "Succeeded" status

---

## Step 2: Configure Event Grid Subscription

### Create Subscription (If Not Auto-Created):

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

### Example Document Structure:
```json
{
  "id": "sample-document.txt",
  "uploadId": "sample-document.txt",
  "fileName": "sample-document.txt",
  "fileSize": 234,
  "wordCount": 45,
  "timestamp": "2024-05-24T12:30:00",
  "eventType": "Microsoft.Storage.BlobCreated",
  "status": "Processed"
}
```

### Query Results:
```sql
SELECT * FROM c WHERE c.status = "Processed"
SELECT AVG(c.fileSize) as AvgSize FROM c
SELECT COUNT(*) FROM c
```

---

## Step 6: Test End-to-End Flow

### Manual Test:

1. **Upload File:**
   - Go to Storage Account → Containers → uploads
   - Upload a new file

2. **Wait for Processing:**
   - Event Grid receives upload event (instant)
   - Function triggered automatically (~2 seconds)
   - Function processes file and stores result

3. **Verify Result:**
   - Go to Cosmos DB → Data Explorer → FileProcessingResults
   - New item appears with processing details
   - timestamp shows recent time
   - status shows "Processed"

**Expected Timeline:**
```
0s   → File upload completes
0.5s → Event Grid detects event
1s   → Function starts execution
2s   → Function completes, stores in Cosmos DB
2.5s → Data visible in Cosmos DB
```

---

## Step 7: Monitor Event Grid Activity

### View Event Grid Metrics:

1. Go to **Event Grid Topic** (if exists)
2. Click **Metrics**
3. Monitor:
   - **Published Events:** Total events published
   - **Matched Events:** Events matched subscription
   - **Unmatched Events:** Events not matched
   - **Delivery Attempts:** Number of delivery tries

### Check Subscription Health:

1. Go to **Storage Account** → **Events**
2. Click subscription name
3. View:
   - **Last Active:** When last processed
   - **Delivery Status:** Success/Failed
   - **Dead Letter Events:** Failed deliveries

---

## Step 8: View Application Insights (Optional)

### Enable Monitoring:

1. Go to **Function App** → **Application Insights**
2. Click **Enable Application Insights**
3. Select or create **Application Insights** resource

### View Traces:

1. Go to **Application Insights** resource
2. Click **Live Metrics Stream**
3. See real-time:
   - Function invocations
   - Response times
   - Exceptions
   - Dependencies

---

## Step 9: Troubleshooting

### Function Not Triggering:

**Issue:** Files uploaded but function doesn't execute

**Solution:**
1. Check Event Grid subscription status:
   - Go to **Storage Account** → **Events**
   - Verify subscription shows "Enabled"

2. Check Function App status:
   - Go to **Function App**
   - View **Essentials**
   - Status should be "Running"

3. View function logs:
   - Go to **Function App** → **Log Stream**
   - Check for errors

### Function Failing:

**Issue:** Function executes but shows errors in logs

**Solution:**
1. Check connection strings:
   - Go to **Function App** → **Configuration**
   - Verify all settings exist:
     - STORAGE_ACCOUNT_CONNECTION
     - COSMOS_DB_CONNECTION
     - COSMOS_DATABASE_NAME
     - COSMOS_CONTAINER_NAME

2. Check permissions:
   - Storage Account: Function needs read access
   - Cosmos DB: Function needs write access

3. View detailed logs:
   - Go to **Function App** → **Code + Test**
   - Click **Logs** tab
   - Look for error messages

### Cosmos DB Not Updated:

**Issue:** Function runs but no data in Cosmos DB

**Solution:**
1. Verify connection string:
   - Go to **Cosmos DB** → **Keys**
   - Check **Primary SQL Connection String**
   - Ensure it's in Function settings

2. Check container permissions:
   - Go to **Cosmos DB** → **Data Explorer**
   - Expand **ProcessedData** → **FileProcessingResults**
   - Click **Items** - should be empty initially

3. Manually test Cosmos DB:
   - Use Data Explorer to create item manually
   - If successful, issue is with function logic

---

## Step 10: Performance Testing

### Stress Test with Multiple Uploads:

1. **Upload Multiple Files:**
   - Upload 10-20 files in succession
   - Monitor function response

2. **Check Performance Metrics:**
   - Go to **Function App** → **Monitor**
   - View execution counts
   - Check response times
   - Monitor success/failure rates

3. **Expected Results:**
   - Each file processes in 1-3 seconds
   - Success rate: >99%
   - No errors in logs

### Load Testing Recommendations:
- **Light:** 1-5 files/minute
- **Medium:** 10-30 files/minute
- **Heavy:** 50+ files/minute

---

## Step 11: View Cost Analysis

### Check Resource Costs:

1. Go to **Resource Group** → **Cost Analysis**
2. View spending by resource:
   - **Storage Account:** Pay per GB stored
   - **Function App:** Pay per execution (free tier: 1M/month)
   - **Cosmos DB:** Pay per RU provisioned
   - **Event Grid:** Pay per million operations

### Cost Optimization:
- **Storage:** Delete old blobs regularly
- **Functions:** Optimize execution time
- **Cosmos DB:** Use serverless billing
- **Event Grid:** Archive long-term events

---

## Step 12: Clean Up Resources

### Delete Everything:

⚠️ **WARNING:** This permanently removes all resources

1. Go to **Resource Groups**
2. Find **rg-serverless-dev**
3. Click **Delete resource group**
4. Confirm deletion

### Delete Specific Resources:

**Keep infrastructure, delete data:**

1. Go to **Storage Account** → **Containers** → **uploads**
2. Delete all blobs
3. Go to **Cosmos DB** → **Data Explorer**
4. Delete all items in **FileProcessingResults**

---

## Quick Reference

| Task | Location |
|------|----------|
| Upload files | Storage Account → Containers → uploads |
| View logs | Function App → Code + Test → Logs |
| Check results | Cosmos DB → Data Explorer → Items |
| Monitor metrics | Function App → Monitor → Metrics |
| View events | Event Grid Topic → Events |
| Check configuration | Function App → Configuration → App settings |

---

## Summary

✅ Infrastructure deployed and configured
✅ Event Grid subscription active
✅ Function triggered on file upload
✅ Results stored in Cosmos DB
✅ Monitoring and logging working

**Your serverless platform is ready to use!**
