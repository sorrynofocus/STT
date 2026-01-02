@echo off

:: This file retrieves and sets the keys and endpoints for various Azure services
:: based on the resource group and service names defined in the environment.

:: All this inforamtion is needed to configure the application to connect to the services.
:: At time of the writing, this script shjould help generate the needed infromation to 
:: copy and paste (c/p) into your configuration file (appsettings.json)

:: The appsettings.json lives at %APPDATA% (C:\Users\{USER}\AppData\Roaming)

:: The appsettings.json should look like this:

:: {
::   "Speaker": "en-US",
::   "RC_AZURE_OPEN_AI_KEY": "[REDACTED]",
::   "RC_AZURE_OPEN_AI_ENDPOINT": "https://rc-azureopenai-foundry-002.cognitiveservices.azure.com",
::   "RC_AZURE_OPEN_AI_DEPLOYMENT": "chat-gippity4o-mini",

::   "Persona": "Your personality is ...",
  
::   "RC_SPEECH_SERVICE_KEY": "[REDACTED]",
::   "RC_SPEECH_SERVICE_REGION": "westus",
::   "RC_SPEECH_SERVICE_ENDPOINT": "https://westus.api.cognitive.microsoft.com/",
  
::   "RC_LANG_ANALYSIS_SERVICE_KEY": "[REDACTED]",
::   "RC_LANG_ANALYSIS_SERVICE_ENDPOINT": "https://rc-languageanalysis.cognitiveservices.azure.com/",
::   "RC_LANG_ANALYSIS_SERVICE_REGION": "westus",
  
::   "RC_AI_SEARCH_SERVICE_ENDPOINT": "https://rc-aisearch123.search.windows.net",
::   "RC_AI_SEARCH_SERVICE_KEY": "[REDACTED]",
::   "RC_AI_SEARCH_SERVICE_QUERY_KEY": "[REDACTED]",

::   "SpeechVoice": "en-US-JennyNeural",
::   "SpeechRecognitionLanguage": "en-US",
::   "SpeechFormat": "Raw24Khz16BitMonoPcm",
::   "SilenceTimeoutMs": "2000",
::   "InitialSilenceTimeoutMs": "6000"
:: }

:: NOTE: At the time of this writing the following configurations are NOT supported. Include them, because they will be used in the future.
:: Some of these are hardcoded into the application for now:

::   "Persona"
::   "SpeechVoice"
::   "SpeechRecognitionLanguage"
::   "SpeechFormat"
::   "SilenceTimeoutMs"
::   "InitialSilenceTimeoutMs"

setlocal EnableExtensions EnableDelayedExpansion

echo === ==== ===== ====== 
call "%~dp0..\000_boot_env.cmd" %1
echo "Calling %~dp0..\000_boot_env.cmd"
if errorlevel 1 exit /b 1
echo === ==== ===== ====== 

REM ////SET YOUR RESOURCE GROUP AND SERVICE NAMES HERE ////
:: set RG=rc_Group_001
:: set RC_AZURE_OPENAI_NAME=rc-azureopenai-foundry-002
:: set RC_SPEECH_SERVICE_NAME=rc-SpeechService-001
:: set RC_LANGUAGE_SERVICE_NAME=rc-languageanalysis
:: set RC_AI_SEARCH_SERVICE_NAME=rc-aisearch123
:: set RC_AZURE_OPEN_AI_DEPLOYMENT=chat-gippity4o-mini
set RG=%RG%
set RC_AZURE_OPENAI_NAME=%RC_AZURE_OPENAI_NAME%
set RC_SPEECH_SERVICE_NAME=%AZ_SPEECH_NAME%
set RC_LANGUAGE_SERVICE_NAME=%AZ_LANGUAGE_NAME%
set RC_AI_SEARCH_SERVICE_NAME=%SEARCH_SERVICE%
set RC_AZURE_OPEN_AI_DEPLOYMENT=%RC_AZURE_OPEN_AI_DEPLOYMENT%

REM //////////////////////////////////////////////////////////////////////

if "%RG%"=="" ( echo ERROR: RG is not set. & exit /b 1 )
if "%RC_AZURE_OPENAI_NAME%"=="" ( echo ERROR: RC_AZURE_OPENAI_NAME is not set. & exit /b 1 )
if "%RC_SPEECH_SERVICE_NAME%"=="" ( echo ERROR: RC_SPEECH_SERVICE_NAME is not set. & exit /b 1 )
if "%RC_LANGUAGE_SERVICE_NAME%"=="" ( echo ERROR: RC_LANGUAGE_SERVICE_NAME is not set. & exit /b 1 )
if "%RC_AI_SEARCH_SERVICE_NAME%"=="" ( echo ERROR: RC_AI_SEARCH_SERVICE_NAME is not set. & exit /b 1 )


REM List all services in the resource group for verification
echo Listing all resources in resource group %RG%
CALL az resource list -g %RG% --query "[].{ID:id,Type:type}" -o table

REM to make it prettier you can do this:
REM under linux
REM az resource list -g $RG --query "[].id" -o tsv | awk -F'/' '{print $NF}'

echo.
echo Loading... Retrieving Keys and Endpoints for Services in Resource Group %RG%
echo.

REM Retrieve Azure OpenAI Key and Endpoint
for /f "tokens=*" %%i in ('CALL az cognitiveservices account keys list --name %RC_AZURE_OPENAI_NAME% --resource-group %RG% --query "key1" -o tsv') do set RC_AZURE_OPEN_AI_KEY=%%i
for /f "tokens=*" %%i in ('CALL az cognitiveservices account show --name %RC_AZURE_OPENAI_NAME% --resource-group %RG% --query "properties.endpoint" -o tsv') do set RC_AZURE_OPEN_AI_ENDPOINT=%%i

