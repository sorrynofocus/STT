@echo off
REM This script does the following:
REM 1. Create Azure OpenAI Cognitive Services resource if it does not exist
REM 2. Create Foundry Project
REM 3. Create connection file to connect Foundry project to Azure OpenAI Service. This  connection file is a JSON file and it is used to create the connection between the project and the Azure OpenAI resource.
REM 4. Connect project to Azure OpenAI Service using the connection file

::  This was created with the help of Copilot and Azure docs. Foundry was pretty 
::  new at the time of this writing and the CLI commands were just added.
::  This may or may not fail in the future but understanding the flow was important.
::  https://github.com/MicrosoftDocs/azure-ai-docs/blob/main/articles/ai-services/includes/quickstarts/management-azcli.md
:: New Cognitive Services in az cli
:: az cognitiveservices account connection: Add AI Foundry account connection management
:: az cognitiveservices account project: Add AI Foundry account project management
:: az cognitiveservices account project connection: Add AI Foundry account project connection management
:: az cognitiveservice agent: Add command group
:: bind stt-demo2 project to the Azure OpenAI resource using the connection defined in foundry-project-connection.json



setlocal EnableExtensions EnableDelayedExpansion

echo Calling "%~dp0000_boot_env.cmd"
call "%~dp0000_boot_env.cmd" "%~1"
if errorlevel 1 exit /b 1

echo "============================================"
echo " Azure AI Foundry Project Setup"
echo "============================================"

echo.
echo "Creation steps:"
echo "Create Azure OpenAI Cognitive Services - %RC_AZURE_OPENAI_NAME%"
echo "Creating Foundry Project - %PROJECT_NAME%"
echo "Creating connection file to connect %PROJECT_NAME% to Azure OpenAI Service %RC_AZURE_OPENAI_NAME%"
echo "Connecting project to Azure OpenAI Service"
echo.

::  set RG=rc_Group_001
::  set RC_AZURE_OPENAI_NAME=rc-AzureOpenAI-Foundry-002
:: set PROJECT_NAME=stt-demo2
::  set CONNECTION_NAME=stt-conn-001
set "CONNECT_FILE=%~dp0foundry-project-connection.json"
set RC_AZURE_OPEN_AI_KEY=

echo "Checking Azure OpenAI Cognitive Services account exists..."
call az cognitiveservices account show --name %RC_AZURE_OPENAI_NAME% --resource-group %RG% --only-show-errors >nul 2>&1
if errorlevel 1 (
  echo "Creating Azure OpenAI Cognitive Services account %RC_AZURE_OPENAI_NAME% ..."
  call az cognitiveservices account create --name %RC_AZURE_OPENAI_NAME% --resource-group %RG% --kind %RC_AZURE_OPENAI_SERVICE_KIND% --sku %RC_AZURE_OPENAI_SERVICE_SKU% --location %LOCATION% --yes --only-show-errors
  if errorlevel 1 exit /b 1
) else (
  echo "Azure OpenAI Cognitive Services account %RC_AZURE_OPENAI_NAME% already exists."
)


REM ERROR: (BadRequest) Account must set CustomSubDomainName before creating projects.
REM This is new. ok then update foundry resource to create a custom subdomain name to finally create a project.
echo "Setting CustomSubDomainName for Azure OpenAI Cognitive Services account %RC_AZURE_OPENAI_NAME% ..."
call az cognitiveservices account update --name %RC_AZURE_OPENAI_NAME% --resource-group %RG% --custom-domain %RC_AZURE_OPENAI_NAME% --only-show-errors
if errorlevel 1 exit /b 1


echo "Creating Foundry Project ..."
call az cognitiveservices account project create --location %LOCATION% --resource-group %RG% --name %RC_AZURE_OPENAI_NAME%  --project-name %PROJECT_NAME%

echo "Connecting project to Azure OpenAI Service... Obtaining key ..."
for /f "tokens=*" %%i in ('az cognitiveservices account keys list --name %RC_AZURE_OPENAI_NAME% --resource-group %RG% --query "key1" -o tsv') do (
    set RC_AZURE_OPEN_AI_KEY=%%i
)


echo "Creating connection file  %CONNECT_FILE% ... "

