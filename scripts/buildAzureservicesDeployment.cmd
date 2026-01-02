@echo off
:: Azure Services Build Deployment Script
:: This will build all the steps in the deployment process for Azure services in the document titled stt_function_0_runbook_azure_setup.md
::

:: Usage: buildAzureservicesDeployment.cmd <subscriptionId>
:: To log all output and errors to a file for debugging, run:
::   buildAzureservicesDeployment.cmd <subscriptionId> > buildAzureservicesDeployment.log 2>&1
:: This will capture all output (including from called scripts) in buildAzureservicesDeployment.log


setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"

if not "%~1"=="" (
    set "AZ_SUBSCRIPTION=%~1"
) else if not "%AZ_SUBSCRIPTION%"=="" (
	echo Using existing AZ_SUBSCRIPTION environment variable
) else (
    echo ERROR: You must provide a subscription ID as a parameter or set AZ_SUBSCRIPTION in the environment. Usage: %~nx0 AZ_SUBSCRIPTION_ID
	call cmd /c exit /b 1
    GOTO :fail
)

REM Step 1: Create / Verify Resource Group
echo.
echo "[1/6] Creating resource group"
CALL "%SCRIPT_DIR%001_group-create-verify.cmd" "%AZ_SUBSCRIPTION%"
IF ERRORLEVEL 1 GOTO :fail

REM Step 2: Create Speech Services (STT/TTS)
echo "[2/6] Creating Speech Services (STT/TTS)"
CALL "%SCRIPT_DIR%002_speech-service-create-verify.cmd" "%AZ_SUBSCRIPTION%"
IF ERRORLEVEL 1 GOTO :fail

REM Step 3: Create Language Services
echo "[3/6] Creating Language Services"
CALL "%SCRIPT_DIR%003_lang-create-verify.cmd" "%AZ_SUBSCRIPTION%"
IF ERRORLEVEL 1 GOTO :fail

REM Step 4: Create Foundry GPT Deployment
echo "[4/6] Creating Foundry GPT Deployment"
CALL "%SCRIPT_DIR%004_create_azure-foundry-rc-project.cmd" "%AZ_SUBSCRIPTION%"
IF ERRORLEVEL 1 GOTO :fail

REM Step 5: Create AI Search/Storage/RAG Index
echo "[5/6] Creating AI Search/Storage/RAG Index"
CALL "%SCRIPT_DIR%005_setup_search_kb.cmd" "%AZ_SUBSCRIPTION%"
IF ERRORLEVEL 1 GOTO :fail

REM Step 6: (Optional) Enable Logging
echo "[6/6] Enabling Logging"
CALL "%SCRIPT_DIR%006_logging-create.cmd" "%AZ_SUBSCRIPTION%"
IF ERRORLEVEL 1 GOTO :fail

REM Get Conf details for  our %APPDATA%/appsettings.json. 
REM Sorry- need to c/p (copy/paste) this from the output log to the appsettings.json file.
echo "Gathering endpoints and conf details..."
CALL "%SCRIPT_DIR%\suppl\get_endpoints-keys-for-services.cmd" "%AZ_SUBSCRIPTION%"
IF ERRORLEVEL 1 GOTO :fail

ECHO Azure services build completed successfully.
GOTO :done

:fail
set "ERR=%ERRORLEVEL%"
echo.
echo "============================"
echo "ERROR: Azure services build failed with errorlevel %ERR%"
echo "============================"
endlocal
exit /b %ERR%


:done
echo.
echo "============================"
echo "Azure services build deployment script completed."
echo "============================"
endlocal
exit /b 0
