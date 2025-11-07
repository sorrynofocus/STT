# Simplistic Speech-to-Text and AI Assistant Application

**Project:** STT <BR>
**Codename:** function_0 <BR>
**Method:** Cloud<BR>
**Lang/Dev Env:** C#, .NET 9.0 - Visual Studio 2022.


## Introduction

I’ve decided to get more serious about AI development, and this project marks my first _working cloud_ deployment. I chose Azure because I recently earned my Microsoft AI-900 certification and have been exploring both Azure and Foundry. There’s a lot to learn, especially around responsible AI practices.

For the first stage of this project, I wanted to start with Speech-to-Text (STT) using Azure OpenAI since it’s both practical and fun to work with.

I also experiment with local large language models using OpenWebUI, Python, and LLaMA, connected through a Twingate VPN backend so I can access them remotely. Hugging Face is another platform I really enjoy exploring!

This project represents my shift toward cloud-based AI development to gain stronger enterprise-level experience.


This application is a **voice-operated assistant** that integrates **Azure Cognitive Services** and **Azure OpenAI** to provide speech-to-text 
transcription, natural language understanding, and respond to queries or execute commands. The end user will give utterances, it is then transcribed, sent to a model, and determines if it should **answer** ("What is 6 + 2?!") or **execute a command** on the local system ("Open task manager!")

In this project, I’ll be separating new features into individual branches to make it easier for others to follow the progression. I’ve often found myself spending a lot of time reading through large amounts of uncommented or undocumented code, so my goal here is to make the development process clearer. By separating features into branches, it’s easier to see how the project builds up step by step.



## Technologies Used
- **Azure Cognitive Services Speech SDK**: For speech-to-text transcription and text-to-speech synthesis.
- **Azure OpenAI Service**: For natural language understanding and generating responses.
- **.NET9.0**: Application framework.
- **Newtonsoft.Json**: For configuration management and JSON serialization.


## Architecture Overview
### ...and future pipeline flow
![Pipeline](./img/pipeline/pipelineflow-2025-01-13-1802.png)

### Current Pipeline Flow
This is _somewhat_ similar to the image above, but with some differences. The current flow is as follows:

1. **Speech-to-Text**:
- The application captures audio input from the microphone.
- Azure Cognitive Services transcribes the audio into text.

2. **Natural Language Understanding**:
- The transcribed text is sent to Azure OpenAI for processing.
- Azure OpenAI generates a response or command based on the input.

3. **Queries/Command Execution**:
- If the response is a command (example: " List all drives under current directory" or "Open notepad"), the application executes it.
- If the response is an answer to query, it is displayed to the user.


## Future Enhancements
1. **Text To Speech AI responses**:
 - Play synthesized audio responses directly through the system's device output.

2. **Keyword Spotting**:
 - Implement keyword spotting to trigger specific actions based on recognized phrases ("Hey Assistant! Do X!").

3. **Interrupt Handling**:
 - Allow users to interrupt the assistant's speech or processing by detecting new audio input and stopping current operations.


## Azure Setup

To get all of this to work, you'll need to set up Azure services: Azure Cognitive Services for Speech and Azure OpenAI Service. Once these are set up, you'll need to deploy a model in Azure OpenAI and get the necessary keys and endpoints.

Finally, in the application, you'll need to configure the keys and endpoints for both services. After compilation, the application will now use the services and models you've set up in Azure.

  > Note: Embedding the keys directly in the code is not recommended for production applications. Consider using secure configuration management practices. This is done here for simplicity and demonstration purposes.

### Azure Speech Services

