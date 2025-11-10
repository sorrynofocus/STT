
echo === ==== ===== ====== 
echo === ==== ===== ====== 

setlocal enableextensions
:: our speech and openai are setup, now ensure the deployment is deployed if it doesn't exist.

:: Polst-build event:
:: Project -> Properties -> Build Events -> Post-build event command line:
:: call "$(SolutionDir)scripts\ensure-aoai.cmd"
:: in Build Events, set “Run the post-build event” to “On successful build”.
:: In Configuration Manager, apply this for "Debug" or whatever you named "Debug" configuration.


:: conf
set RG=rc_Group_001
set AOAI=rc-AzureOpenAI-Foundry-002
set DEPLOY=chat-gippity4o-mini
set MODEL=gpt-4o-mini
set VERSION=2024-07-18

echo === Speech account ===
call az cognitiveservices account show -g %RG% -n rc-SpeechService-001 --query "{endpoint:properties.endpoint, location:location}"
call az cognitiveservices account keys list -g %RG% -n rc-SpeechService-001

echo === Azure OpenAI account ===
call az cognitiveservices account show -g %RG% -n %AOAI% --query "{endpoint:properties.endpoint, location:location}"
call az cognitiveservices account keys list -g %RG% -n %AOAI%

echo === Ensure deployment '%DEPLOY%' exists ===
echo az cognitiveservices account deployment show -g %RG% -n %AOAI% --deployment-name %DEPLOY%
call az cognitiveservices account deployment show -g %RG% -n %AOAI% --deployment-name %DEPLOY% >nul 2>&1

if errorlevel 1 (
  echo Deployment not found. Creating...
  echo az cognitiveservices account deployment create -g %RG% -n %AOAI% --deployment-name %DEPLOY% --model-name %MODEL% --model-version %VERSION% --model-format OpenAI --sku-name Standard --sku-capacity 1
  call az cognitiveservices account deployment create -g %RG% -n %AOAI% --deployment-name %DEPLOY% --model-name %MODEL% --model-version %VERSION% --model-format OpenAI --sku-name Standard --sku-capacity 1 || goto :fail
  
) else (
  echo Deployment already exists.
)

echo === List deployments (table) ===
echo az cognitiveservices account deployment list -g %RG% -n %AOAI% --output table
call az cognitiveservices account deployment list -g %RG% -n %AOAI% --output table

exit /b 0

:fail
echo.
echo *** Azure CLI step failed. See errors above. ***
exit /b 1