:: Creating connection json file -  expected content:
:: {
::   "type": "AzureOpenAI",
::   "connectionType": "AzureOpenAI", 
::   "endpoint": "https://https://rc-azureopenai-foundry-002.openai.azure.com/",
::   "authentication": {
::     "type": "apiKey",
::     "key": "%RC_AZURE_OPEN_AI_KEY%"
::   },
::   "metadata": {
::     "description": "Connection for STT demo (2) project",
::     "createdBy": "cli-script",
::     "tags": ["speech-to-text", "demo"],
::     "apiType": "chat" 
::   }
:: }


> "%CONNECT_FILE%" echo {
>> "%CONNECT_FILE%" echo   "type": "AzureOpenAI",
>> "%CONNECT_FILE%" echo   "connectionType": "AzureOpenAI",
>> "%CONNECT_FILE%" echo   "endpoint": "https://%RC_AZURE_OPENAI_NAME%.openai.azure.com/",
>> "%CONNECT_FILE%" echo   "authentication": {
>> "%CONNECT_FILE%" echo     "type": "apiKey",
>> "%CONNECT_FILE%" echo     "key": "%RC_AZURE_OPEN_AI_KEY%"
>> "%CONNECT_FILE%" echo   },
>> "%CONNECT_FILE%" echo   "metadata": {
>> "%CONNECT_FILE%" echo     "description": "Connection for STT demo (2) project",
>> "%CONNECT_FILE%" echo     "createdBy": "cli-script",
>> "%CONNECT_FILE%" echo     "tags": ["speech-to-text", "demo"],
>> "%CONNECT_FILE%" echo     "ApiType": "audio"
>> "%CONNECT_FILE%" echo   }
>> "%CONNECT_FILE%" echo }     


echo "Connecting project %PROJECT_NAME% to Azure OpenAI Service %RC_AZURE_OPENAI_NAME% with a connection name %CONNECTION_NAME% ..."
call az cognitiveservices account project connection create  --resource-group %RG%  --name %RC_AZURE_OPENAI_NAME%  --project-name %PROJECT_NAME%  --connection-name %CONNECTION_NAME%  --file "%CONNECT_FILE%"

:: ApiType values tripped me up!
::  Operation returned an invalid status 'Required metadata property ApiType is missing' 
:: CASE SenSitive!!! That why this error appeared while trying to get this to work.
::
::  Documentation on ApiType values (CoPilot help):
::
::  ApiType - Use Case - Example Scenario
::  chat - For GPT models using the Chat Completions API - Building conversational agents, copilots, or assistants
::  embeddings -For vector representations of text - Semantic search, document retrieval, clustering
::  completions	- Legacy text completion API - Classic prompt  text output (older models)
::  images	- For image generation endpoints - Generating visuals from text prompts
::  audio	-   For speech-to-text or text-to-speech - Transcribing audio files, synthesizing speech


:: Now verify the connection
echo "Verifying connection..."
call az cognitiveservices account project connection show --resource-group %RG% --name %RC_AZURE_OPENAI_NAME% --project-name %PROJECT_NAME% --connection-name %CONNECTION_NAME%

:: previous error while troubleshooting: "Parameter format not correct - "foundry-project-connection.json""
:: this was becasue I had ./ rather than .\ - tricky batch fiel debugging.
del "%CONNECT_FILE%"


echo "Checking if deployment %RC_AZURE_OPEN_AI_DEPLOYMENT% exists - probably will not... "
echo az cognitiveservices account deployment show -g %RG% -n %RC_AZURE_OPENAI_NAME% --deployment-name %RC_AZURE_OPEN_AI_DEPLOYMENT%
call az cognitiveservices account deployment show -g %RG% -n %RC_AZURE_OPENAI_NAME% --deployment-name %RC_AZURE_OPEN_AI_DEPLOYMENT% >nul 2>&1


