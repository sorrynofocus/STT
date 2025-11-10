set RG=rc_Group_001
set AOAI=rc-AzureOpenAI-Foundry-002
set DEPLOY=chat-gippity4o-mini
echo Deleting deployment %DEPLOY%...
echo az cognitiveservices account deployment delete -g %RG% -n %AOAI% --deployment-name %DEPLOY%
az cognitiveservices account deployment delete -g %RG% -n %AOAI% --deployment-name %DEPLOY%