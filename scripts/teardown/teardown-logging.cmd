 @echo off
:: ============================================================
:: CLEANUP SCRIPT FOR LOG ANALYTICS/DIAGNOSTIC SETTINGS
:: ============================================================

setlocal EnableExtensions EnableDelayedExpansion

echo Calling "%~dp0..\000_boot_env.cmd"
call "%~dp0..\000_boot_env.cmd" "%~1"
if errorlevel 1 exit /b 1

@REM set RG=rc_Group_001
@REM set LAW=rc-logs-001

@REM :: Detect current subscription
@REM set AZ_SUBSCRIPTION=
@REM FOR /F "tokens=* USEBACKQ" %%F IN (`az account show --query id -o tsv`) DO (
@REM     SET AZ_SUBSCRIPTION=%%F
@REM )

echo Subscription is: %AZ_SUBSCRIPTION%
echo Resource Group:  %RG%
echo Log Analytics Workspace: %LAW%
echo.

echo "============================================================"
echo "Remove diagnostic settings from resources in resource group %RG%"
echo "============================================================"

:: Speech

echo.
echo "== Removing diagnostic settings from Speech service... =="
call az monitor diagnostic-settings list --resource "/subscriptions/%AZ_SUBSCRIPTION%/resourceGroups/%RG%/providers/Microsoft.CognitiveServices/accounts/rc-SpeechService-001" --query "[].name" -o tsv > tmp_diag.txt

for /f "tokens=* USEBACKQ" %%D in (tmp_diag.txt) do (
    echo   Deleting setting: %%D
    call az monitor diagnostic-settings delete ^
        --name %%D ^
        --resource "/subscriptions/%AZ_SUBSCRIPTION%/resourceGroups/%RG%/providers/Microsoft.CognitiveServices/accounts/rc-SpeechService-001"
)

:: Language
echo.
echo "== Removing log settings from Language service... =="
call az monitor diagnostic-settings list --resource "/subscriptions/%AZ_SUBSCRIPTION%/resourceGroups/%RG%/providers/Microsoft.CognitiveServices/accounts/rc-LanguageAnalysis" --query "[].name" -o tsv > tmp_diag.txt

for /f "tokens=* USEBACKQ" %%D in (tmp_diag.txt) do (
    echo "Deleting setting: %%D"
    call az monitor diagnostic-settings delete ^
        --name %%D ^
        --resource "/subscriptions/%AZ_SUBSCRIPTION%/resourceGroups/%RG%/providers/Microsoft.CognitiveServices/accounts/rc-LanguageAnalysis"
)

:: OpenAI
echo.
echo "== Removing log settings from OpenAI Foundry... =="
call az monitor diagnostic-settings list --resource "/subscriptions/%AZ_SUBSCRIPTION%/resourceGroups/%RG%/providers/Microsoft.CognitiveServices/accounts/rc-AzureOpenAI-Foundry-002" --query "[].name" -o tsv > tmp_diag.txt

for /f "tokens=* USEBACKQ" %%D in (tmp_diag.txt) do (
    echo "Deleting setting: %%D"
    call az monitor diagnostic-settings delete ^
        --name %%D ^
        --resource "/subscriptions/%AZ_SUBSCRIPTION%/resourceGroups/%RG%/providers/Microsoft.CognitiveServices/accounts/rc-AzureOpenAI-Foundry-002"
)

:: Azure AI Search
echo.
echo "== Removing log settings from AI Search... =="
call az monitor diagnostic-settings list --resource "/subscriptions/%AZ_SUBSCRIPTION%/resourceGroups/%RG%/providers/Microsoft.Search/searchServices/rc-aisearch123" --query "[].name" -o tsv > tmp_diag.txt

for /f "tokens=* USEBACKQ" %%D in (tmp_diag.txt) do (
    echo "Deleting setting: %%D"
    call az monitor diagnostic-settings delete ^
        --name %%D ^
        --resource "/subscriptions/%AZ_SUBSCRIPTION%/resourceGroups/%RG%/providers/Microsoft.Search/searchServices/rc-aisearch123"
)

del tmp_diag.txt 2>nul

echo.
echo ============================================================
echo STEP 2: Delete the Log Analytics Workspace
echo ============================================================

echo "== Deleting workspace: %LAW% =="
call az monitor log-analytics workspace delete ^
    --resource-group %RG% ^
    --workspace-name %LAW% ^
    --yes

echo.
echo "============================================================"
echo "COMPLETE: LOGGING TEARDOWN"
echo "============================================================"

endlocal
exit /b 0