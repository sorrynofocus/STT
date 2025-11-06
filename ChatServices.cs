/*
 CWinters / Thinkpad T15g Gen 1 / Arizona / AZ / USA
 Purpose: Azure Cognitive Services
 Delivery: Speech to text project using C# 13.0 and .NET 9.0
*/
using OpenAI.Chat;
using Azure;
using Azure.AI.OpenAI;          // AzureOpenAIClient, ChatClient, ChatMessage, not OpenAI but Azure OpenAI!
using System;
using System.ClientModel;       // ApiKeyCredential  (note: this is *not* AzureKeyCredential)

namespace stt
{
    [Notification("Class AzureChatservices()", " - Currently operational")]
    public sealed class AzureChatService
    {
        private readonly ChatClient _chat;

        public AzureChatService(ChatSettings s)
        {
            if (string.IsNullOrWhiteSpace(s.Endpoint)) throw new ArgumentException("Missing endpoint.");
            if (string.IsNullOrWhiteSpace(s.ApiKey)) throw new ArgumentException("Missing API key.");
            if (string.IsNullOrWhiteSpace(s.Deployment)) throw new ArgumentException("Missing deployment name.");

            AzureOpenAIClient? client = new AzureOpenAIClient(new Uri(s.Endpoint),
                                                               new ApiKeyCredential(s.ApiKey)
                                                             );
            _chat = client.GetChatClient(s.Deployment);
        }

        // This function sends messages to the chat model and returns the response text.
        // TODO: move out ChatCompletionOptions as parameters?
        [Notification("CompleteAsync()", " - Currently operational")]
        public async Task<string> CompleteAsync(
                                                IEnumerable<ChatMessage> messages,
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

                return (string.IsNullOrWhiteSpace(content) ? "(Empty response.)"
                        : content.Trim());
            }
            catch (OperationCanceledException)
            {
                return "[Canceled]";
            }
            catch (Exception ex)
            {
                return $"[Error] {ex.Message}";
            }
        }

        //This function builds the messages and calls CompleteAsync()
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
