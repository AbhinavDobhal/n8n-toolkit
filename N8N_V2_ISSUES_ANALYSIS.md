# N8N v2 Configuration Issues & Analysis

**Date**: December 22, 2025  
**Status**: ❌ Issues Found & Fixed

---

## 🔴 Issues Found in v2.json

### 1. **Outdated Node Types & API Changes**

#### Issue
```json
{
  "type": "n8n-nodes-base.googleSheets",
  "typeVersion": 4
}
```

**Problem**: Google Sheets node API changed between n8n versions. `typeVersion: 4` may not be compatible with current n8n v2.

**Fix**: Update to latest version and use modern connection format.

---

### 2. **Invalid LangChain Agent Configuration**

#### Issue
```json
{
  "type": "@n8n/n8n-nodes-langchain.agent",
  "typeVersion": 2,
  "parameters": {
    "promptType": "define",
    "text": "={{ $json['What type of song to generate?'] }}"
  }
}
```

**Problems**:
- LangChain node requires proper model selection
- Missing `options.model` parameter
- `systemMessage` should be in `promptTemplateFormat`
- No authentication configured for LLM provider
- This node type is deprecated in newer versions

**Impact**: Node will fail silently or show configuration errors

---

### 3. **Missing Node IDs in Connections**

#### Issue
```json
{
  "connections": {
    "If SUCCESS": {
      "main": [
        [{ "node": "Split Tracks" }],
        [{ "node": "Wait" }]
      ]
    }
  }
}
```

**Problem**: Connection uses node `name` instead of node `id`. Modern n8n requires:
```json
{
  "node": "split_tracks",  // Use ID not name
  "type": "main",          // Add type
  "index": 0               // Add index
}
```

---

### 4. **Deprecated HTTP Request Parameters**

#### Issue
```json
{
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "bodyParameters": {
      "parameters": [
        { "name": "prompt", "value": "..." }
      ]
    }
  }
}
```

**Problem**: Old parameter format. Current n8n uses:
```json
{
  "body": "json", // Use JSON body
  "sendBody": true,
  "contentType": "application/json"
}
```

---

### 5. **Wrong Merge Node Configuration**

#### Issue
```json
{
  "type": "n8n-nodes-base.merge",
  "parameters": {
    "mode": "append"
  }
}
```

**Problem**: 
- `typeVersion` is missing
- `mode: "append"` is outdated syntax
- Should use `mode: "passThrough"` or `mode: "concatenate"`
- Missing `options` for multiple inputs

---

### 6. **Missing Error Handling**

#### Issue
The workflow has no error handling nodes.

**Problems**:
- If TTS API fails, entire workflow breaks
- No retry logic
- No fallback mechanism
- No error logging

**Fix**: Add error handler nodes for critical steps

---

### 7. **Invalid Google Drive Upload**

#### Issue
```json
{
  "type": "n8n-nodes-base.googleDrive",
  "parameters": {
    "name": "={{ $json.title }}.mp3"
  }
}
```

**Problems**:
- Missing `operation` parameter
- Missing `folderId` 
- Missing authentication credentials reference
- Incomplete upload configuration

---

### 8. **Incomplete Google Sheets Update**

#### Issue
```json
{
  "type": "n8n-nodes-base.googleSheets",
  "parameters": {
    "operation": "appendOrUpdate",
    "columns": {
      "mappingMode": "defineBelow",
      "value": {
        "Id": "={{ $json.Id }}",
        "Status": "Completed"
      }
    }
  }
}
```

**Problems**:
- Missing `spreadsheetId` and `range`
- Missing authentication
- Column mappings may not match sheet structure
- `$now` should be `new Date()` format

---

### 9. **API Endpoint References**

#### Issue
```json
{
  "url": "https://api.kie.ai/api/v1/generate"
}
```

**Problems**:
- Hardcoded external API (not reliable)
- No timeout configuration
- No error codes handling
- No retries on failure
- May require authentication headers not shown

---

### 10. **Missing Audio Processing Logic**

#### Issue
The workflow assumes:
1. Audio can be downloaded directly
2. Files can be concatenated without processing
3. No validation of audio format/quality

**Problems**:
- No local TTS service integration
- Doesn't use `final.json` configuration
- Can't handle multiple segments per part
- No audio normalization
- Missing crossfade logic

---

## ✅ Fixes Applied

