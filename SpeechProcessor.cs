/*
 CWinters / Thinkpad T15g Gen 1 / Arizona / AZ / USA
 Purpose: Azure Cognitive Services
 Delivery: Speech to text project using C# 13.0 and .NET 9.0
*/

using Microsoft.CognitiveServices.Speech;
using Microsoft.CognitiveServices.Speech.Audio;

namespace stt
{
    internal class SpeechProcessor
    {
        public static event EventHandler<string>? OnRecognized;

        //Debouncer
        private static DateTime? _lastRecognizedTime = DateTime.MinValue;
        private static readonly TimeSpan RecognizedDebounceWindow = TimeSpan.FromMilliseconds(500);
        private static string? _lastRecognizedText = string.Empty;

        /// <summary>
        /// OnRecognizedEvent invokes the OnRecognized event handlers asynchronously.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="text"></param>
        /// This will be handled by the OnRecognized event subscriber in the main program.
        /// It is used in the RecognizeSpeechContinuouslyAsyncEx() func.
        protected static void OnRecognizedEvent(object? sender, string text)
        {
            EventHandler<string>? handlers = OnRecognized;
            if (handlers == null) return;

            foreach (EventHandler<string> h in handlers.GetInvocationList().Cast<EventHandler<string>>())
            {
                // exec each subscriber on the thread-pool; log errors.
                Task.Run(() =>
                {
                    try { h.Invoke(sender, text); }
                    catch (Exception ex) { Console.WriteLine($"Recognized handler error: {ex.Message}"); }
                });
            }
        }

        /// <summary>
        /// Uses Azure Cognitive Services Speech SDK to synthesize speech from text.
        /// This is the "mouth" function. All call to it should already have an "ear" (micrphone)
        /// </summary>
        /// <param name="text"></param>
        /// <param name="speechConfig"></param>
        /// <returns></returns>
        public static async Task SpeakTextAsync(string text, SpeechConfig speechConfig)
            {
                // Output to default speaker (ears)
                using SpeechSynthesizer? synthesizer = new SpeechSynthesizer(speechConfig);

                // Synthesize speech
                SpeechSynthesisResult? result = await synthesizer.SpeakTextAsync(text);

                //If done, return - else we probably cancelled.
                if (result.Reason == ResultReason.SynthesizingAudioCompleted)
                    //Console.WriteLine($"Speech synthesized for text: {text}");
                    return;

                else if (result.Reason == ResultReason.Canceled)
                {
                    SpeechSynthesisCancellationDetails? cancellation = SpeechSynthesisCancellationDetails.FromResult(result);
                    Console.WriteLine($"Speech synthesis canceled: {cancellation.Reason}");

                    if (cancellation.Reason == CancellationReason.Error)
                    {
                        Console.WriteLine($"Error details: {cancellation.ErrorDetails}");
                        Console.WriteLine("Did you set the speech resource key and region correctly?");
                    }
                }
            }


    /// <summary>
    /// This function recognizes speech continuously and processes recognized text with Azure OpenAI.
    /// </summary>
    /// <param name="speechConfig"></param>
    /// <param name="audioInput"></param>
    /// <param name="chat"></param>
    /// <param name="ct"></param>
    /// <returns></returns>
    /// Pipeline workflow: Thread[Event handler -> Speech -> Azure OpenAI -> Execute/output]
    /// SpeechProcessor -> AIResponder -> AzureChatService
    /// SpeechProcessor -> AIResponder -> (SearchService and AzureChatService)
    /// TODO: All event handlers are in this function, consider refactoring!   
    [Notification("RecognizeSpeechContinuouslyAsyncEx()", " - Currently operational")]
        public static async Task RecognizeSpeechContinuouslyAsyncEx(
                                                                    SpeechConfig speechConfig,
                                                                    AudioConfig audioInput,
                                                                    //SpeechPrg programInstance,
                                                                    AzureChatService chat,
                                                                    SearchService searchService,
                                                                    CancellationToken ct = default)
        {
            // Create a speech recognizer - (mouth)
            using SpeechRecognizer? recognizer = new SpeechRecognizer(speechConfig, "en-US", audioInput);

            //ADDED to test with phrase list grammar. TESTING ONLY - no "noticable" difference
            //PhraseListGrammar ?phraseList = PhraseListGrammar.FromRecognizer(recognizer);
            //phraseList.AddPhrase("jira up");
            //phraseList.AddPhrase("jeera op");

            recognizer.Recognized += async (s, e) =>
            {
                try
                {
                    if (e.Result.Reason == ResultReason.RecognizedSpeech &&
                         !string.IsNullOrEmpty(e.Result.Text))
                    {
                        string? transcript = e.Result.Text;

                        // Debounce repeated recognitions
                        DateTime? now = DateTime.UtcNow;

                        if ((now - _lastRecognizedTime) < RecognizedDebounceWindow &&
                             transcript.Equals(_lastRecognizedText, StringComparison.OrdinalIgnoreCase))
                            // eh, ignore duplicates
                            return;  

                        _lastRecognizedTime = now;
                        _lastRecognizedText = transcript;

                        //Console.WriteLine($"RECOGNIZED: {transcript}");

                        SpeechProcessor.OnRecognizedEvent(s, transcript);

                        // Send transcript to Azure OpenAI pipeline... off we go!
                        //string aiResponse = await AIResponder.GetAIResponseAsync(chat, transcript, ct);
                        string aiResponse = await AIResponder.GetAIResponseAsync(chat, searchService, transcript, ct);

                        Console.WriteLine($"[SpeechProcessor.RecognizeSpeechContinuouslyAsyncEx] AI: {aiResponse}");

                        // command? answer?
                        // If the response starts with "CMD:", treat it as a command

                        if (CmdProcess.CommandExtract(aiResponse, out var cmd))
                        {
                            CmdProcess.ExecuteCommand(cmd);

                            //If you need to speak the command result, uncomment
                            /*
                            await recognizer.StopContinuousRecognitionAsync();  // Overlap issue if speaking while recognizing.
                            await SpeakTextAsync(cmd, speechConfig);            // speak the answer
                            await recognizer.StartContinuousRecognitionAsync(); // restart recognition
                            */
                        }
                        else
                        {
                            // ...anything else as answer
                            await recognizer.StopContinuousRecognitionAsync();  // Overlap issue if speaking while recognizing.
                            await SpeakTextAsync(aiResponse, speechConfig);     // speak the answer
                            await recognizer.StartContinuousRecognitionAsync(); // restart recognition

                            Console.WriteLine($"[SpeechProcessor.RecognizeSpeechContinuouslyAsyncEx] ANS: {aiResponse}");
                        }

                    }
                    else if (e.Result.Reason == ResultReason.NoMatch)
                        Console.WriteLine("NEGATIVE: Huh?! I don't understand you.");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error in Recognized event handler: {ex.Message}");
                }
            };

            recognizer.Canceled += (s, e) =>
            {
                Console.WriteLine($"CANCELED: Reason={e.Reason}");
                if (e.Reason == CancellationReason.Error)
                {
                    Console.WriteLine($"CANCELED: ErrorCode={e.ErrorCode}");
                    Console.WriteLine($"CANCELED: ErrorDetails={e.ErrorDetails}");
                }
            };

            recognizer.SessionStopped += (s, e) => Console.WriteLine("Session stopped.");

            Console.WriteLine("Speak now… (press Enter to stop)");
            await recognizer.StartContinuousRecognitionAsync();
            Console.ReadLine();
            await recognizer.StopContinuousRecognitionAsync();
        }

    }
}
