@echo off
:: Script to create speech services.
setlocal EnableExtensions EnableDelayedExpansion


echo Calling "%~dp0000_boot_env.cmd"
call "%~dp0000_boot_env.cmd" "%~1"
if errorlevel 1 exit /b 1

echo "============================================"
echo " Azure Speech Service Setup"
echo "============================================"

echo "Checking for existing Speech Service %AZ_SPEECH_NAME% in Resource Group %RG%"...
call az cognitiveservices account show --name "%AZ_SPEECH_NAME%" --resource-group "%RG%" --only-show-errors >nul 2>&1
if not errorlevel 1 (
    echo "WARNING: Speech Service %AZ_SPEECH_NAME% already exists. Skipping creation."
    goto :verify
)

echo "Creating Speech Service %AZ_SPEECH_NAME% in Resource Group %RG% at Location %LOCATION%..."
echo call az cognitiveservices account create --name "%AZ_SPEECH_NAME%" --resource-group "%RG%" --kind "%RC_SPEECH_SERVICE_KIND%" --sku "%RC_SPEECH_SERVICE_SKU%" --location "%LOCATION%" --tags service=speech project=experimentation environment=development owner=team-ai cost-center="%COST_CENTER%" --yes --only-show-errors
call az cognitiveservices account create --name "%AZ_SPEECH_NAME%" --resource-group "%RG%" --kind "%RC_SPEECH_SERVICE_KIND%" --sku "%RC_SPEECH_SERVICE_SKU%" --location "%LOCATION%" --tags service=speech project=experimentation environment=development owner=team-ai cost-center="%COST_CENTER%" --yes --only-show-errors
if errorlevel 1 (
    echo "ERROR: Failed to create Speech Service %AZ_SPEECH_NAME%."
    exit /b 1
)

:verify
echo "Verifying Speech Service %AZ_SPEECH_NAME%..."
call az cognitiveservices account show --name "%AZ_SPEECH_NAME%" --resource-group "%RG%" --only-show-errors

echo "COMPLETED: SPEECH SERVICE CREATE VERIFY."
endlocal
exit /b 0
