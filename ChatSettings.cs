/*
 CWinters / Thinkpad T15g Gen 1 / Arizona / AZ / USA
 Purpose: Azure Cognitive Services
 Delivery: Speech to text project using C# 13.0 and .NET 9.0
*/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace stt
{
    /// <summary>
    /// ChatSettings holds configuration for connecting to Azure OpenAI.
    /// </summary>
    public sealed class ChatSettings
    {
        public string Endpoint { get; init; } = "";
        public string Deployment { get; init; } = "";
        public string ApiKey { get; init; } = "";

        public static ChatSettings FromEnv() => new ChatSettings
        {
            Endpoint = Environment.GetEnvironmentVariable("RC_AZURE_OPEN_AI_ENDPOINT") ?? "",
            Deployment = Environment.GetEnvironmentVariable("RC_AZURE_OPEN_AI_DEPLOYMENT") ?? "",
            ApiKey = Environment.GetEnvironmentVariable("RC_AZURE_OPEN_AI_KEY") ?? ""
        };
    }
}
