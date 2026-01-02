@echo off
setlocal EnableExtensions EnableDelayedExpansion

echo Calling "%~dp0..\000_boot_env.cmd"
call "%~dp0..\000_boot_env.cmd" "%~1"
IF ERRORLEVEL 1 GOTO :fail

:: Delete the main resource group RG
echo.
echo "== Deleting resource group %RG% =="
call az group delete --name "%RG%" --yes --only-show-errors
IF ERRORLEVEL 1 GOTO :fail

endlocal
exit /b 0

:fail
set "ERR=%ERRORLEVEL%"
endlocal
exit /b %ERR%