1. **Create a Speech Service Resource**:
 - Go to the [Azure Portal](https://portal.azure.com).
 - Search for "Speech" and create a new Speech Service resource.
 - Note the **key**, **region**, and **endpoint**.

2. **Enable Speech-to-Text and Text-to-Speech**:
 - Ensure both transcription and synthesis capabilities are enabled.

### Azure OpenAI Service
1. **Create an Azure OpenAI Resource**:
 - Go to the [Azure Portal](https://portal.azure.com).
 - Search for "Azure OpenAI" and create a new resource.
 - Note the **key**, **endpoint**, and **deployment name**.

2. **Deploy a Model**:
 - In the Azure OpenAI resource, deploy a model like `gpt-4-mini` or `gpt-3.5-turbo`.
 - Note the deployment name for use in the application.

<P>

<details>
<summary><strong>Create Azure Resources and Deploy model (Not for the faint of heart: All for the hardcore CLI users)   [click to expand]</strong></summary>


This is an exhaustive way to building up thje Azure resources, so I've added a both TL;DR and In detail section. I also validated the commands. I should make a video on these steps. Learning the Azure CLI was done using CoPilot and trial and error. There was a _lotuverrors_!

## Build Azure Resources and deploy model (TL;DR)

_Create Resource Group:_

```
az group create --name rc_Group_001 --location westus --tags project=experimentation service=speech service=OpenAI
```

_Create Azure OpenAI Resource:_

```
az cognitiveservices account create  --name rc-AzureOpenAI-Foundry-002 --resource-group rc_Group_001  --kind AIServices  --sku S0  --location westus --tags service=OpenAI project=experimentation environment=development owner=team-ai
```

_Create Speech Services Resource:_

```
az cognitiveservices account create --name rc-SpeechService-001 --resource-group rc_Group_001  --kind SpeechServices  --sku F0 --location westus --tags service=speech project=experimentation environment=development owner=team-ai cost-center=8r0K3-422
```

_Deploy gpt-4o-mini model to Azure OpenAI Resource:_

```
az cognitiveservices account deployment create --resource-group rc_Group_001 --name rc-AzureOpenAI-Foundry-002 --deployment-name chat-gippity4o-mini  --model-name gpt-4o-mini --model-version 2024-07-18  --model-format OpenAI --sku-name Standard --sku-capacity 1
```

_Grab endpoint and keys for your resources:_

```
az cognitiveservices account show -g rc_Group_001 -n rc-SpeechService-001 --query "{endpoint:properties.endpoint, location:location}"
az cognitiveservices account keys list -g rc_Group_001  -n rc-SpeechService-001
```

```
az cognitiveservices account show -g rc_Group_001 -n rc-AzureOpenAI-Foundry-002 --query "{endpoint:properties.endpoint, location:location}"
az cognitiveservices account keys list -g rc_Group_001  -n rc-AzureOpenAI-Foundry-002
```



## Build Azure Resources and deploy model, in detail

### Step 1: Create the Resource Group

```
az group create --name rc_Group_001 --location westus --tags project=experimentation service=speech service=OpenAI
```

Verify:

```
az group show --name rc_Group_001 
```



  

### Step 2a: Create Azure OpenAI Resource

This method is the current (now legacy) to create a resournce in Azure portal. The new way if AI Foundry, but the AZ CLI doesn't support commands as of yet. 

However, is this resource is created, it will surely show in both Portal and Foundry. Foundry will have it represented as a resource. Foundry (the new way) will reqwuire a project created and a resource within the project. 

In this example, this is the method used until Azure CLI supports Foundry. Microsoft is really pushing this. 

Note: 

* The region `westus` will be used in this example.
* `--identity-type` not used because we're not using managed identity in this example.
* `--api-properties` not used because we're not setting any special properties in this example.
* The `Kind` type when creating Foundry project is `AIFoundry`. The older method of creating Azure OpenAI resource (_this example) directly uses `AIServices` as the kind (see commands below that reference `AIServices`). 

Let's continue...

Find available SKUs in your region:

  > Azure OpenAI (S0): This is a paid tier. Even idle deployments may incur charges depending on quota and throughput settings. There is no other option, by th way ^_^


```
az cognitiveservices account list-skus --kind AIServices --location westus
```

Create Azure OpenAI Resource

```
az cognitiveservices account create  --name rc-AzureOpenAI-Foundry-002 --resource-group rc_Group_001  --kind AIServices  --sku S0  --location westus --tags service=OpenAI project=experimentation environment=development owner=team-ai
```


Validate the service created:

```
az cognitiveservices account show --name rc-AzureOpenAI-Foundry-002 --resource-group rc_Group_001
```

Find the SKU of the Azure OpenAI resource you just created:

```
az cognitiveservices account show --name rc-AzureOpenAI-Foundry-002 --resource-group rc_Group_001 --query sku.name -o tsv
```

Verify if public network access is enabled:

```
az cognitiveservices account show  --name rc-AzureOpenAI-Foundry-002  --resource-group rc_Group_001  --query properties.publicNetworkAccess -o tsv
```

Get the endpoint and key:

```
for /f "tokens=*" %i in ('az cognitiveservices account show -g rc_Group_001 -n rc-AzureOpenAI-Foundry-002 --query properties.endpoint -o tsv') do set OPENAI_ENDPOINT=%i
for /f "tokens=*" %i in ('az cognitiveservices account keys list -g rc_Group_001 -n rc-AzureOpenAI-Foundry-002 --query key1 -o tsv') do set OPENAI_KEY=%i
echo OPENAI_ENDPOINT: %OPENAI_ENDPOINT% 
echo OPENAI_KEY: %OPENAI_KEY%
```

  > If you prefer the AZ CLI, refer to the TL;DR section `Grab endpoint and keys for your resources`. This is used if you need automation in Windows terminal BATch scripts
  
  > Cost note: The account itself does not incur cost; deployments do. A Standard deployment (with capacity) bills hourly + tokens.


### Step 2 (optional): Create Foundry project
_Please read carefully! This is optional, but recommended in the future._

At the moment, az CLI does not support foundry. You'll have to do it through the UI at `ai.azure.com`. If you don't want to create project, then creating Azure OpenAI resource directly is possible but the resource will be listed as a resource in Foundry but not part of any project.
If you do go this route, then skip Step 2a above. Creating a Foundry project will also create a resource for you. This will eventually be the preferred method.

Also, to note, creating a Foundry project and resource may not be accessible (deployment) through the AZ CLI at this time. The `Kind` type when creating Foundry project is `AIFoundry`. The older method of creating Azure OpenAI resource directly uses `AIServices` as the kind (see commands below that reference `AIServices`).

- Select + Create New
- Choose AI Foundry resource
- In the create project dialogue window, enter "proj-001-grp-001" for the project name. 
- Expand the `Advanced options`.

Fill in the following:
- Resource Group: rc_Group_001
- Azure AI Foundry resource: rc-AzureOpenAI-Foundry-002
- Subscription: {your subscription name}
- Region: westus

- Click Create

  > Creating project and resources may take several minutes (typically about 3-5 minutes).

  > Interacting with Foundry cannot be done at the time of this writing with AZ CLI. You must use the portal. 


### Step 3: Create Speech Services Resource

```
az cognitiveservices account create --name rc-SpeechService-001 --resource-group rc_Group_001  --kind SpeechServices  --sku F0 --location westus --tags service=speech project=experimentation environment=development owner=team-ai cost-center=8r0K3-422
```


Validate speech service:

```
az cognitiveservices account show --name rc-SpeechService-001 --resource-group rc_Group_001
```

View network access:

```
az cognitiveservices account show   --name rc-SpeechService-001   --resource-group rc_Group_001   --query properties.publicNetworkAccess -o tsv
```

Get the endpoint and key:

```
for /f "tokens=*" %i in ('az cognitiveservices account show -g rc_Group_001 -n rc-SpeechService-001 --query properties.endpoint -o tsv') do set SPEECH_ENDPOINT=%i
for /f "tokens=*" %i in ('az cognitiveservices account keys list -g rc_Group_001 -n rc-SpeechService-001 --query key1 -o tsv') do set SPEECH_KEY=%i
echo SPEECH_ENDPOINT: %SPEECH_ENDPOINT%
echo SPEECH_KEY: %SPEECH_KEY%
```

  > Billing: Speech bills per minute of audio processed. No idle cost.




### Step 4: Deploy a GPT Model to Azure OpenAI (Provisioned input)

Note: 
`--name` must match the Cognitive Services resource name (`rc-AzureOpenAI-Foundry-002`)

First... What can we deploy?

```
az cognitiveservices model list --location westus -o table
```

Let's filter and find _low-end models_ to deploy for our region. Look for both `turbo` and `mini` models (_mini are less costly_):

```
az cognitiveservices model list --location westus --query "map(&{Kind:kind, Sku:skuName, Name:name, Location:location, Version:model.version}, [?kind=='AIServices' && (contains(name, 'turbo') || contains(name, 'mini'))])" -o table
```

Hmmm... Interesting model to consider: `OpenAI.gpt-4o-mini.2024-07-18`

IF you need to see MORE dedtails about the models, use this command:

```
az cognitiveservices model list --location westus --query "[?kind=='AIServices' && (contains(name, 'turbo') || contains(name, 'mini'))]"  -o jsonc
```

Check for model deployability?

```
az cognitiveservices model list --location westus  --query "[?kind=='AIServices' && contains(name, 'turbo')].[name, model.version, model.skus]" -o json
```

  > If a model has a non-empty model.skus including GlobalStandard, it can be deployed via CLI in this region.

We can do this to filter for deployable models:

```
az cognitiveservices model list --location westus --query "[?model.skus && contains(join(' ', model.skus[].name), 'GlobalStandard') && contains(name, 'turbo') || contains(name, 'mini')].[name, model.version, model.skus]" 
```

Select `gpt-4o-mini` for this example.  :
```
    
    Kind        SkuName    Name                                   Location
    ----------  ---------  -------------------------------------  ----------
    AIServices  S0         OpenAI.gpt-4o-mini.2024-07-18         WestUS
```


Deploy gpt-4o-mini to the Azure OpenAI resource created earlier:

```
az cognitiveservices account deployment create --resource-group rc_Group_001 --name rc-AzureOpenAI-Foundry-002 --deployment-name chat-gippity4o-mini  --model-name gpt-4o-mini --model-version 2024-07-18  --model-format OpenAI --sku-name Standard --sku-capacity 1
```


  > Model version is significant as we need to get the EXACT versionof the model.

  > PTU note: --sku-capacity 1 allocates provisioned throughput (1 PTU). Delete the deployment when idle to avoid hourly charges.

Finally,  verify the deployment:

```
az cognitiveservices account deployment show --resource-group rc_Group_001 --name rc-AzureOpenAI-Foundry-002 --deployment-name chat-gippity4o-mini  --query "{model:properties.model, sku:sku, state:properties.provisioningState}"
```

  > 'state' should be 'Succeeded' when deployment is complete.


 To get model details of the deployment:

```
az cognitiveservices account deployment show --resource-group rc_Group_001 --name rc-AzureOpenAI-Foundry-002 --deployment-name chat-gippity4o-mini --query properties.model -o json
```
_Note:_ Validate version, model format, and name.

Using the above example, you can put it into table format:

```
az cognitiveservices account deployment list --resource-group rc_Group_001 --name rc-AzureOpenAI-Foundry-002 --query "[].{name:name, model:properties.model.name, version:properties.model.version, sku:sku.name, capacity:sku.capacity, state:properties.provisioningState}"  -o table
```

Clean up when you’re done (so hourly charges stop)

```
az cognitiveservices account deployment delete --resource-group rc_Group_001 --name rc-AzureOpenAI-Foundry-002 --deployment-name chat-gippity4o-mini
```



### Step 5: Validate Resources

```
az resource list --resource-group rc_Group_001 -o table
```


## Teardown everything with the following:

### Delete the provisioned deployment when done

```
az cognitiveservices account deployment delete --resource-group rc_Group_001 --name rc-AzureOpenAI-Foundry-002 --deployment-name chat-gippity4o-mini
```


### Remove entire resource group and all resources

```
az group delete --name rc_Group_001 --yes --no-wait
```

**Finally! The hardcore stuff is done!**

---

</details>

<P>


## Application Build Instructions


1. **Install Required Packages**:

In the project directory, run the following commands to install the necessary NuGet packages, under the Nuget package manager console:

 ```
 dotnet add package Azure.AI.OpenAI
 dotnet add package Microsoft.CognitiveServices.Speech
 dotnet add package Newtonsoft.Json
 ```

2. **Verify Installed Packages**:
 ```
 dotnet list package
 ```

3. **Clear NuGet Cache and Restore**:
 Probably don't need this, _but_ just in case! 
 
 ```
 dotnet nuget locals all --clear
 dotnet restore --force-evaluate --no-cache
 ```

4. **Build the Application**:
			
  > Note:  Before building, this is where you configure your Azure Cognitive Services and Azure OpenAI keys and endpoints. This is done in `ApplicationConfig.cs` (just don't publish it in production). <BR><BR>Simply modify the following for defaults:

```
      RC_AZURE_OPEN_AI_KEY = "XXX", // Azure OpenAI key 
      RC_AZURE_OPEN_AI_ENDPOINT = "XXX", // Azure OpenAI endpoint 
      RC_AZURE_OPEN_AI_DEPLOYMENT = "XXX", // model deployment
      RC_SPEECH_SERVICE_ENDPOINT = "XXX", // Azure Speech service endpoint
      RC_SPEECH_SERVICE_KEY = "XXX", // Azure Speech service key
      RC_SPEECH_SERVICE_REGION = "westus2", // Azure Speech service region
```
  > If you do not chase this method, then run the application, and configure the `appsettings.json` in your 
`%APPDATA%` folder (APPDATA=C:\Users\{user}\AppData\Roaming\AppSettings.json). The configuration method is crude, but it works for demonstration purposes.


Finally... Build. 

 ```
 dotnet build
 ```



##  Active Branches
| Branch | Description |
|---------|-------------|
| `main` | README.md (your project intro, branching policy, etc.) |
| `feature/winters/init-working-commit` | Initial commit, first working build |
| `develop/winters/*` | Active development branch (will update this soon) |








