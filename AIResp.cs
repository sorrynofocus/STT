/*
 CWinters / Thinkpad T15g Gen 1 / Arizona / AZ / USA
 Purpose: Azure Cognitive Services. Using the Azure Cognitive
          Services Speech SDK and Azure OpenAI SDK.
 Delivery: Speech to text project using C# 13.0 and .NET 9.0
*/

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
        //Keep format <string> + <string> + ...
        //If giving bullet points, they're same as any toher:
        // <string>  + <string bullet points> \n"
        private const string SystemContract =
            "You are an AI assistant for a voice-operated PC. " +
            "You MUST output exactly one of the following forms:\n" +
            "1) CMD: <a single Windows command to execute>\n" +
            "2) ANS: <a concise answer>\n" +
            "Never include explanations outside those forms.";

        /// <summary>
        /// Gets AI response from AzureChatService based on the provided prompt.
        /// lambda calls AskAsync() from AzureChatService() class with a fixed system contract.
        /// </summary>
        /// <param name="chat"></param>
        /// <param name="prompt"></param>
        /// <param name="ct"></param>
        /// <returns></returns>
        public static Task<string> GetAIResponseAsync(AzureChatService chat,
                                                      string prompt,
                                                      CancellationToken ct = default)
                                                      => chat.AskAsync(SystemContract, prompt, ct);
    }
}
