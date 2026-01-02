using Azure; // TextAnalyticsClient, DocumentSentiment
using Azure.AI.OpenAI;
using Azure.AI.TextAnalytics; // TextAnalyticsClient, DocumentSentiment
using System.ClientModel;


// https://learn.microsoft.com/en-us/dotnet/api/azure.ai.textanalytics.textanalyticsclient?view=azure-dotnet
namespace stt
{

    [Notification("Class LanguageService()", " - Currently in development")]
    public sealed class LanguageService
    {
        private readonly TextAnalyticsClient _lang;

        public LanguageService(LangSettings settings)
        {
            if (string.IsNullOrWhiteSpace(settings.LangEndpoint)) throw new ArgumentException("Missing endpoint.");
            if (string.IsNullOrWhiteSpace(settings.LangApiKey)) throw new ArgumentException("Missing API key.");


            AzureOpenAIClient? client = new AzureOpenAIClient(new Uri(settings.LangEndpoint),
                                                              new ApiKeyCredential(settings.LangApiKey));

            _lang = new TextAnalyticsClient(new Uri(settings.LangEndpoint), new AzureKeyCredential(settings.LangApiKey));
        }

        /// <summary>
        /// DetectLanguage is a func that detects the language of the input text.
        /// </summary>
        /// <param name="inputText"></param>
        /// <returns></returns>
        [Notification("DetectLanguage()", " - Currently in development -needs improvement")]
        public string DetectLanguage (string? inputText)
        {
            Response<DetectedLanguage>? response = _lang.DetectLanguage(inputText);
            return (response.Value.Name);
        }


        /// <summary>
        /// Analyzes sentiment of input text.
        /// </summary>
        /// <param name="inputText"></param>
        /// <returns>DocumentSentiment - sentiment, confidence scores.</returns>
        /// <exception cref="ArgumentException"></exception>
        [Notification("AnalyzeSentiment()", " - Currently in development -needs improvement")]
        public DocumentSentiment AnalyzeSentiment(string? inputText)
        {
            if (string.IsNullOrWhiteSpace(inputText)) throw new ArgumentException("Input text empty - problem with transcription or txt input!");
            
            DocumentSentiment documentSentiment = _lang.AnalyzeSentiment(inputText);
            Console.WriteLine($"Sentiment: {documentSentiment.Sentiment}");
            Console.WriteLine($"Positive: {documentSentiment.ConfidenceScores.Positive}, Neutral: {documentSentiment.ConfidenceScores.Neutral}, Negative: {documentSentiment.ConfidenceScores.Negative}");

            return (documentSentiment);
        }

        /// <summary>
        /// Extract key phrases from input text.
        /// </summary>
        /// <param name="inputText"></param>
        /// <returns>KeyPhraseCollection - IList<string> </returns>
        /// <exception cref="ArgumentException"></exception>
        [Notification("ExtractKeyPhrases()", " - Currently in development -needs improvement")]
        public KeyPhraseCollection ExtractKeyPhrases (string? inputText)
        {
            if (string.IsNullOrWhiteSpace(inputText)) throw new ArgumentException("Input text empty - problem with transcription or txt input!");
            Response<KeyPhraseCollection>? response = _lang.ExtractKeyPhrases(inputText);
            return (response.Value);
        }

    }
}
