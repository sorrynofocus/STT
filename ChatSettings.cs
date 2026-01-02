/*
 CWinters / Thinkpad T15g Gen 1 / Arizona / AZ / USA
 Purpose: Azure Cognitive Services
 Delivery: Speech to text project using C# 13.0 and .NET 9.0
*/
namespace stt
{
    /// <summary>
    /// ChatSettings holds configuration for connecting to Azure OpenAI.
    /// </summary>
    public sealed class ChatSettings
    {
        public string? Endpoint { get; init; } = "";
        public string? Deployment { get; init; } = "";
        public string? ApiKey { get; init; } = "";
        public string? LangEndpoint { get; init; } = "";
        public string? LangApiKey { get; init; } = "";
        public static ChatSettings FromEnv() => new ChatSettings
        {
            Endpoint = Environment.GetEnvironmentVariable("RC_AZURE_OPEN_AI_ENDPOINT") ?? "",
            Deployment = Environment.GetEnvironmentVariable("RC_AZURE_OPEN_AI_DEPLOYMENT") ?? "",
            ApiKey = Environment.GetEnvironmentVariable("RC_AZURE_OPEN_AI_KEY") ?? "",

            LangEndpoint = Environment.GetEnvironmentVariable("RC_LANG_ANALYSIS_SERVICE_ENDPOINT") ?? "",
            LangApiKey = Environment.GetEnvironmentVariable("RC_LANG_ANALYSIS_SERVICE_KEY") ?? ""
        };
    }
}
