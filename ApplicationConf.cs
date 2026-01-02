using Newtonsoft.Json;

namespace stt
{
    // Entity config is stored at APPDATA=C:\Users\{user}\AppData\Roaming\AppSettings.json
    // The config file works like this:
    // 1. Loads settings
    // 2. Falls back to environment variables if not present in JSON file.
    // 3. Validates the configuration for all required values.
    // 4. Creates template config file if the JSON file does not exist -user updates it.

    internal class ApplicationConfig
    {
        public class AppSettingsEntity
        {
            ///OpenAI settings
            public string? RC_AZURE_OPEN_AI_KEY { get; set; }
            public string? RC_AZURE_OPEN_AI_ENDPOINT { get; set; }
            public string? RC_AZURE_OPEN_AI_DEPLOYMENT { get; set; }
            // Azure Speech settings
            public string? RC_SPEECH_SERVICE_ENDPOINT { get; set; } 
            public string? RC_SPEECH_SERVICE_KEY { get; set; } 
            public string? RC_SPEECH_SERVICE_REGION { get; set; }
            // Language Analysis Service settings
            public string? RC_LANG_ANALYSIS_SERVICE_ENDPOINT { get; set; }
            public string? RC_LANG_ANALYSIS_SERVICE_KEY { get; set; }
            public string? RC_LANG_ANALYSIS_SERVICE_REGION { get; set; }

            public string? RC_AI_SEARCH_SERVICE_ENDPOINT { get; set; }
            public string? RC_AI_SEARCH_SERVICE_KEY { get; set; }
            public string? RC_AI_SEARCH_SERVICE_QUERY_KEY { get; set; }
            //public string? RC_AI_SEARCH_SERVICE_REGION { get; set; }

            private static readonly string FileUrl =Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "AppSettings.json");


            private static void CreateDefaultConf()
            {
                var defaultConfig = new
                {
                    RC_AZURE_OPEN_AI_KEY = "API_KEY",
                    RC_AZURE_OPEN_AI_ENDPOINT = "ENDPOINT_URL",
                    RC_AZURE_OPEN_AI_DEPLOYMENT = "MODEL_NAME_STRING",
                    RC_SPEECH_SERVICE_ENDPOINT = "ENDPOINT_URL",
                    RC_SPEECH_SERVICE_KEY = "API_KEY",
                    RC_SPEECH_SERVICE_REGION = "REGION",
                    RC_LANG_ANALYSIS_SERVICE_ENDPOINT = "ENDPOINT_URL",
                    RC_LANG_ANALYSIS_SERVICE_KEY = "API_KEY",
                    RC_LANG_ANALYSIS_SERVICE_REGION = "REGION",
                    RC_AI_SEARCH_SERVICE_ENDPOINT = "ENDPOINT_URL",
                    RC_AI_SEARCH_SERVICE_KEY = "API_KEY",
                    RC_AI_SEARCH_SERVICE_QUERY_KEY = "QUERY_KEY",
                    //RC_AI_SEARCH_SERVICE_REGION = "REGION",

                };

                string? json = JsonConvert.SerializeObject(defaultConfig, Formatting.Indented);
                File.WriteAllText(FileUrl, json);

                Console.WriteLine($"Default configuration file created: {FileUrl}");
            }


            private static string? GetEnvOrDefault(string? currVal, string envVarName)
            {
                return (string.IsNullOrWhiteSpace(currVal) ? Environment.GetEnvironmentVariable(envVarName) : currVal);
            }

            public void LoadFromEnv()
            {
                RC_AZURE_OPEN_AI_KEY        = GetEnvOrDefault(RC_AZURE_OPEN_AI_KEY, "RC_AZURE_OPEN_AI_KEY");
                RC_AZURE_OPEN_AI_ENDPOINT   = GetEnvOrDefault(RC_AZURE_OPEN_AI_ENDPOINT, "RC_AZURE_OPEN_AI_ENDPOINT");
                RC_AZURE_OPEN_AI_DEPLOYMENT = GetEnvOrDefault(RC_AZURE_OPEN_AI_DEPLOYMENT, "RC_AZURE_OPEN_AI_DEPLOYMENT");

                RC_SPEECH_SERVICE_ENDPOINT  = GetEnvOrDefault(RC_SPEECH_SERVICE_ENDPOINT, "RC_SPEECH_SERVICE_ENDPOINT");
                RC_SPEECH_SERVICE_KEY       = GetEnvOrDefault(RC_SPEECH_SERVICE_KEY, "RC_SPEECH_SERVICE_KEY");
                RC_SPEECH_SERVICE_REGION    = GetEnvOrDefault(RC_SPEECH_SERVICE_REGION, "RC_SPEECH_SERVICE_REGION");

                RC_LANG_ANALYSIS_SERVICE_ENDPOINT = GetEnvOrDefault(RC_LANG_ANALYSIS_SERVICE_ENDPOINT, "RC_LANG_ANALYSIS_SERVICE_ENDPOINT");
                RC_LANG_ANALYSIS_SERVICE_KEY      = GetEnvOrDefault(RC_LANG_ANALYSIS_SERVICE_KEY, "RC_LANG_ANALYSIS_SERVICE_KEY");
                RC_LANG_ANALYSIS_SERVICE_REGION   = GetEnvOrDefault(RC_LANG_ANALYSIS_SERVICE_REGION, "RC_LANG_ANALYSIS_SERVICE_REGION");

                RC_AI_SEARCH_SERVICE_ENDPOINT     = GetEnvOrDefault(RC_AI_SEARCH_SERVICE_ENDPOINT, "RC_AI_SEARCH_SERVICE_ENDPOINT");
                RC_AI_SEARCH_SERVICE_KEY          = GetEnvOrDefault(RC_AI_SEARCH_SERVICE_KEY, "RC_AI_SEARCH_SERVICE_KEY");
                RC_AI_SEARCH_SERVICE_QUERY_KEY    = GetEnvOrDefault(RC_AI_SEARCH_SERVICE_QUERY_KEY, "RC_AI_SEARCH_SERVICE_QUERY_KEY");
                //RC_AI_SEARCH_SERVICE_REGION       = GetEnvOrDefault(RC_AI_SEARCH_SERVICE_REGION, "RC_AI_SEARCH_SERVICE_REGION");
            }

            public static AppSettingsEntity Load()
            {
                AppSettingsEntity conf;

                if (File.Exists(FileUrl))
                {
                    string? json = File.ReadAllText(FileUrl);
                    conf = JsonConvert.DeserializeObject<AppSettingsEntity>(json) ?? new AppSettingsEntity();
                }
                else
                {
                    Console.WriteLine("Configuration file not found. Creating a default configuration file...");
                    CreateDefaultConf();
                    throw new FileNotFoundException($"Configuration not found. A default conf created: {FileUrl}. Now, you can populate it with settings.");
                }

                // Load sensitive values from environment variables
                conf.LoadFromEnv();
                ValidateConf(conf);

                return (conf);
            }

            private static void ValidateConf(AppSettingsEntity conf)
            {
                foreach (System.Reflection.PropertyInfo property in typeof(AppSettingsEntity).GetProperties())
                {
                    var value = property.GetValue(conf);

                    if (value == null)
                    { 
                        Console.WriteLine($"Warning: Missing value for {property.Name}. Please update the configuration file.");
                        Environment.Exit(1);
                    }
                }
            }

            public void Save()
            {
                string? json = JsonConvert.SerializeObject(this, Formatting.Indented);
                File.WriteAllText(FileUrl, json);
            }

        }
    }
}
