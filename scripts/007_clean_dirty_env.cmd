@echo off
:: Clears environment variables set by 000_boot_env.cmd (boot loader)
:: In case you test and got a dirty system environment!

:: Clean up *.log files in current directory
echo Cleaning *.log files in current directory...
del /q *.log >nul 2>&1

:: Clean up *.log files in 'teardown' subfolder
if exist teardown (
	echo Cleaning *.log files in 'teardown' subfolder...
	del /q teardown\*.log >nul 2>&1
)

set "AZURE_EXTENSION_USE_DYNAMIC_INSTALL="
set "AZURE_CORE_NO_COLOR="
set "AZURE_CORE_DISABLE_INTERACTIVE_PROMPTS="

REM set "AZ_SUBSCRIPTION="
set "LOCATION="
set "RG="

set "AZ_SPEECH_NAME="
set "RC_SPEECH_SERVICE_REGION="
set "RC_SPEECH_SERVICE_ENDPOINT="
set "COST_CENTER="
set "SERVICE_KIND="
set "SKU="

set "AZ_LANGUAGE_NAME="
set "RC_LANG_ANALYSIS_SERVICE_REGION="
set "LANG_SERVICE_KIND="
set "LANG_SERVICE_SKU="

set "RC_AZURE_OPENAI_NAME="
set "PROJECT_NAME="
set "CONNECTION_NAME="
set "RC_AZURE_OPEN_AI_DEPLOYMENT="
set "MODEL_CARD_NAME="
set "MODEL_CARD_VERSION="

set "SEARCH_SERVICE="
set "STORAGE="
set "CONTAINER="
set "SRC="
set "API_VER="
set "DATA_SOURCE_NAME="
set "INDEX_NAME="
set "INDEXER_NAME="

set "LAW="
set "RETENTION_LOG_TIME="

set "APP_PUBLISH_DIR="

set "RC_AI_SEARCH_SERVICE_NAME="
set "RC_AZURE_OPEN_AI_ENDPOINT="
set "RC_AZURE_OPEN_AI_KEY="

set "RC_LANGUAGE_SERVICE_NAME="
set "RC_LANG_ANALYSIS_SERVICE_ENDPOINT="
set "RC_LANG_ANALYSIS_SERVICE_KEY="
set "RC_SPEECH_SERVICE_KEY="
set "RC_SPEECH_SERVICE_NAME="

echo Cleaned boot loader environment variables and all build logs in curdir and teardown dir. No more dirty env!
exit /b 0
