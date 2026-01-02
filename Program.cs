/*
 CWinters / Thinkpad T15g Gen 1 / Arizona / AZ / USA
 Purpose: Azure Cognitive Services. Using the Azure Cognitive
          Services Speech SDK and Azure OpenAI SDK.
 Delivery: Speech to text project using C# 13.0 and .NET 9.0


Set Azure login prefs:
az config set core.login_experience_v2=off

# login with a tenant ID
az login --tenant 00000000-0000-0000-0000-000000000000

*/
using Microsoft.CognitiveServices.Speech;
using Microsoft.CognitiveServices.Speech.Audio;

namespace stt
{
    internal class SpeechPrg
    {
        //Event handler for recognized speech. REquires subscription to event.
        //public event EventHandler<string>? OnRecognized;

        private static void PrintServiceConfig(ApplicationConfig.AppSettingsEntity settings)
        {
            Console.WriteLine("********** CONFIGURATION SUMMARY **********");

            Console.WriteLine("Azure OpenAI:");
            Console.WriteLine($"  Endpoint   : {settings.RC_AZURE_OPEN_AI_ENDPOINT}");
            Console.WriteLine($"  Deployment : {settings.RC_AZURE_OPEN_AI_DEPLOYMENT}");
            Console.WriteLine($"  Key Length : {settings.RC_AZURE_OPEN_AI_KEY?.Length}");

            Console.WriteLine("\nSpeech Service:");
            Console.WriteLine($"  Region     : {settings.RC_SPEECH_SERVICE_REGION}");
            Console.WriteLine($"  Endpoint   : {settings.RC_SPEECH_SERVICE_ENDPOINT}");
            Console.WriteLine($"  Key Length : {settings.RC_SPEECH_SERVICE_KEY?.Length}");

            Console.WriteLine("\nLanguage Analysis:");
            Console.WriteLine($"  Endpoint   : {settings.RC_LANG_ANALYSIS_SERVICE_ENDPOINT}");
            Console.WriteLine($"  Key Length : {settings.RC_LANG_ANALYSIS_SERVICE_KEY?.Length}");

            Console.WriteLine("\nAzure AI Search:");
            Console.WriteLine($"  Endpoint   : {settings.RC_AI_SEARCH_SERVICE_ENDPOINT}");
            Console.WriteLine($"  Index Name : context-index");
            Console.WriteLine($"  Key Length : {settings.RC_AI_SEARCH_SERVICE_KEY?.Length}");

            Console.WriteLine("*******************************************\n");
        }


        // ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-
        async static Task Main(string[] args)
        {
            // Load application entity settings
            ApplicationConfig.AppSettingsEntity? settings = ApplicationConfig.AppSettingsEntity.Load();

            // -------------------------------------------------------------
            // Diagnostic printing of all configured services
            // -------------------------------------------------------------
            PrintServiceConfig(settings);

            // Speech setup
            SpeechConfig? speechConfig = SpeechConfig.FromSubscription(settings.RC_SPEECH_SERVICE_KEY,
                                                                       settings.RC_SPEECH_SERVICE_REGION);

            //MOAR voices here! https://speech.microsoft.com/portal/voicegallery
            //TODO make configurable voices in appsettings.json
            speechConfig.SpeechSynthesisVoiceName = "en-US-JennyNeural";
            // speechConfig.SpeechSynthesisVoiceName = "en-US-AvaMultilingualNeural";
            // speechConfig.SpeechSynthesisOutputFormat = Raw24Khz16BitMonoPcm;
            // Debug: verify speechConfig.GetProperty(PropertyId.SpeechServiceConnection_Endpoint));


            //TODO: Build a better device iterator. Defaults to system default.
            AudioConfig? audioConfig = BasicInputDeviceConfig.SetupMicInput();

            // Azure OpenAI setup
            ChatSettings? chatSettings = new ChatSettings
            {
                Endpoint    = settings.RC_AZURE_OPEN_AI_ENDPOINT ?? string.Empty,
                Deployment  = settings.RC_AZURE_OPEN_AI_DEPLOYMENT ?? string.Empty,
                ApiKey      = settings.RC_AZURE_OPEN_AI_KEY ?? string.Empty,
            };

            // Language analysis service settings
            LangSettings? langSettings = new LangSettings
            {
                LangEndpoint = settings.RC_LANG_ANALYSIS_SERVICE_ENDPOINT ?? string.Empty,
                LangApiKey   = settings.RC_LANG_ANALYSIS_SERVICE_KEY ?? string.Empty
            };

            LanguageService? langService = new LanguageService(langSettings);

            //Azure AI Search settings
            SearchSettings? searchSettings = new SearchSettings()
            {
                SearchEndpoint = settings.RC_AI_SEARCH_SERVICE_ENDPOINT ?? string.Empty,
                SearchApiKey = settings.RC_AI_SEARCH_SERVICE_QUERY_KEY?.Trim() ?? string.Empty,
                SearchIndexName = "tooldata-index" // TODO: Hardcoded for now
            };

            SearchService? searchService = null;
            if (searchSettings.IsEnabled)
            {
                searchService = new SearchService(searchSettings);
                Console.WriteLine("[Init] Azure AI Search enabled.");
            }
            else
                Console.WriteLine("[Init] Azure AI Search disabled (missing config).");


            // Chat service settings
            AzureChatService? chat = new AzureChatService(chatSettings, langService, searchService);

            // Trace recognition events, hooking to console
            SpeechProcessor.OnRecognized += (sender, recognizedText) =>
            {
                Console.WriteLine($"\n[Event] Recognized: {recognizedText}");
            };

            // Run the integrated loop
            using CancellationTokenSource? cts = new CancellationTokenSource();

            //Program.cs
            //   ->
            //      SpeechProcessor.RecognizeSpeechContinuouslyAsyncEx(speechConfig, audioConfig, chat, searchService, ct)
            //   ->
            //      AIResponder.GetAIResponseAsync(chat, searchService, transcript, ct)
            //   ->
            //      SearchService.GetRelevantContextAsync(prompt)
            //   ->
            //      AzureChatService.AskAsync(systemPrompt, enrichedPrompt)
            await chat.AskAsync("Hello", "Hello, world! Let's warm up!", CancellationToken.None);

            await SpeechProcessor.RecognizeSpeechContinuouslyAsyncEx(speechConfig, audioConfig, chat, searchService, cts.Token);

            Console.WriteLine("End of session.");
        }
    }
}

    
