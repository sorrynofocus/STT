/*
dotnet add package Azure.Search.Documents

Azure Cognitive Search (now branded as Azure AI Search)
Azure Cognitive Search service (now part of Azure AI Search) uses the Microsoft.Search/searchServices resource type. In a temaplte you'll see:
"type": "Microsoft.Search/searchServices"
This creates -or have been created as Cognitive Search service. 

Notes:

Create the Azure AI Search service (F0 = Free tier)
az search service create --name rc-aisearch123 --resource-group rc_Group_001 --sku free --partition-count 1 --replica-count 1 --location westus --public-network-access Enabled

higher tier -standard SKU:
az search service create --name rc-aisearch123 --resource-group rc_Group_001 --sku standard --partition-count 1 --replica-count 1 --location westus --public-network-access Enabled

Lsit keys (admin):
az search admin-key show --resource-group rc_Group_001 --service-name rc-aisearch123

List query keys (for user access):
az search query-key list --resource-group rc_Group_001 --service-name rc-aisearch123

create query key (this is used for application/user access):
az search query-key create --resource-group rc_Group_001 --service-name rc-aisearch123 --name MyQueryKey

NOTE! 
When creating a search service, a default query key is created. It's name is NULL. Let's delete this by LISTING the query
keys first (see az search query-key list ...) then delete the key by using the KEY VALUE from the output:

az search query-key delete --resource-group rc_Group_001 --service-name rc-aisearch123 --key-value <key>

Now, use the CREATE QUERY command (above) to create a NAMED query for application.

rotate keys:
# Regenerate the primary key
az search admin-key renew --resource-group rc_Group_001 --service-name rc-aisearch123 --key-kind primary

# Regenerate the secondary key
az search admin-key renew --resource-group rc_Group_001 --service-name rc-aisearch123 --key-kind secondary --service-name rc-aisearch123 --key-kind secondary
*/

using Azure;
using Azure.Search.Documents;
using Azure.Search.Documents.Models;
using System;
using System.Text;
using System.Threading.Tasks;

namespace stt
{
    /// <summary>
    /// Retrieves contextual information from Azure AI Search for use in RAG-style prompts.
    /// </summary>
    public sealed class SearchService
    {
        private readonly SearchClient _searchClient;

        /// <param name="endpoint">The endpoint of your Azure AI Search service (e.g., https://mysearch.search.windows.net)</param>
        /// <param name="indexName">The name of your index</param>
        /// <param name="apiKey">Admin or query key</param>
        public SearchService(SearchSettings searchSettings)
        {
            var serviceUri = new Uri(searchSettings.SearchEndpoint);

            _searchClient = new SearchClient(serviceUri, searchSettings.SearchIndexName, new AzureKeyCredential(searchSettings.SearchApiKey));
        }


        /// <summary>
        /// This retrieves a field value from a SearchDocument, returning an empty string if the field is missing or null.
        /// </summary>
        /// <param name="doc"></param>
        /// <param name="field"></param>
        /// <returns></returns>
        private static string GetFieldValueOrDefault(SearchDocument doc, string field)
         {
             return (doc.TryGetValue(field, out object? value) 
                     && value != null
                     ? value.ToString() ?? string.Empty
                     : string.Empty);
         }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="input"></param>
        /// <param name="max"></param>
        /// <returns></returns>
         private static string TruncStr(string input, int max = 300)
         {
             if (string.IsNullOrEmpty(input)) return string.Empty;
             return (input.Length > max? input.Substring(0, max) + "..." : input);
         }


        /// <summary>
        /// Performs a simple search query and returns the top k results concatenated.
        /// top: number of results to retrieve. If you add KBs, consider increasing this.
        /// For prototype I had 3, so this sat at three. But when I uploaded 5, I wondered 
        /// why certain queries were not fulfilled and it took up to 32 seconds to "figure it out".
        /// </summary>
        public async Task<string> GetRelevantContextAsync(string query, int top = 10)
        {
            //TODO: Revisit this code for semantic search. This will need to be refactored
            try
            {
                var options = new SearchOptions
                {
                    Size = top,
                    IncludeTotalCount = false,
                    //QueryType = SearchQueryType.Semantic, //Not on F0 tier!
                    QueryType = SearchQueryType.Simple,
                };

                var response = await _searchClient.SearchAsync<SearchDocument>(query, options);
                var sb = new StringBuilder();

                int count = 0;
                await foreach (var result in response.Value.GetResultsAsync())
                {
                    // Test AI Search relevance score filtering
                    // Go to search service -> Search Explorer
                    // Set  index choose with drop down menu
                    // run a query. ex: search=epoch
                    // Observe the scores in the results. 
                    // Skip irrelevant results
                    Console.WriteLine($"[SearchService][GetRelevantContextAsync] Result Score: {result.Score}");

                    //Score filtering threshold
                    // 2.0 is very high
                    // 1.2 is a good starting point
                    // .75 is medium
                    // .25 is low
                    // .20
                    //TODO: Make this configurable. Magic Number here!
                    if (result.Score < 2.00)
                        continue;

                    count++;

                    //if (result.Document.TryGetValue("content", out var rawContent))
                    //{
                    //    string? content = rawContent.ToString();

                    //    // Truncate long content to prevent LLM overload
                    //    if (content?.Length > 500)
                    //        content = content.Substring(0, 500) + "...";

                    //    sb.AppendLine($"[Context #{count}] {content}");
                    //    sb.AppendLine();
                    //}

                    // New structured schema fields
                    string toolName = GetFieldValueOrDefault(result.Document, "toolName");
                    string description = TruncStr(GetFieldValueOrDefault(result.Document, "description"));
                    string commandFormat = TruncStr(GetFieldValueOrDefault(result.Document, "commandFormat"));
                    string parameters = TruncStr(GetFieldValueOrDefault(result.Document, "parameters"));
                    string examples = TruncStr(GetFieldValueOrDefault(result.Document, "examples"));

                    sb.AppendLine($"[Context #{count}] Tool: {toolName}");
                    if (!string.IsNullOrWhiteSpace(description))    sb.AppendLine($"Desc: {description}");
                    if (!string.IsNullOrWhiteSpace(commandFormat))  sb.AppendLine($"Command: {commandFormat}");
                    if (!string.IsNullOrWhiteSpace(parameters))     sb.AppendLine($"Params: {parameters}");
                    if (!string.IsNullOrWhiteSpace(examples))       sb.AppendLine($"Example: {examples}");
                    sb.AppendLine();
                }

                if (sb.Length == 0) return (string.Empty);

                Console.WriteLine($"[SearchRetriever] Retrieved {count} context items from Azure AI Search.");
                return (sb.ToString());
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[SearchRetriever] ERROR: {ex.Message}");
                return string.Empty;
            }
        }
    }
}
