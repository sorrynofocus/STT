### INtegrating Azure.AI.TextAnalytics

1. in console: dotnet add package Azure.AI.TextAnalytics
2. Code: add using Azure.AI.TextAnalytics;


resp.Value.CreatedAt
resp.Value.Id
resp.Value.Role
resp.Value.Usage.InputTokenCount
resp.Value.Usage.OutputTokenCount
resp.Value.Usage.TotalTokenCount


Test:
What's 2+4?
resp.Value.Content[0].Text = "ANS: 4"



IN CSPROJ:

Only triggers for Debug (you can change the condition).

IgnoreExitCode="true" on cleanup so your Clean doesn’t fail if the deployment is already gone.


---

  <PropertyGroup>
    <!-- Only run these scripts for Debug builds -->
    <RunAoaiScripts Condition="'$(Configuration)'=='Debug'">true</RunAoaiScripts>
  </PropertyGroup>

  <!-- Runs after a success build -->
  <Target Name="EnsureAoaiBeforeDebug" AfterTargets="Build" Condition="'$(RunAoaiScripts)'=='true'">
    <Message Text="Running bop-aoai.cmd......" Importance="high" />
    <Exec Command="scripts\bop-aoai.cmd" />
  </Target>

  <!--  run cleanup   Build - Clean -->
  <Target Name="CleanupAoaiOnClean" AfterTargets="Clean" Condition="'$(RunAoaiScripts)'=='true'">
    <Message Text="Running cleanup-deploy-aoai.cmd...." Importance="high" />
    <Exec Command="scripts\cleanup-deploy-aoai.cmd" IgnoreExitCode="true" />
  </Target>

---
- Edned up removing because of many clean and rebuilds.




"Hi, my name is John Doe. I’m calling because my air conditioner isn’t working properly. It’s blowing warm air 
instead of cool air, and it’s been like this since yesterday.
Could you please help me schedule a technician to come and take a look at it? I’d appreciate it if we could 
get this fixed as soon as possible since the weather is quite hot right now. Thank you!""


LangSettings.cs
Set up class for Analytics configuration


//Example sentiment analysis using Azure.AI.TextAnalytics
using Azure.AI.TextAnalytics; // TextAnalyticsClient, DocumentSentiment
// https://learn.microsoft.com/en-us/dotnet/api/azure.ai.textanalytics.textanalyticsclient?view=azure-dotnet
TextAnalyticsClient textAnalyticsClient = new TextAnalyticsClient(new Uri("endpoint"), new AzureKeyCredential("key"));

               

// Perform sentiment analysis on the content
if (!string.IsNullOrWhiteSpace(content))
{
    DocumentSentiment sentiment = textAnalyticsClient.AnalyzeSentiment(content);
    Console.WriteLine($"Sentiment: {sentiment.Sentiment}");
    Console.WriteLine($"Positive: {sentiment.ConfidenceScores.Positive}, Neutral: {sentiment.ConfidenceScores.Neutral}, Negative: {sentiment.ConfidenceScores.Negative}");
}


---

Added LangServices.cs to encapsulate the TextAnalyticsClient usage.
Added Langsettings to hold configuration.
Injected LangServices into OpenAiService.cs to use sentiment analysis, simple lang detection, and key phrase extraction.
Tested in Debug mode after deploying model.


---
FUTURE...
Use azure key vaults...

Add package:

dotnet add package Azure.Security.KeyVault.Secrets

Example usage to build up AppSettingsEntity() class

var client = new SecretClient(new Uri("<KeyVaultUri>"), new DefaultAzureCredential());
  KeyVaultSecret secret = client.GetSecret("RC_AZURE_OPEN_AI_KEY");
  RC_AZURE_OPEN_AI_KEY = secret.Value;


  --
  TODO:
  Update the readme hardcode section to create via CLI (after validation).

  Update code maps 

  az cognitiveservices account create --name rc-LanguageAnalysis --resource-group rc_Group_001  --kind TextAnalytics  --sku F0  --location westus  --assign-identity  --custom-domain rc-languageanalysis -tags service=language project=experimentation environment=development owner=team-ai cost-center=8r0K3-422
  
  -destroy:
  az cognitiveservices account delete --name rc-LanguageAnalysis --resource-group rc_Group_001

 -network should we lock it down (suggested):
 az cognitiveservices account network-rule list  -g rc_Group_001 -n rc-LanguageAnalysis
az cognitiveservices account network-rule add   -g rc_Group_001 -n rc-LanguageAnalysis --ip-address 203.0.113.10
az cognitiveservices account network-rule remove -g rc_Group_001 -n rc-LanguageAnalysis --ip-address 203.0.113.10
