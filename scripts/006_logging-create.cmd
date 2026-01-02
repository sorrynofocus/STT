@echo off
:: This creates logging  and this was all the help with chat gippity.
:: Loggging was weak in learning for me. 

setlocal EnableExtensions EnableDelayedExpansion

echo Calling "%~dp0000_boot_env.cmd"
call "%~dp0000_boot_env.cmd" "%~1"
if errorlevel 1 exit /b 1

echo "============================================"
echo " Azure Cognitive Services Diagnostic Settings Logging Setup"
echo "============================================"

@REM The project is building:
@REM Speech - Intent - RAG - GPT pipeline
@REM AI Search indexing
@REM OpenAI response tracking
@REM Experimentation environment
@REM Debugging API rate limits & health

@REM Log Analytics Workspace (LAW)
@REM Full query language (Kusto / KQL)
@REM Unified dashboards
@REM Resource health
@REM Metrics history 
@REM Can funnel to: Sentinel, Alerts, Dashboards, Grafana
@REM Stores logs in a structured, queryable way

@REM What can you log from Cognitive Services?

@REM You can enable:
@REM Audit logs (who accessed what)
@REM Operational logs (throttling, failures)
@REM Request metrics
@REM Rate limits
@REM Billing-level usage
@REM Errors
@REM Resource Health
@REM Speech + Language + OpenAI + Search all support this.

:: Notes: 
:: Don’t try to enable logging at the resource group level. Azure doesn’t support cascading diagnostic settings.
:: Don’t mix production logs with experimentation if you expand later. You can create a second workspace with production-grade retention rules.

REM Step 1 - Create a Log Analytics Workspace (LAW)
echo "Creating logs for subscription: %AZ_SUBSCRIPTION%"
call az monitor log-analytics workspace create --resource-group %RG% --workspace-name %LAW% --location %LOCATION%    

:: Step 2 - Enable diagnostics settings on Cognitive Services resource

:: Cognitive services (Speech, Language, OpenAI Foundry) valid diagnostic categories
SET LOGS_COG=[{""category"":""Audit"",""enabled"":true},{""category"":""RequestResponse"",""enabled"":true}]
SET METRICS_COG=[]

:: Azure AI Search valid diagnostic categories (F0 only supports OperationLogs)
SET LOGS_SEARCH=[{""category"":""OperationLogs"",""enabled"":true}]
SET METRICS_SEARCH=[]

:: test - gather categories leave commented out
:: call az monitor diagnostic-settings categories list --resource "/subscriptions/%AZ_SUBSCRIPTION%/resourceGroups/%RG%/providers/Microsoft.CognitiveServices/accounts/%AZ_SPEECH_NAME%"

:: Speech
echo "Enabling diagnostic settings for Speech Service..."
call az monitor diagnostic-settings create --name speech-logs --resource "/subscriptions/%AZ_SUBSCRIPTION%/resourceGroups/%RG%/providers/Microsoft.CognitiveServices/accounts/%AZ_SPEECH_NAME%"  --workspace %LAW%   --logs "%LOGS_COG%" --metrics "%METRICS_COG%"

:: Language:
echo "Enabling diagnostic settings for Language Service..."
call az monitor diagnostic-settings create  --name lang-logs  --resource "/subscriptions/%AZ_SUBSCRIPTION%/resourceGroups/%RG%/providers/Microsoft.CognitiveServices/accounts/%AZ_LANGUAGE_NAME%"  --workspace %LAW%  --logs "%LOGS_COG%" --metrics "%METRICS_COG%"

:: OpenAI (Foundry)
echo "Enabling diagnostic settings for OpenAI Foundry Service..."
call az monitor diagnostic-settings create  --name openai-logs  --resource "/subscriptions/%AZ_SUBSCRIPTION%/resourceGroups/%RG%/providers/Microsoft.CognitiveServices/accounts/%RC_AZURE_OPENAI_NAME%"  --workspace %LAW%  --logs "%LOGS_COG%" --metrics "%METRICS_COG%"

  :: Azure AI Search
