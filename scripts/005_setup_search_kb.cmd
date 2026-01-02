@echo off

@REM THIS wa sa challenge! Documentation was sparse and scattered. Inconsistent behavior from CLI vs REST API. Finally got it working.
setlocal EnableExtensions EnableDelayedExpansion

echo Calling "%~dp0000_boot_env.cmd"
call "%~dp0000_boot_env.cmd" "%~1"
if errorlevel 1 exit /b 1

REM Need to test again after creating datasource near end failed and added "--resource "https://search.azure.com"" to help with errors.

echo "============================================"
echo " Azure AI Search Knowledge Base Setup"
echo "============================================"

echo "Creating Azure AI Search service..."
call az search service create ^
  --name %SEARCH_SERVICE% ^
  --resource-group %RG% ^
  --location %LOCATION% ^
  --sku free ^
  --partition-count 1 ^
  --replica-count 1 ^
  --public-network-access Enabled ^
  --disable-local-auth false
if %ERRORLEVEL% NEQ 0 goto END

echo "Getting search admin key..."
FOR /F "usebackq delims=" %%K IN (`call az search admin-key show --resource-group %RG% --service-name %SEARCH_SERVICE% --query primaryKey -o tsv`) DO set ADMIN_KEY=%%K

echo "Creating storage account..."
call az storage account create ^
  --name %STORAGE% ^
  --resource-group %RG% ^
  --location %LOCATION% ^
  --sku Standard_LRS
if %ERRORLEVEL% NEQ 0 goto END

echo "Getting storage connection string..."
FOR /F "usebackq delims=" %%C IN (`call az storage account show-connection-string --name %STORAGE% --resource-group %RG% --query connectionString -o tsv`) DO set STORAGE_CONN=%%C

echo "Creating blob container..."
call az storage container create --name %CONTAINER% --connection-string "%STORAGE_CONN%" --public-access off

echo "Uploading KB files..."
call az storage blob upload-batch ^
  --destination %CONTAINER% ^
  --source "%SRC%" ^
  --connection-string "%STORAGE_CONN%"

echo "Creating datasource.json..."
> datasource.json echo {
>> datasource.json echo "name": "tooldata-ds",
>> datasource.json echo "type": "azureblob",
>> datasource.json echo "credentials": { "connectionString": "%STORAGE_CONN%" },
>> datasource.json echo "container": { "name": "%CONTAINER%" }
>> datasource.json echo }

echo "Creating index.json..."
> index.json echo {
>> index.json echo   "name": "tooldata-index",
>> index.json echo   "fields": [
>> index.json echo     { "name": "id", "type": "Edm.String", "key": true, "searchable": false },
>> index.json echo     { "name": "toolName", "type": "Edm.String", "searchable": true, "filterable": true, "sortable": true },
>> index.json echo     { "name": "description", "type": "Edm.String", "searchable": true },
>> index.json echo     { "name": "commandFormat", "type": "Edm.String", "searchable": true },
>> index.json echo     { "name": "parameters", "type": "Edm.String", "searchable": true },
>> index.json echo     { "name": "examples", "type": "Edm.String", "searchable": true },
>> index.json echo     { "name": "keywords", "type": "Collection(Edm.String)", "searchable": true }
>> index.json echo   ]
>> index.json echo }



echo "Creating indexer.json..."
> indexer.json echo {
>> indexer.json echo "name": "tooldata-indexer",
>> indexer.json echo "dataSourceName": "tooldata-ds",
>> indexer.json echo "targetIndexName": "tooldata-index",
>> indexer.json echo   "schedule": {
>> indexer.json echo     "interval": "PT5M"
>> indexer.json echo   },
>> indexer.json echo "parameters": {
>> indexer.json echo   "configuration": {
>> indexer.json echo     "parsingMode": "json",
REM >> indexer.json echo     "indexFileNameExtensions": ".json"
>> indexer.json echo   }
>> indexer.json echo }
>> indexer.json echo }

echo "Creating datasource via az rest..."

  call az rest --method put ^
  --uri "https://%SEARCH_SERVICE%.search.windows.net/datasources/tooldata-ds?api-version=%API_VER%" ^
  --headers "api-key=%ADMIN_KEY%" ^
  --resource "https://search.azure.com" ^
  --body @datasource.json

echo "Creating index via az rest..."
call az rest --method put ^
  --uri "https://%SEARCH_SERVICE%.search.windows.net/indexes/tooldata-index?api-version=%API_VER%" ^
  --headers "api-key=%ADMIN_KEY%" ^
  --resource "https://search.azure.com" ^
  --body @index.json

echo "Creating indexer via az rest..."
echo call az rest --method put  --uri "https://%SEARCH_SERVICE%.search.windows.net/indexers/tooldata-indexer?api-version=%API_VER%"  --headers "api-key=%ADMIN_KEY%"  --resource "https://search.azure.com" --body @indexer.json

call az rest --method put ^
  --uri "https://%SEARCH_SERVICE%.search.windows.net/indexers/tooldata-indexer?api-version=%API_VER%" ^
  --headers "api-key=%ADMIN_KEY%" ^
  --resource "https://search.azure.com" ^
  --body @indexer.json

echo "Running indexer..."
echo call az rest --method post  --uri "https://%SEARCH_SERVICE%.search.windows.net/indexers/tooldata-indexer/run?api-version=%API_VER%" --headers "api-key=%ADMIN_KEY%"  --resource "https://search.azure.com"

call az rest --method post ^
  --uri "https://%SEARCH_SERVICE%.search.windows.net/indexers/tooldata-indexer/run?api-version=%API_VER%" ^
  --headers "api-key=%ADMIN_KEY%" ^
  --resource "https://search.azure.com"


echo "Cleaning up created files - datasource.json, index.json, indexer.json..."
del datasource.json
del index.json  
del indexer.json

:END
echo "COMPLETED: AI Search KB Setup."
endlocal
exit /b 0
