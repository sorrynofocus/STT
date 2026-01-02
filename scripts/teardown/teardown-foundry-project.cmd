@echo off
setlocal EnableExtensions EnableDelayedExpansion

echo Calling "%~dp0..\000_boot_env.cmd"
call "%~dp0..\000_boot_env.cmd" "%~1"
IF ERRORLEVEL 1 GOTO :fail

:: Verify the connection
echo.
echo "== Verifying connection... =="
call az cognitiveservices account project connection show --resource-group %RG% --name %RC_AZURE_OPENAI_NAME% --project-name %PROJECT_NAME% --connection-name %CONNECTION_NAME% --only-show-errors

:: Delete connection TO the project:
call az cognitiveservices account project connection delete --resource-group %RG% --name %RC_AZURE_OPENAI_NAME% --project-name %PROJECT_NAME% --connection-name %CONNECTION_NAME% --only-show-errors

:: Delete project
echo.
echo "== Deleting project %PROJECT_NAME% in Foundry resource %RC_AZURE_OPENAI_NAME% =="
call az cognitiveservices account project delete --resource-group %RG% --name %RC_AZURE_OPENAI_NAME% --project-name %PROJECT_NAME% --only-show-errors

:: Delete the Foundry Azure OpenAI resource 
echo.
echo "== Deleting Foundry resource %RC_AZURE_OPENAI_NAME% in resource group %RG% =="
call az cognitiveservices account delete --resource-group %RG% --name %RC_AZURE_OPENAI_NAME% --only-show-errors
IF ERRORLEVEL 1 GOTO :fail

:: Purge Foundry Azure OpenAI resource (This and lang-speech services are softdeleted)
call az cognitiveservices account purge --location "%LOCATION%" --resource-group "%RG%" --name "%RC_AZURE_OPENAI_NAME%" --only-show-errors
IF ERRORLEVEL 1 GOTO :fail



endlocal
exit /b 0

:fail
set "ERR=%ERRORLEVEL%"
endlocal
exit /b %ERR%
