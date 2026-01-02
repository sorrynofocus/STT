 @echo off
setlocal EnableExtensions EnableDelayedExpansion

echo Calling "%~dp0..\000_boot_env.cmd"
CALL "%~dp0..\000_boot_env.cmd" "%~1"
if errorlevel 1 exit /b 1


echo.
echo "== Deleting deployment %RC_AZURE_OPEN_AI_DEPLOYMENT% =="

call az cognitiveservices account deployment show -g %RG% -n %RC_AZURE_OPENAI_NAME% --deployment-name %RC_AZURE_OPEN_AI_DEPLOYMENT% >nul 2>&1
if errorlevel 1 (
  echo "Model deployment not found. Skipping."
  exit /b 0
)

echo az cognitiveservices account deployment delete -g %RG% -n %RC_AZURE_OPENAI_NAME% --deployment-name %RC_AZURE_OPEN_AI_DEPLOYMENT%
CALL az cognitiveservices account deployment delete -g %RG% -n %RC_AZURE_OPENAI_NAME% --deployment-name %RC_AZURE_OPEN_AI_DEPLOYMENT%
endlocal
exit /b 0