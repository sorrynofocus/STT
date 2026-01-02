@echo off
:: script to create a language service and verify its creation
setlocal EnableExtensions EnableDelayedExpansion

echo Calling "%~dp0000_boot_env.cmd"
call "%~dp0000_boot_env.cmd" "%~1"
if errorlevel 1 exit /b 1

echo "============================================"
echo " Azure Language Service Setup"
echo "============================================"

echo "Checking for existing Language service %AZ_LANGUAGE_NAME% in resource group %RG%..."
call az cognitiveservices account show --name "%AZ_LANGUAGE_NAME%" --resource-group "%RG%" --only-show-errors >nul 2>&1
if not errorlevel 1 (
  echo Language service "%AZ_LANGUAGE_NAME%" already exists. Skipping creation.
  goto :verify
)

echo Creating Language service "%AZ_LANGUAGE_NAME%" in resource group "%RG%" at location "%LOCATION%"...
call az cognitiveservices account create --name "%AZ_LANGUAGE_NAME%" --resource-group "%RG%" --kind "%LANG_SERVICE_KIND%" --sku "%LANG_SERVICE_SKU%" --location "%LOCATION%" --assign-identity --yes --only-show-errors
if errorlevel 1 (
  echo "ERROR: Failed to create Language service %AZ_LANGUAGE_NAME%."
  exit /b 1
)

:verify
echo "Verifying creation of Language service %AZ_LANGUAGE_NAME%..."
call az cognitiveservices account show --name "%AZ_LANGUAGE_NAME%" --resource-group "%RG%" --only-show-errors

echo "COMPLETED: LANGUAGE SERVICE CREATE VERIFY."
endlocal
exit /b 0
