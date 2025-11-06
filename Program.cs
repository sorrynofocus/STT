/*
 CWinters / Thinkpad T15g Gen 1 / Arizona / AZ / USA
 Purpose: Azure Cognitive Services. Using the Azure Cognitive
          Services Speech SDK and Azure OpenAI SDK.
 Delivery: Speech to text project using C# 13.0 and .NET 9.0
*/
using Microsoft.CognitiveServices.Speech;
using Microsoft.CognitiveServices.Speech.Audio;

namespace stt
{
    internal class SpeechPrg
    {
        //Event handler for recognized speech. REquires subscription to event.
        public event EventHandler<string>? OnRecognized;
        //Here comes all the static stuff for speech SDK and Azure OpenAI SDK!
        private static Microsoft.CognitiveServices.Speech.SpeechConfig? speechConfig;
        private static Microsoft.CognitiveServices.Speech.Audio.AudioConfig? audioConfig;
        private static Microsoft.CognitiveServices.Speech.SpeechSynthesizer? synthesizer;
        private static Microsoft.CognitiveServices.Speech.SpeechRecognizer? recognizer;

        // ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-
        async static Task Main(string[] args)
        {
            // Load application entity settings
            ApplicationConfig.AppSettingsEntity? settings = ApplicationConfig.AppSettingsEntity.Load();

            // Speech setup
            SpeechConfig? speechConfig = SpeechConfig.FromSubscription(settings.RC_SPEECH_SERVICE_KEY,
                                                                       settings.RC_SPEECH_SERVICE_REGION);

            //TODO: Build a better device iterator. Defaults to system default.
            //AudioConfig ?audioConfig = AudioConfig.FromDefaultMicrophoneInput();
            AudioConfig? audioConfig = BasicInputDeviceConfig.SetupMicInput();

            // Azure OpenAI setup
            var chatSettings = new ChatSettings
            {
                Endpoint    = settings.RC_AZURE_OPEN_AI_ENDPOINT ?? string.Empty,
                Deployment  = settings.RC_AZURE_OPEN_AI_DEPLOYMENT ?? string.Empty,
                ApiKey      = settings.RC_AZURE_OPEN_AI_KEY ?? string.Empty
            };

            // Chat service settings
            AzureChatService? chat = new AzureChatService( chatSettings); 

            Console.WriteLine($"Endpoint: {settings.RC_AZURE_OPEN_AI_ENDPOINT}");
            Console.WriteLine($"Deployment: {settings.RC_AZURE_OPEN_AI_DEPLOYMENT}");
            Console.WriteLine($"Key: {(settings.RC_AZURE_OPEN_AI_KEY?.Length ?? 0)} chars");

            // Trace recognition events, hooking to console
            SpeechProcessor.OnRecognized += (sender, recognizedText) =>
            {
                Console.WriteLine($"[Event] Recognized: {recognizedText}");
            };

            // Run the integrated loop
            using CancellationTokenSource? cts = new CancellationTokenSource();

            await SpeechProcessor.RecognizeSpeechContinuouslyAsyncEx(speechConfig, audioConfig, chat, cts.Token);

            Console.WriteLine("End of session.");
        }
    }
}

    