if errorlevel 1 (
  echo "Deployment not found. Creating deployment %RC_AZURE_OPEN_AI_DEPLOYMENT% - %MODEL_CARD_NAME%  ..."
  echo az cognitiveservices account deployment create -g %RG% -n %RC_AZURE_OPENAI_NAME% --deployment-name %RC_AZURE_OPEN_AI_DEPLOYMENT% --model-name %MODEL_CARD_NAME% --model-version %MODEL_CARD_VERSION% --model-format OpenAI --sku-name Standard --sku-capacity 1
  call az cognitiveservices account deployment create -g %RG% -n %RC_AZURE_OPENAI_NAME% --deployment-name %RC_AZURE_OPEN_AI_DEPLOYMENT% --model-name %MODEL_CARD_NAME% --model-version %MODEL_CARD_VERSION% --model-format OpenAI --sku-name Standard --sku-capacity 1 || goto :fail
  
) else (
  echo "Deployment already exists."
)

echo "=== List deployments (table) ==="
echo az cognitiveservices account deployment list -g %RG% -n %RC_AZURE_OPENAI_NAME% --output table
:: az cognitiveservices account connection list --resource-group rc_Group_001 --name rc-AzureOpenAI-Foundry-002
call az cognitiveservices account deployment list -g %RG% -n %RC_AZURE_OPENAI_NAME% --output table


echo "COMPLETED: CREATE AZURE FOUNDRY RC PROJECT."
endlocal
exit /b 0


::
::
::

:: Reviewing the flow from above. Adding more foundry stuff to CLI, so this is new!
::Create project FIRST 
:: expected out put:

::  {
::    "etag": "\"0300c06a-0000-0700-0000-693790420000\"",
::    "id": "/subscriptions/[SUBSCRIPTION_ID_REDACTED]/resourceGroups/rc_Group_001/providers/Microsoft.CognitiveServices/accounts/rc-AzureOpenAI-Foundry-002/projects/stt-demo2",
::    "identity": {
::      "principalId": "[REDACTED]",
::      "tenantId": "[REDACTED]",
::      "type": "SystemAssigned",
::      "userAssignedIdentities": null
::    },
::    "kind": "AIServices",
::    "location": "westus",
::    "name": "rc-AzureOpenAI-Foundry-002/stt-demo2",
::    "properties": {
::      "description": null,
::      "displayName": null,
::      "endpoints": {
::        "AI Foundry API": "https://rc-azureopenai-foundry-002.services.ai.azure.com/api/projects/stt-demo2"
::      },
::      "internalId": "REDACTED",
::      "isDefault": false,
::      "provisioningState": "Succeeded"
::    },
::    "resourceGroup": "rc_Group_001",
::    "systemData": {
::      "createdAt": "2025-12-09T02:58:03.709454+00:00",
::      "createdBy": "[EMAIL_REDACTED]",
::      "createdByType": "User",
::      "lastModifiedAt": "2025-12-09T02:58:03.709454+00:00",
::      "lastModifiedBy": "[EMAIL_REDACTED]",
::      "lastModifiedByType": "User"
::    },
::    "tags": null,
::    "type": "Microsoft.CognitiveServices/accounts/projects"
::  }

:: Then we obtain a key from the Azure OpenAI resource

:: Then we create a connection json file with the key and endpoint
:: Should look something  like this:

:: {
::    "type": "AzureOpenAI",
::    "connectionType": "AzureOpenAI",
::    "endpoint": "https://%RC_AZURE_OPENAI_NAME%.openai.azure.com/",
::    "authentication": {
::      "type": "apiKey",
::      "key": "%RC_AZURE_OPEN_AI_KEY%"
::    },
::    "metadata": {
::      "description": "Connection for STT demo (2) project",
::      "createdBy": "cli-script",
::      "tags": ["speech-to-text", "demo"],
::      "ApiType": "audio"
::    }
::  }   



:: Then we create the connection to bind the project to the Azure OpenAI resource

::  Expected output

