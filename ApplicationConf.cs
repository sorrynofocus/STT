using Newtonsoft.Json;
using System;
using System.IO;
using Microsoft.CognitiveServices.Speech;

namespace stt
{
    // NOTE: This application should NOT be used to store sensitive information in production.
    // In fact, - construct a better solution to get your secrets. This is just for demo purposes.
    // The way this entity config setting work is the first time the app runs, it creates
    // a config file with default values. You can then edit the config file to add your own keys.
    // On repeated runs, it loads the config file. 
    // entity config is stored at APPDATA=C:\Users\{user}\AppData\Roaming\AppSettings.json

    internal class ApplicationConfig
    {
        public class AppSettingsEntity
        {
            ///OpenAI settings
            public string ?RC_AZURE_OPEN_AI_KEY { get; set; }
            public string ?RC_AZURE_OPEN_AI_ENDPOINT { get; set; }
            public string ?RC_AZURE_OPEN_AI_DEPLOYMENT { get; set; }

            // Azure Speech settings
            public string ?RC_SPEECH_SERVICE_ENDPOINT { get; set; } 
            public string ?RC_SPEECH_SERVICE_KEY { get; set; } 
            public string ?RC_SPEECH_SERVICE_REGION { get; set; }


            private static readonly string ?FileUrl =
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "AppSettings.json");

            public static AppSettingsEntity Load()
            {
                if (File.Exists(FileUrl))
                {
                    string ?json = File.ReadAllText(FileUrl);

                    return (JsonConvert.DeserializeObject<AppSettingsEntity>(json) ?? new AppSettingsEntity() );
                }

                //Notice: These defaults are placeholders. Replace with your own keys and endpoints.
                var defaults = new AppSettingsEntity
                {
                    RC_AZURE_OPEN_AI_KEY = "XXX", // Azure OpenAI key 
                    RC_AZURE_OPEN_AI_ENDPOINT = "XXX", // Azure OpenAI endpoint 
                    RC_AZURE_OPEN_AI_DEPLOYMENT = "XXX", // model deployment
                    RC_SPEECH_SERVICE_ENDPOINT = "XXX", // Azure Speech service endpoint
                    RC_SPEECH_SERVICE_KEY = "XXX", // Azure Speech service key
                    RC_SPEECH_SERVICE_REGION = "westus2", // Azure Speech service region
                };
                defaults.Save();
                return defaults;
            }

            public void Save()
            {
                var json = JsonConvert.SerializeObject(this, Formatting.Indented);
                File.WriteAllText(FileUrl, json);
            }

        }
    }
}
