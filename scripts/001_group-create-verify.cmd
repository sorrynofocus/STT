@echo off
setlocal EnableExtensions EnableDelayedExpansion

echo Calling "%~dp0000_boot_env.cmd"
call "%~dp0000_boot_env.cmd" "%~1"
if errorlevel 1 exit /b 1

echo "============================================"
echo " Azure Resource Group Setup"
echo "============================================"

if not defined RG (
  echo "ERROR: RG is not set."
  exit /b 1
)
if not defined LOCATION (
  echo "ERROR: LOCATION is not set."
  exit /b 1
)

REM --- Preflight: fail fast if not logged in (prevents "hang") ---
call az account show --only-show-errors >nul 2>&1
if errorlevel 1 (
  echo "ERROR: Azure CLI is not logged in (or token expired)."
  echo "Run: az login"
  exit /b 1
)

echo Checking if resource group "%RG%" exists...
call az group show --name "%RG%" --only-show-errors >nul 2>&1
if %errorlevel%==0 (
  echo "OK: Resource group %RG% already exists. No action needed."
  endlocal
  exit /b 0
)

echo "Creating resource group %RG% in location %LOCATION%..."
call az group create --name "%RG%" --location "%LOCATION%" --only-show-errors --output none
if errorlevel 1 (
  echo "ERROR: Failed to create resource group %RG%."
  exit /b 1
)

echo "SUCCESS: Resource group %RG% created."
echo "Showing resource group:"
call az group show --name "%RG%" --only-show-errors --output table
if errorlevel 1 (
  echo "ERROR: Resource group %RG% not accessible after create."
  exit /b 1
)

echo "COMPLETED: GROUP CREATE VERIFY."
endlocal
exit /b 0
