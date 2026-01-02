@echo off
setlocal EnableExtensions EnableDelayedExpansion

echo Calling "%~dp0..\000_boot_env.cmd"
call "%~dp0..\000_boot_env.cmd" "%~1"
if errorlevel 1 exit /b 1

echo "============================================================"
echo " Azure AI Search Knowledge Base Teardown"
echo "============================================================"

echo.
echo "== Deleting Blob Container =="
CALL az storage container delete  --name %CONTAINER% --account-name %STORAGE%  --auth-mode login >nul 2>&1

echo.
echo "== Deleting Storage Account =="
CALL az storage account delete  --name %STORAGE%  --resource-group %RG% --yes >nul 2>&1

echo.
echo "== Deleting Azure AI Search Service =="
CALL az search service delete --name %SEARCH_SERVICE% --resource-group %RG%  --yes >nul 2>&1

echo.
echo "== Done! =="
endlocal
exit /b 0