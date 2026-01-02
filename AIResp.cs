/*
 CWinters / Thinkpad T15g Gen 1 / Arizona / AZ / USA
 Purpose: Azure Cognitive Services. Using the Azure Cognitive
          Services Speech SDK and Azure OpenAI SDK.
 Delivery: Speech to text project using C# 13.0 and .NET 9.0

*/

using System.Diagnostics;

namespace stt
{
    /// <summary>
    /// AIResponder() class
    /// Tight contract with the model: return either CMD: or ANS:
    /// This function sends the prompt to the chat service and returns the response.
    /// </summary>
    [Notification("Class AIResponder()", " - Currently operational")]
    public static class AIResponder
    {
        /// <summary>
        /// Gets AI response from AzureChatService based on the provided prompt.
        /// lambda calls AskAsync() from AzureChatService() class with a fixed system contract.
        /// </summary>
        /// <param name="chat"></param>
        ///  <param name="searchService"></param>
        /// <param name="prompt"></param>
        /// <param name="ct"></param>
        /// <returns></returns>
        public static async Task<string> GetAIResponseAsync(
                                                            AzureChatService chat,
                                                            SearchService searchService,
                                                            string prompt,
                                                            CancellationToken ct = default)
        {
            string? systemPrompt = PromptComposer.BuildSystemPrompt();
            Stopwatch? sw = Stopwatch.StartNew();

            try
            {
                string? context = string.Empty;

                if (searchService is not null)
                    //TODO: parameterize top K
                    context = await searchService.GetRelevantContextAsync(prompt, top: 3);

                string? enrichedPrompt = PromptComposer.BuildUserPrompt(prompt, context);

                Console.WriteLine($"[AIResp.GetAIResponseAsync] Calling AskAsync. Prompt length: {enrichedPrompt.Length}");
                string? result = await chat.AskAsync(systemPrompt, enrichedPrompt, ct);

                //Console.WriteLine($"[AIResp.GetAIResponseAsync] Response: {result}");
                Console.WriteLine($"[AIResp.GetAIResponseAsync] [LLM] took {sw.ElapsedMilliseconds} ms to resp.");

                // Stable CMD/ANS parsing
                if (result.StartsWith("CMD:", StringComparison.OrdinalIgnoreCase))
                        return (result.Trim());
                
                if (result.StartsWith("ANS:", StringComparison.OrdinalIgnoreCase))
                        return (result.Trim());

                return (result.Trim());
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[AIResp.GetAIResponseAsync] ERROR: {ex.Message}");
                return "ANS: (error)";
            }
        }
    }
}
