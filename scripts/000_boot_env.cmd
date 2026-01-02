@echo off
::  ============================
::  Azure services Environment Variables
::  Windows CMD only
::  ============================
echo BOOT FILE: [%~f0]

REM Make Azure CLI non-interactive
set "AZURE_EXTENSION_USE_DYNAMIC_INSTALL=yes_without_prompt"
set "AZURE_CORE_NO_COLOR=true"
REM Disable interactive prompts
set "AZURE_CORE_DISABLE_INTERACTIVE_PROMPTS=1"


::  Check to see if passed in subscription ID, if not then AZ_SUBSCRIPTION must be set in environment. If both are null, fail and bail.
if not "%~1"=="" (
    set "AZ_SUBSCRIPTION=%~1"
) else if not "%AZ_SUBSCRIPTION%"=="" (
	echo Using existing AZ_SUBSCRIPTION environment variable
) else (
    echo ERROR: You must provide a subscription ID as a parameter or set AZ_SUBSCRIPTION in the environment
    exit /b 1
)

echo "Using subscription ID: %AZ_SUBSCRIPTION%"

call az account set --subscription "%AZ_SUBSCRIPTION%" --only-show-errors
if errorlevel 1 (
  echo "ERROR: Could not set subscription %AZ_SUBSCRIPTION%"
  exit /b 1
)

echo "============================"
echo "Boot loaded for subscription %AZ_SUBSCRIPTION%"
echo "============================"

::  Azure specifics
set "LOCATION=westus"

::  Core resource group
set "RG=rc_Group_001"

::  Speech STT TTS
set "AZ_SPEECH_NAME=rc-SpeechService-001"
set "RC_SPEECH_SERVICE_REGION=westus"
set "RC_SPEECH_SERVICE_ENDPOINT=https://westus.api.cognitive.microsoft.com/"
set "COST_CENTER=8r0K3-422"
REM 8r0K3-422 = BRoke Ass in l33t speak. ^_^
set "RC_SPEECH_SERVICE_KIND=SpeechServices"
@REM echo ===== boot snippet =====
@REM findstr /n /c:"RC_SPEECH_SERVICE_KIND" "%~f0"
@REM echo ========================
@REM echo DEBUG: after set, RC_SPEECH_SERVICE_KIND=[%RC_SPEECH_SERVICE_KIND%]
set "RC_SPEECH_SERVICE_SKU=F0"

::  Language Text Analytics
set "AZ_LANGUAGE_NAME=rc-LanguageAnalysis"
set "RC_LANG_ANALYSIS_SERVICE_REGION=westus"
set "LANG_SERVICE_KIND=TextAnalytics"
set "LANG_SERVICE_SKU=F0"


::  Foundry  OpenAI Project 
set "RC_AZURE_OPENAI_NAME=rc-azureopenai-foundry-002"
set "RC_AZURE_OPENAI_SERVICE_KIND=AIServices"
set "RC_AZURE_OPENAI_SERVICE_SKU=S0"
set "PROJECT_NAME=stt-demo1"
::  connection name in foundry project to resource RC_AZURE_OPENAI_NAME
set "CONNECTION_NAME=stt-conn-001"
set "RC_AZURE_OPEN_AI_DEPLOYMENT=chat-gippity4o-mini"
set "MODEL_CARD_NAME=gpt-4o-mini"
set "MODEL_CARD_VERSION=2024-07-18"


::  AI Search RAG
set "SEARCH_SERVICE=rc-aisearch123"
set "STORAGE=sakbdata"
set "CONTAINER=tooldata"
::  Local KB source path JSON files should be in project folder for relative path
set "SRC=%~dp0..\readmes\JSON"
if not exist "%SRC%\*" (
  echo "ERROR: SRC KB JSON files folder not found: %SRC%"
  exit /b 1
)
set "API_VER=2024-07-01"
::  NOTE! 005_setup_search_kb.cmd creates the datasource,  and indexer.json files.
::  and the names of the index, indexer, and datasource are hardcoded.
::  No big deal, but if you need to change them, it is provided below (not used)
set "DATA_SOURCE_NAME=tooldata-ds"
set "INDEX_NAME=tooldata-index"
set "INDEXER_NAME=tooldata-indexer"

::  Log Analytics workspace - logging under Azure Monitor 
set "LAW=rc-logs-001"
:: Keep logs for 30 days -default is 30 days, max 730 days
set "RETENTION_LOG_TIME=30"


::  Optional app publish output in the project dir
set "APP_PUBLISH_DIR=.\bin\x64\Release\net9.0\publishprod"

echo "============================"
echo "Boot loader initialized for subscription %AZ_SUBSCRIPTION% in location %LOCATION%"
echo "============================"
exit /b 0