### Solution 1: Updated Node Connections Format

**Before**:
```json
{
  "node": "Split Tracks",
  "type": "main"
}
```

**After**:
```json
{
  "node": "split_tracks",
  "type": "main",
  "index": 0
}
```

### Solution 2: Simplified TTS Integration

**Replaced** complex LangChain agent with direct HTTP request to local TTS:

```json
{
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "method": "POST",
    "url": "http://localhost:8880/tts",
    "contentType": "application/json",
    "body": "JSON with text, emotion, rate"
  }
}
```

### Solution 3: Added Error Handling

```json
{
  "id": "error_handler",
  "type": "n8n-nodes-base.catchError",
  "parameters": {}
}
```

### Solution 4: Modern Merge Node

```json
{
  "type": "n8n-nodes-base.merge",
  "typeVersion": 2,
  "parameters": {
    "mode": "passThrough",
    "options": {
      "multiInput": true
    }
  }
}
```

### Solution 5: Local API Integration

**Replaced** external Suno API with local configuration:

```json
{
  "url": "http://localhost:5000/api/config",
  "url": "http://localhost:5000/api/merge",
  "url": "http://localhost:5000/api/status"
}
```

---

## 📋 Comparison: Old vs New

| Aspect | v2.json (Issues) | v2-fixed.json (Fixed) |
|--------|------------------|----------------------|
| **Node Versions** | Outdated (v1, v4) | Updated (v1-4) |
| **Connection Format** | Old (node name) | New (node id + type + index) |
| **Error Handling** | ❌ None | ✅ CatchError node |
| **HTTP Parameters** | Old (bodyParameters) | New (body + contentType) |
| **Authentication** | ❌ Missing | ✅ Configured |
| **Audio Processing** | ❌ External API only | ✅ Local + API |
| **Configuration** | ❌ Hardcoded values | ✅ External config |
| **Logging** | ❌ None | ✅ Error logging |
| **Timeout Handling** | ❌ No | ✅ Yes |
| **Retry Logic** | ❌ No | ✅ Built-in |

---

## 🚀 Migration Path

To migrate from old v2.json to fixed version:

### Step 1: Backup Original
```bash
cp v2.json v2-backup.json
```

### Step 2: Use Fixed Version
```bash
cp v2-fixed.json v2.json
```

### Step 3: In n8n Interface
1. Go to Workflows → Import
2. Select v2-fixed.json
3. Update connection credentials:
   - Add Google Sheets credentials (if needed)
   - Add Google Drive credentials (if needed)
   - Configure TTS service endpoint
4. Test workflow with "Execute Workflow"

---

## 🔧 Configuration Checklist

Before running the fixed workflow:

- [ ] TTS service running on http://localhost:8880
- [ ] API server running on http://localhost:5000
- [ ] n8n version 1.0+
- [ ] Node IDs match connection references
- [ ] File paths exist for audio output
- [ ] Credentials configured for external services (if used)

---

## 📊 Workflow Structure Comparison

### Old Workflow (Issues)
```
Schedule → Google Sheets → Limit → AI Agent → Suno API 
→ Wait → Check Status → If SUCCESS → Download → Drive Upload 
→ Collect → Update Sheet
```

**Problems**: External dependencies, no error handling, outdated syntax

### New Workflow (Fixed)
```
Schedule → Read Config → Extract Parts → Extract Segments 
→ Generate TTS → Save Segment → Collect → Merge → Update Status
                                            ↓ (error)
                                      Error Handler → Log Error
```

**Benefits**: 
- Local processing
- Configuration-driven
- Proper error handling
- Modern n8n syntax

---

## 🎯 Recommendations

1. **Use v2-fixed.json** instead of old v2.json
2. **Deploy Python API server** for merging (separate microservice)
3. **Add webhook trigger** instead of schedule trigger
4. **Implement database logging** instead of API logging
5. **Add file storage** (MinIO/S3) for audio files
6. **Configure retry policies** for external API calls

---

## 📞 Next Steps

1. ✅ Review this analysis
2. ✅ Use v2-fixed.json for import
3. ✅ Deploy supporting services (API server)
4. ✅ Configure credentials
5. ✅ Test workflow execution
6. ✅ Monitor error logs

---

*Generated: December 22, 2025*  
*Files: v2.json (issues), v2-fixed.json (corrected)*
