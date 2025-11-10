using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

/// <summary>
/// Langsettings class to hold language analysis service configuration.
/// </summary> 
   
namespace stt
{
    [Notification("Class LangSettings()", " - Currently in development")]
    public sealed class LangSettings
    {
        public string LangEndpoint { get; init; } = "";
        public string LangApiKey { get; init; } = "";

        public static LangSettings FromEnv() => new LangSettings
        {
            LangEndpoint = Environment.GetEnvironmentVariable("RC_LANG_ANALYSIS_SERVICE_ENDPOINT") ?? "",
            LangApiKey = Environment.GetEnvironmentVariable("RC_LANG_ANALYSIS_SERVICE_KEY") ?? ""

        };
    }
}
