/// <summary>
/// Langsettings class to hold language analysis service configuration.
/// </summary> 

namespace stt
{
    [Notification("Class LangSettings()", " - Currently in development")]
    public sealed class LangSettings
    {
        public string? LangEndpoint { get; init; } = "";
        public string? LangApiKey { get; init; } = "";
    }
}