::  {
::    "id": "/subscriptions/[SUBSCRIPTION_ID_REDACTED]/resourceGroups/rc_Group_001/providers/Microsoft.CognitiveServices/accounts/rc-AzureOpenAI-Foundry-002/projects/stt-demo2/connections/stt-conn-001",
::    "location": null,
::    "name": "stt-conn-001",
::    "properties": {
::      "authType": "AAD",
::      "category": "AzureOpenAI",
::      "createdByWorkspaceArmId": null,
::      "error": null,
::      "expiryTime": null,
::      "group": "AzureAI",
::      "isDefault": true,
::      "isSharedToAll": false,
::      "metadata": {
::        "ApiType": "audio",
::        "ApiVersion": "2023-07-01-preview",
::        "DeploymentApiVersion": "2023-10-01-preview",
::        "createdBy": "cli-script",
::        "description": "Connection for STT demo (2) project",
::        "tags": "['speech-to-text', 'demo']"
::      },
::      "peRequirement": "NotRequired",
::      "peStatus": "NotApplicable",
::      "sharedUserList": [],
::      "target": "https://rc-AzureOpenAI-Foundry-002.openai.azure.com/",
::      "useWorkspaceManagedIdentity": false
::    },
::    "resourceGroup": "rc_Group_001",
::    "systemData": {
::      "createdAt": "2025-12-09T03:23:05.424946+00:00",
::      "createdBy": "[EMAIL_REDACTED]",
::      "createdByType": "User",
::      "lastModifiedAt": "2025-12-09T03:23:05.424946+00:00",
::      "lastModifiedBy": "[EMAIL_REDACTED]",
::      "lastModifiedByType": "User"
::    },
::    "tags": null,
::    "type": "Microsoft.CognitiveServices/accounts/projects/connections"
::  }

:: Then we can verify the connection

::  Expected output:
::  {
::    "id": "/subscriptions/[SUBSCRIPTION_ID_REDACTED]/resourceGroups/rc_Group_001/providers/Microsoft.CognitiveServices/accounts/rc-AzureOpenAI-Foundry-002/projects/stt-demo2/connections/stt-conn-001",
::    "location": null,
::    "name": "stt-conn-001",
::    "properties": {
::      "authType": "AAD",
::      "category": "AzureOpenAI",
::      "createdByWorkspaceArmId": null,
::      "error": null,
::      "expiryTime": null,
::      "group": "AzureAI",
::      "isDefault": true,
::      "isSharedToAll": false,
::      "metadata": {
::        "ApiType": "audio",
::        "ApiVersion": "2023-07-01-preview",
::        "DeploymentApiVersion": "2023-10-01-preview",
::        "createdBy": "cli-script",
::        "description": "Connection for STT demo (2) project",
::        "tags": "['speech-to-text', 'demo']"
::      },
::      "peRequirement": "NotRequired",
::      "peStatus": "NotApplicable",
::      "sharedUserList": [],
::      "target": "https://rc-AzureOpenAI-Foundry-002.openai.azure.com/",
::      "useWorkspaceManagedIdentity": false
::    },
::    "resourceGroup": "rc_Group_001",
::    "systemData": {
::      "createdAt": "2025-12-09T03:59:44.996608+00:00",
::      "createdBy": "[EMAIL_REDACTED]",
::      "createdByType": "User",
::      "lastModifiedAt": "2025-12-09T03:59:44.996608+00:00",
::      "lastModifiedBy": "[EMAIL_REDACTED]",
::      "lastModifiedByType": "User"
::    },
::    "tags": null,
::    "type": "Microsoft.CognitiveServices/accounts/projects/connections"
::  }

:: :: 
:: :: 
:: :: 
:: :: 

::  good description from Copilot on connections:
::  Understanding Cognitive Services Project Connections
::  What a "connection" actually is
::  A connection is a child resource under a Cognitive Services project.

::  It defines how that project talks to a specific service endpoint for example, your Azure OpenAI resource.

::  The connection bundles together:

::  Endpoint URL (where requests go).

::  Authentication method (API key or managed identity).

::  Metadata (like ApiType = chat, audio, embeddings, etc.).

::  Think of it as the bridge between your project and the actual Cognitive Services account.

::  What the connection name does
::  The connection name is just the identifier for that bridge.

::  It’s unique within the project and lets you reference the connection later.

::  For example:

::  When you deploy or test a project, you can say “use connection stt-conn-001.”

::  If you have multiple connections (say one for chat and one for audio), the names distinguish them.

::  It doesn’t affect the endpoint or keys it’s purely a label you control.

::  Hierarchy Recap
::  Code
::  Resource Group then Cognitive Services Account then Project then Connection
::  Account: Your Azure OpenAI resource (rc-AzureOpenAI-Foundry-002).

::  Project: Logical grouping for a workload (stt-demo2).

::  Connection: The binding that says “this project uses this account, with this API type, via this auth.”