echo "Enabling diagnostic settings for Azure AI Search Service..."
call  az monitor diagnostic-settings create  --name search-logs  --resource "/subscriptions/%AZ_SUBSCRIPTION%/resourceGroups/%RG%/providers/Microsoft.Search/searchServices/%SEARCH_SERVICE%" --workspace %LAW%  --logs "%LOGS_SEARCH%" --metrics "%METRICS_SEARCH%"

:: Step 3 -Add retention policies (optional)
echo "Setting log retention policy to 30 days..."
call az monitor log-analytics workspace update  --resource-group %RG%  --workspace-name %LAW%  --retention-time %RETENTION_LOG_TIME%

echo "COMPLETED: Azure Cognitive Services Diagnostic Settings Logging Setup."
endlocal
exit /b 0



:: Step 4 - Query logs (example) KQL
:: Top API calls:
:: AzureDiagnostics
:: | where Category == "AllMetrics"
:: | summarize count() by Resource, OperationName

::Speech STT or TTS errors:
:: AzureDiagnostics
:: | where Resource == "rc-SpeechService-001"
:: | where Level == "Error"

:: Throttling detection (rate limits):
:: AzureDiagnostics
:: | AzureDiagnostics
:: | where Message has "429"

:: KQL for STT failures:
:: AzureDiagnostics
:: | where Resource == "rc-SpeechService-001"
:: | where OperationName contains "SpeechToText"
:: | where Level == "Error"
:: | summarize count() by bin(TimeGenerated, 5m)

:: Language Services Tiles (Intent Classification / KeyPhrase)
:: Track: Intent recognition success rate, KeyPhrase extraction volumes, PII detection failures
:: AzureDiagnostics
:: | where Resource == "rc-LanguageAnalysis"
:: | summarize CountByOperation = count() by OperationName, bin(TimeGenerated, 5m)


:: Azure OpneAI foundry tiles
:: Invocation count per model
:: Average token usage
:: Response latency
:: Errors (429 = rate limit, 500 = azure outage or model error)
:: AzureDiagnostics
:: | where Resource contains "AzureOpenAI"
:: | summarize Errors = count() by ResultType, bin(TimeGenerated, 5m)

:: Azure AI Search Tiles (for RAG Context)
:: AzureDiagnostics
:: | where Category == "OperationLogs"
:: | summarize count() by OperationName, bin(TimeGenerated, 5m)

:: End-to-End RAG Pipeline Metrics
:: AppTraces_CL
:: | summarize avg(DurationMs) by bin(TimeGenerated, 5m)

echo.
echo DONE!
echo Now - create dashboards in the Azure Portal using Log Analytics queries.
echo.
echo Go to Azure portal - Dashboard - New Dashboard
echo Add tiles using Metrics or Log Analytics
echo For each tile:
echo - Choose resource (Speech, Language, Search, OpenAI)
echo - Pick a metric OR write a KQL query
echo - Add visualization (line chart, bar, number)
echo - Resize and arrange tiles
echo - Save dashboard
echo.

@REM How to Build a Dashboard
@REM 1. Go to Azure Portal  to Dashboard
@REM 2. Click New Dashboard
@REM 3. Use Metrics or Log Analytics tiles
@REM 4. For each tile:

@REM - Choose resource (Speech, Language, Search, OpenAI)
@REM - Pick a metric OR write a KQL query

@REM - Add visualization (line chart, bar, number)

@REM - Resize and arrange tiles

@REM - Save dashboard

@REM Example Dashboard Layout for Your Project

@REM Row 1 - Speech Service
@REM STT Latency (line chart)
@REM STT Errors (bar)
@REM TTS Invocations (bar)
@REM Quota usage (number tile)

@REM Row 2 - Language Analysis
@REM Intent request count
@REM Intent failure rate
@REM KeyPhrase extraction latency

@REM Row 3 - Azure OpenAI
@REM Invocation count
@REM Token usage (input/output)
@REM GPT latency
@REM GPT 429 & 500 errors

@REM Row 4 - Azure AI Search
@REM Query latency
@REM Indexing failures
@REM RAG document retrieval count

@REM Row 5 - End-to-End Pipeline
@REM Total roundtrip latency
@REM Errors by pipeline stage

