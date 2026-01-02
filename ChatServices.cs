/*
 CWinters / Thinkpad T15g Gen 1 / Arizona / AZ / USA
 Purpose: Azure Cognitive Services
 Delivery: Speech to text project using C# 13.0 and .NET 9.0
*/
using Azure;
using Azure.AI.OpenAI;          // AzureOpenAIClient, ChatClient, ChatMessage, not OpenAI but Azure OpenAI!
using Azure.AI.TextAnalytics;
using OpenAI.Chat;
using System;
using System.ClientModel;       // ApiKeyCredential  (note: this is *not* AzureKeyCredential)

namespace stt
{
    [Notification("Class AzureChatservices()", " - Currently operational")]
    public sealed class AzureChatService
    {
        private readonly ChatClient _chat;
        private readonly LanguageService _languageService;
        private readonly SearchService _searchRetriever;

        public AzureChatService(ChatSettings settings, LanguageService? languageService, SearchService? searchRetriever)
        {
            if (string.IsNullOrWhiteSpace(settings.Endpoint)) throw new ArgumentException("Missing endpoint.");
            if (string.IsNullOrWhiteSpace(settings.ApiKey)) throw new ArgumentException("Missing API key.");
            if (string.IsNullOrWhiteSpace(settings.Deployment)) throw new ArgumentException("Missing deployment name.");


            AzureOpenAIClient? client = new AzureOpenAIClient(new Uri(settings.Endpoint),
                                                               new ApiKeyCredential(settings.ApiKey));

            _chat = client.GetChatClient(settings.Deployment);

            _languageService = languageService ?? throw new ArgumentNullException(nameof(languageService));
            _searchRetriever = searchRetriever ?? throw new ArgumentNullException(nameof(searchRetriever));
        }

        // This function sends messages to the chat model and returns the response text.
        // TODO: move out ChatCompletionOptions as parameters?
        [Notification("CompleteAsync()", " - Currently operational")]
        public async Task<string> CompleteAsync( IEnumerable<ChatMessage> messages,
                                                 ChatCompletionOptions? options = null,
                                                 CancellationToken ct = default
                                                )
        {
            try
            {
                options ??= new ChatCompletionOptions
                {
                    Temperature = 0.3f,
                    PresencePenalty = 0,
                    FrequencyPenalty = 0,
                    //MaxOutputTokenCount = 500
                };


                ClientResult<ChatCompletion>? resp = await _chat.CompleteChatAsync(messages, options, ct);
                string? content = resp.Value.Content.LastOrDefault()?.Text;

                //DISABLED: Language analysis examples checking for performance!
                //if (!string.IsNullOrWhiteSpace(content))
                //{
                //    // Example: Detect language
                //    string detectedLanguage = _languageService.DetectLanguage(content);
                //    Console.WriteLine($"Detected Language: {detectedLanguage}");

                //    // Example: Analyze sentiment
                //    DocumentSentiment sentiment = _languageService.AnalyzeSentiment(content);
                //    Console.WriteLine($"Sentiment: {sentiment.Sentiment}");

                //    // Example: Extract key phrases
                //    KeyPhraseCollection keyPhrases = _languageService.ExtractKeyPhrases(content);
                //    Console.WriteLine("Key Phrases: " + string.Join(", ", keyPhrases));
                //}

                return (string.IsNullOrWhiteSpace(content) ? "(Empty response.)"
                        : content.Trim());
            }
            catch (OperationCanceledException)
            {
                return ("[Canceled]");
            }
            catch (Exception ex)
            {
                return ($"[Error] {ex.Message}");
            }
        }


        //This function system contracts (prompt) and user contract, build msgs, and call CompleteAsync()
        [Notification("AskAsync()", " - Currently operational")]
        public Task<string> AskAsync(string systemPrompt,
                                      string userPrompt,
                                      CancellationToken ct = default)
        {
            List<ChatMessage>? msgs = BuildMessages(systemPrompt, userPrompt);

            // return the response from CompleteAsync()
            //The msgs will be in format of /SystemChatMessage, UserChatMessage/
            return (CompleteAsync(msgs, null, ct));
        }

        //This function builds the message list for the soon-to-be deployed chat model.
        // returns a List of ChatMessageS
        [Notification("BuildMessages()", " - Currently operational")]
        public static List<ChatMessage> BuildMessages(string systemPrompt,
                                                       string userPrompt,
                                                       IEnumerable<ChatMessage>? history = null)
        {
            var messages = new List<ChatMessage>();

            if (!string.IsNullOrWhiteSpace(systemPrompt))
                messages.Add(new SystemChatMessage(systemPrompt));

            if (history != null) messages.AddRange(history);

            messages.Add(new UserChatMessage(userPrompt));
            return (messages);
        }
    }

}
