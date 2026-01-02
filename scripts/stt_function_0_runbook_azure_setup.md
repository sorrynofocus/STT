# STT Runbook: Azure Setup and Teardown
**Project:** Speech‑to‑Text (STT)
**Platform:** Windows CMD + Azure CLI  
**Purpose:** Provision and remove the Azure resources required for the STT demo project.

---

## 1) Runbook basics

This runbook exists to prevent **future‑you confusion**.

You do **not** need to manually run every script in the `scripts` directory.  
Instead, you run **one setup orchestrator** and **one teardown orchestrator**.

This runbook intentionally mirrors the **OCR project runbook style**, but the STT project itself is intentionally **minimal**.

---

## 2) Prerequisites

### Required
- Windows 11
- Azure CLI installed (`az --version`)
- Logged into Azure CLI (interactive or service principal)
- An Azure subscription where you can create:
  - Resource Group
  - Azure Cognitive Services (Speech)
  - (Optional) Log Analytics workspace

### Recommended
- Run all scripts from a standard `cmd.exe` prompt
- Redirect output to log files (examples below)

---

## 3) Authentication options

### Option A: Interactive login (simplest)
```cmd
az login
az account show --output table
```

### Option B: Service Principal login (non‑interactive)
```cmd
az ad sp create-for-rbac --name "STT-automation" --role contributor --scopes /subscriptions/<your-subscription-id>
```

Then:
```cmd
az login --service-principal -u <appId> -p <password> --tenant <tenant>
az account show --output table
```

> The scripts still require a **subscription ID**.

---

## 4) The Boot Loader: `scripts\000_boot_env.cmd`

All setup and teardown scripts source a **boot loader**.
This file is the **single source of truth** for naming and location.

### What it does
- Sets Azure CLI execution behavior
- Forces the subscription context
- Defines shared resource names and locations

### What you should edit
Open:

```
scripts\000_boot_env.cmd
```

Update the following values:
- `LOCATION` (example: `westus2`)
- `RG` (resource group name)
- `RC_SPEECH_SERVICE_NAME`
- `RC_SPEECH_SERVICE_SKU` (ex: `F0`, `S0`)
... and the rest as needed.

> Tip: Speech resources are name‑constrained and region‑sensitive. Use unique names if you rebuild often.

### Subscription ID handling
The scripts accept the subscription ID in **either** form:

1. Environment variable:
```cmd
SET AZ_SUBSCRIPTION=<your-subscription-id>
```

2. First script argument:
```cmd
buildAzureServicesDeployment.cmd <your-subscription-id>
```

---

## 5) Main operation: Setup (provision Azure resources)

### The one command you run
From the repo root:

```cmd
cd scripts
.\setup\buildAzureServicesDeployment.cmd <your-subscription-id> > buildAzureServicesDeployment.log 2>&1
```

### What it creates (high level)
The setup orchestrator performs:
- Resource Group create / verify
- Azure Cognitive Services **Speech** resource create / verify
- (Optional) Diagnostic settings or logging resources if enabled

### Success criteria
- Script completes without errors
- Azure Portal shows the Speech resource inside the configured resource group

---

## 6) Supplemental helper: Print endpoints and keys

If included in the repo, a helper script prints the Speech service configuration values:

```cmd
cd scripts
.\setup\get_endpoints-keys-for-services.cmd <your-subscription-id>
```

This script:
- **Does not create resources**
- Prints:
  - Speech endpoint
  - Speech key
  - Region

Use these values when configuring the STT application.

#### Configuration

This file retrieves and sets the keys and endpoints for various Azure services
based on the resource group and service names defined in the environment.

All this information is needed to configure the application to connect to the services.
At time of the writing, this script(s) should help generate the needed information to 
copy and paste (c/p) into your configuration file (appsettings.json)

The `appsettings.json` lives at `%APPDATA%` (`C:\Users\{USER}\AppData\Roaming`)

The `appsettings.json` should look like this:

```
{
  "Speaker": "en-US",
  "RC_AZURE_OPEN_AI_KEY": "[REDACTED]",
  "RC_AZURE_OPEN_AI_ENDPOINT": "https://rc-azureopenai-foundry-002.cognitiveservices.azure.com",
  "RC_AZURE_OPEN_AI_DEPLOYMENT": "chat-gippity4o-mini",

  "Persona": "Your personality is ...",
  
  "RC_SPEECH_SERVICE_KEY": "[REDACTED]",
  "RC_SPEECH_SERVICE_REGION": "westus",
  "RC_SPEECH_SERVICE_ENDPOINT": "https://westus.api.cognitive.microsoft.com/",
  
  "RC_LANG_ANALYSIS_SERVICE_KEY": "[REDACTED]",
  "RC_LANG_ANALYSIS_SERVICE_ENDPOINT": "https://rc-languageanalysis.cognitiveservices.azure.com/",
  "RC_LANG_ANALYSIS_SERVICE_REGION": "westus",
  
  "RC_AI_SEARCH_SERVICE_ENDPOINT": "https://rc-aisearch123.search.windows.net",
  "RC_AI_SEARCH_SERVICE_KEY": "[REDACTED]",
  "RC_AI_SEARCH_SERVICE_QUERY_KEY": "[REDACTED]",

  "SpeechVoice": "en-US-JennyNeural",
  "SpeechRecognitionLanguage": "en-US",
  "SpeechFormat": "Raw24Khz16BitMonoPcm",
  "SilenceTimeoutMs": "2000",
  "InitialSilenceTimeoutMs": "6000"
}
```

    > NOTE: At the time of this writing the following configurations are NOT supported. Include them, because they will be used in the future. Some of these are hardcoded into the application for now:

```
  "Speaker"
  "Persona"
  "SpeechVoice"
  "SpeechRecognitionLanguage"
  "SpeechFormat"
  "SilenceTimeoutMs"
  "InitialSilenceTimeoutMs"
```



---

## 7) Main operation: Teardown (remove all resources)

### The one command you run
From the repo root:

```cmd
cd scripts
.\teardown\buildTeardownAll.cmd <your-subscription-id> > buildTeardownAll.log 2>&1
```

### What it removes (high level)
- Diagnostic settings (if present)
- Speech service resource
- Resource group

### Important: Speech soft‑delete
Azure Cognitive Services resources may be **soft‑deleted**.
If the teardown script includes a purge step, allow it to complete.

If not, you may need to manually purge:
```cmd
az cognitiveservices account list-deleted
```

This is especially important when using the **F0 tier**, which allows only one Speech resource per subscription.

---

## 8) Troubleshooting

### Azure CLI not logged in
```cmd
az login
az account show
```

### Name conflicts
Edit the following in `000_boot_env.cmd`:
- `RG`
- `RC_SPEECH_SERVICE_NAME`

Then rerun setup.

### Teardown fails due to locks
Check for locks:
```cmd
az lock list --resource-group "%RG%"
```

Remove locks if present, then rerun teardown.

### Need diagnostics
Always run orchestrators with log redirection:
```cmd
> build.log 2>&1
```

---

## 9) Reminder: Avoid Azure charges

When finished testing or demoing:

1. Run teardown:
```cmd
cd scripts
.\teardown\buildTeardownAll.cmd <your-subscription-id>
```

2. Verify in Azure Portal:
- Resource group is deleted
- No remaining Speech resources
- No Log Analytics workspaces left behind

---

## 10) Summary

- **Boot loader:** `scripts\000_boot_env.cmd`
- **Setup:** `setup\buildAzureServicesDeployment.cmd`
- **Teardown:** `teardown\buildTeardownAll.cmd`
- **Helpers:** Endpoint/key print scripts (if present)