echo List of deployments for Azure OpenAI Service:
CALL az cognitiveservices account deployment list --resource-group %RG% --name %RC_AZURE_OPENAI_NAME% --output table

echo ---
echo.

REM Retrieve Speech Service Key and Region
for /f "tokens=*" %%i in ('CALL az cognitiveservices account keys list --name %RC_SPEECH_SERVICE_NAME% --resource-group %RG% --query "key1" -o tsv') do set RC_SPEECH_SERVICE_KEY=%%i
:: set RC_SPEECH_SERVICE_REGION=westus
:: set RC_SPEECH_SERVICE_ENDPOINT=https://westus.api.cognitive.microsoft.com/

REM Retrieve Language Analysis Service Key, Endpoint, and Region
for /f "tokens=*" %%i in ('CALL az cognitiveservices account keys list --name %RC_LANGUAGE_SERVICE_NAME% --resource-group %RG% --query "key1" -o tsv') do set RC_LANG_ANALYSIS_SERVICE_KEY=%%i
for /f "tokens=*" %%i in ('CALL az cognitiveservices account show --name %RC_LANGUAGE_SERVICE_NAME% --resource-group %RG% --query "properties.endpoint" -o tsv') do set RC_LANG_ANALYSIS_SERVICE_ENDPOINT=%%i
:: set RC_LANG_ANALYSIS_SERVICE_REGION=westus

REM Retrieve AI Search Service Endpoint and Keys
for /f "tokens=*" %%i in ('CALL az search service show --name %RC_AI_SEARCH_SERVICE_NAME% --resource-group %RG% --query endpoint -o tsv') do set RC_AI_SEARCH_SERVICE_ENDPOINT=%%i
for /f "tokens=*" %%i in ('CALL az search admin-key show --service-name %RC_AI_SEARCH_SERVICE_NAME% --resource-group %RG% --query "primaryKey" -o tsv') do set RC_AI_SEARCH_SERVICE_KEY=%%i
for /f "tokens=*" %%i in ('CALL az search query-key list --service-name %RC_AI_SEARCH_SERVICE_NAME% --resource-group %RG% --query "[0].key" -o tsv') do set RC_AI_SEARCH_SERVICE_QUERY_KEY=%%i


REM Retrieve Storage Accounts
REM TODO:
REM In this section, we loop through all storage accounts in the resource group
REM and retrieve their endpoints and keys. For now, in this project, we just use only one storage account.
REM BuuuuuuTTT this will have to be fixed if we implment more. It'll _only_ pick up the last one in the list.
REM
echo.
echo "Loading Storage Accounts for resource group %RG%"

for /f "tokens=*" %%A in ('CALL az storage account list -g %RG% --query "[].name" -o tsv') do (
    echo.
    echo --- Storage account: %%A ---
    for /f "tokens=*" %%i in ('CALL az storage account show -g %RG% -n %%A --query "primaryEndpoints.blob" -o tsv') do set RC_STORAGE_SERVICE_ENDPOINT=%%i
    for /f "tokens=*" %%i in ('CALL az storage account keys list -g %RG% -n %%A --query "[0].value" -o tsv') do set RC_STORAGE_SERVICE_KEY1=%%i
    for /f "tokens=*" %%i in ('CALL az storage account keys list -g %RG% -n %%A --query "[1].value" -o tsv') do set RC_STORAGE_SERVICE_KEY2=%%i
)


REM Output the retrieved values
echo *****************************************
echo Retrieved Service Keys and Endpoints
echo UPDATE YOUR CONFIGURATIONS AS NEEDED
echo *****************************************
echo.
echo AZURE OPEN AI SERVICE
echo RC_AZURE_OPEN_AI_KEY=%RC_AZURE_OPEN_AI_KEY%
echo RC_AZURE_OPEN_AI_ENDPOINT=%RC_AZURE_OPEN_AI_ENDPOINT%
echo RC_AZURE_OPEN_AI_DEPLOYMENT=%RC_AZURE_OPEN_AI_DEPLOYMENT%
echo.
echo SPEECH SERVICE
echo RC_SPEECH_SERVICE_KEY=%RC_SPEECH_SERVICE_KEY%
echo RC_SPEECH_SERVICE_REGION=%RC_SPEECH_SERVICE_REGION%
echo RC_SPEECH_SERVICE_ENDPOINT=%RC_SPEECH_SERVICE_ENDPOINT%
echo.
echo LANGUAGE ANALYSIS SERVICE
echo RC_LANG_ANALYSIS_SERVICE_KEY=%RC_LANG_ANALYSIS_SERVICE_KEY%
echo RC_LANG_ANALYSIS_SERVICE_ENDPOINT=%RC_LANG_ANALYSIS_SERVICE_ENDPOINT%
echo RC_LANG_ANALYSIS_SERVICE_REGION=%RC_LANG_ANALYSIS_SERVICE_REGION%
echo.
echo AI SEARCH SERVICE
echo RC_AI_SEARCH_SERVICE_ENDPOINT=%RC_AI_SEARCH_SERVICE_ENDPOINT%
echo RC_AI_SEARCH_SERVICE_KEY=%RC_AI_SEARCH_SERVICE_KEY%
echo RC_AI_SEARCH_SERVICE_QUERY_KEY=%RC_AI_SEARCH_SERVICE_QUERY_KEY%
echo.
echo STORAGE ACCOUNTS
echo RC_STORAGE_SERVICE_ENDPOINT=%RC_STORAGE_SERVICE_ENDPOINT%
echo RC_STORAGE_SERVICE_KEY1=%RC_STORAGE_SERVICE_KEY1%
echo RC_STORAGE_SERVICE_KEY2=%RC_STORAGE_SERVICE_KEY2%

endlocal
exit /b 0