@echo off
setlocal EnableExtensions EnableDelayedExpansion

echo Calling "%~dp0..\000_boot_env.cmd"
call "%~dp0..\000_boot_env.cmd" "%~1"
IF ERRORLEVEL 1 GOTO :fail

:: Delete Language service
echo.
echo "== Deleting Language service %AZ_LANGUAGE_NAME% in resource group %RG% =="

call az cognitiveservices account show --resource-group "%RG%" --name "%AZ_LANGUAGE_NAME%" --only-show-errors >nul 2>&1

if errorlevel 1 (
  echo "Language service %AZ_LANGUAGE_NAME% not found. Skipping."
) else (
  call az cognitiveservices account delete --resource-group "%RG%" --name "%AZ_LANGUAGE_NAME%" --only-show-errors
  IF ERRORLEVEL 1 GOTO :fail
)

  :: Purge Language service (because the service is soft-deleted -discovery!)
  call az cognitiveservices account purge --location "%LOCATION%" --resource-group "%RG%" --name "%AZ_LANGUAGE_NAME%" --only-show-errors
  IF ERRORLEVEL 1 GOTO :fail

:: Delete Speech service
echo.
echo "== Deleting Speech service %AZ_SPEECH_NAME% in resource group %RG% =="

call az cognitiveservices account show --resource-group "%RG%" --name "%AZ_SPEECH_NAME%" --only-show-errors >nul 2>&1

if errorlevel 1 (
  echo "Speech service %AZ_SPEECH_NAME% not found. Skipping."
) else (
  call az cognitiveservices account delete --resource-group "%RG%" --name "%AZ_SPEECH_NAME%" --only-show-errors
  IF ERRORLEVEL 1 GOTO :fail
)

  :: Purge Speech service (because this is also soft-deleted)
  call az cognitiveservices account purge --location "%LOCATION%" --resource-group "%RG%" --name "%AZ_SPEECH_NAME%" --only-show-errors
  IF ERRORLEVEL 1 GOTO :fail


REM Note: I've learned in deleting services are considered soft-deletes. I've witnessed this in Azure Webv UYI but did not pay attention to it. 
REM But, after creating, tearing down and recreatign services, I cannot create certain SKUs or kind of services because they sat in soft-delete with same name.
REM So they need to be PURGED after deletion to be able to recreate them with same name.
REM I discovered the Azure CLI has a purge command for cognitive services to do this.
REM Understandable because soft-delete is a safety mechanism to avoid accidental deletion.


endlocal
exit /b 0

:fail
set "ERR=%ERRORLEVEL%"
endlocal
exit /b %ERR%
