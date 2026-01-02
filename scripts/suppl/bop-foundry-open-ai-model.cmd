@echo off 
:: Ensure AZure CLI and azure extension "azure-cli-ml" are installed and logged in.
:: This script create a model deployment in our Azure Foundry. 
:: It assumes the resource group, Azure OpenAI, and Foundry service already exist.
:: This script is good to "bop" the deployment before running project or test application. Leaving a running model costs $M$O$N$E$Y$

:: Post-build event -adding below line to Visual Studio project file to deploy and test after build.:
:: Project -> Properties -> Build Events -> Post-build event command line:
:: call "$(SolutionDir)scripts\bop-foundry-open-ai-model.cmd" $(AZURE_SUBSCRIPTION_ID)
:: in Build Events, set “Run the post-build event” to “On successful build”.
:: In Configuration Manager, apply this for "Debug" or whatever you named "Debug" configuration.

setlocal EnableExtensions EnableDelayedExpansion

echo Calling "%~dp0..\000_boot_env.cmd"
call "%~dp0..\000_boot_env.cmd" "%~1"
if errorlevel 1 exit /b 1


:: az cognitiveservices account connection list --resource-group rc_Group_001 --name rc-AzureOpenAI-Foundry-002

call az cognitiveservices account show -g %RG% -n %RC_AZURE_OPENAI_NAME% --only-show-errors >nul 2>&1
if errorlevel 1 (
  echo "*** Azure OpenAI %RC_AZURE_OPENAI_NAME% not found in RG %RG%. ***"
  goto :fail
)

echo "Azure OpenAI %RC_AZURE_OPENAI_NAME% found in Resource Group: %RG%"

@REM echo === Speech account ===
@REM call az cognitiveservices account show -g %RG% -n rc-SpeechService-001 --query "{endpoint:properties.endpoint, location:location}"
@REM call az cognitiveservices account keys list -g %RG% -n rc-SpeechService-001

@REM echo === Azure OpenAI account ===
@REM call az cognitiveservices account show -g %RG% -n %RC_AZURE_OPENAI_NAME% --query "{endpoint:properties.endpoint, location:location}"
@REM call az cognitiveservices account keys list -g %RG% -n %RC_AZURE_OPENAI_NAME%

echo "=== Ensure deployment %RC_AZURE_OPEN_AI_DEPLOYMENT% exists ==="
echo az cognitiveservices account deployment show -g %RG% -n %RC_AZURE_OPENAI_NAME% --deployment-name %RC_AZURE_OPEN_AI_DEPLOYMENT%
call az cognitiveservices account deployment show -g %RG% -n %RC_AZURE_OPENAI_NAME% --deployment-name %RC_AZURE_OPEN_AI_DEPLOYMENT% >nul 2>&1


if errorlevel 1 (
  echo "Deployment not found. Creating..."
  echo az cognitiveservices account deployment create -g %RG% -n %RC_AZURE_OPENAI_NAME% --deployment-name %RC_AZURE_OPEN_AI_DEPLOYMENT% --model-name %MODEL_CARD_NAME% --model-version %MODEL_CARD_VERSION% --model-format OpenAI --sku-name Standard --sku-capacity 1
  call az cognitiveservices account deployment create -g %RG% -n %RC_AZURE_OPENAI_NAME% --deployment-name %RC_AZURE_OPEN_AI_DEPLOYMENT% --model-name %MODEL_CARD_NAME% --model-version %MODEL_CARD_VERSION% --model-format OpenAI --sku-name Standard --sku-capacity 1 || goto :fail
  
) else (
  echo "Deployment already exists."
)

echo "=== List deployments (table) ==="
echo az cognitiveservices account deployment list -g %RG% -n %RC_AZURE_OPENAI_NAME% --output table
:: az cognitiveservices account connection list --resource-group rc_Group_001 --name rc-AzureOpenAI-Foundry-002
call az cognitiveservices account deployment list -g %RG% -n %RC_AZURE_OPENAI_NAME% --output table
       
endlocal
exit /b 0

:fail
echo.
echo "*** Azure CLI step failed. See errors above. ***"
endlocal
exit /b 1
