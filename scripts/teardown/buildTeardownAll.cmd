@echo off
REM Teardown all resources by calling each teardown script in this directory
REM Usage: %~nx0 AZ_SUBSCRIPTION_ID > buildTeardownAll.log 2>&1
REM Usage: buildTeardownAll.cmd AZ_SUBSCRIPTION_ID > buildTeardownAll.log 2>&1
setlocal EnableExtensions EnableDelayedExpansion

if not "%~1"=="" (
    set "AZ_SUBSCRIPTION=%~1"
) else if not "%AZ_SUBSCRIPTION%"=="" (
	echo Using existing AZ_SUBSCRIPTION environment variable
) else (
    echo ERROR: You must provide a subscription ID as a parameter or set AZ_SUBSCRIPTION in the environment. Usage: %~nx0 AZ_SUBSCRIPTION_ID
	call cmd /c exit /b 1
    GOTO :fail
    REM TODO modify all scripts to include the done fail pattern because endlocal not called after err. fixed teardown-foundry-project.cmd
)

set "SCRIPT_DIR=%~dp0"

echo Calling "%~dp0..\000_boot_env.cmd"
CALL "%~dp0..\000_boot_env.cmd" "%AZ_SUBSCRIPTION%"
IF ERRORLEVEL 1 GOTO :fail

echo.
echo "[1/6] Tearing down Diagnostics and Logging..."
CALL "%SCRIPT_DIR%teardown-logging.cmd" "%AZ_SUBSCRIPTION%"
IF ERRORLEVEL 1 GOTO :fail

REM Pass the subscription parameter to each teardown script
echo.
echo "[2/6] Tearing down deployed model..."
CALL "%SCRIPT_DIR%teardown-deploy-model.cmd" "%AZ_SUBSCRIPTION%"
IF ERRORLEVEL 1 GOTO :fail

echo.
echo "[3/6] Tearing down Foundry project and resource.."
CALL "%SCRIPT_DIR%teardown-foundry-project.cmd" "%AZ_SUBSCRIPTION%"
IF ERRORLEVEL 1 GOTO :fail

echo.
echo "[4/6] Tearing down Search Indexing and related resources..."
CALL "%SCRIPT_DIR%teardown-search-indexing-etc.cmd" "%AZ_SUBSCRIPTION%"
IF ERRORLEVEL 1 GOTO :fail

echo.
echo "[5/6] Tearing down Language and Speech resources..."
CALL "%SCRIPT_DIR%teardown-lang-speech-service.cmd" "%AZ_SUBSCRIPTION%"
IF ERRORLEVEL 1 GOTO :fail


echo.
echo "[6/6] Tearing down MAIN reosurce group... Goodbye, demo! "
CALL "%SCRIPT_DIR%teardown-rc-grp.cmd" "%AZ_SUBSCRIPTION%"
IF ERRORLEVEL 1 GOTO :fail

echo.
echo "Listing any soft deletes remaining for cognitive services"
CALL az cognitiveservices account list-deleted --output table
echo "------------"
echo "If BLANKS LINES above, no soft-deleted cognitive services remain."
echo "If any soft-deleted services remain, you can purge them with the 'az cognitiveservices account purge' command."
echo "Example: az cognitiveservices account purge  --location %LOCATION%  --resource-group %RG% --name %AZ_SPEECH_NAME% --only-show-errors"

echo.
echo "============D==O==N==E================"
echo "COMPLETED: All teardown executions finished. Resource group '%RG%' should be deleted and all its resources cleaned up."
echo "============D==O==N==E================"
GOTO :done

:done
echo Check lock list for services to verify teardown:
call az lock list --resource-group "%RG%" --output table
REM in case we need to check particular resource
REM call az lock list --resource-group "%RG%" --resource-name "%RC_AZURE_OPENAI_NAME%" --resource-type "Microsoft.CognitiveServices/accounts" --output table
echo.
echo "============================"
echo "Azure services build teardown script completed."
echo "============================"
endlocal
exit /b 0

:fail
set "ERR=%ERRORLEVEL%"
echo.
echo "============================"
echo "ERROR: Azure services build failed with errorlevel %ERR%"
echo "============================"
endlocal
exit /b %ERR%
