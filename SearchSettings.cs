/// <summary>
/// Searchsettings class to hold the search service configuration.
/// </summary> 

namespace stt
{
    [Notification("Class SearchSettings()", " - Currently in development")]
    public sealed class SearchSettings
    {
        public string SearchEndpoint { get; init; } = "";
        public string SearchApiKey { get; init; } = "";

        public string SearchIndexName { get; init; } = "tooldata-indexer";

        public bool IsEnabled =>
            !string.IsNullOrWhiteSpace(SearchEndpoint) &&
            !string.IsNullOrWhiteSpace(SearchApiKey) &&
            !string.IsNullOrWhiteSpace(SearchIndexName);
    }
}