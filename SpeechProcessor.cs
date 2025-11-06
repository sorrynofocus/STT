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
        /// This function recognizes speech continuously and processes recognized text with Azure OpenAI.
        /// </summary>
        /// <param name="speechConfig"></param>
        /// <param name="audioInput"></param>
        /// <param name="chat"></param>
        /// <param name="ct"></param>
        /// <returns></returns>
        /// Pipeline workflow: Thread[Event handler -> Speech -> Azure OpenAI -> Execute/output]
        /// TODO: All event handlers are in this function, consider refactoring!   
        [Notification("RecognizeSpeechContinuouslyAsyncEx()", " - Currently operational")]
        public static async Task RecognizeSpeechContinuouslyAsyncEx(
                                                                    SpeechConfig speechConfig,
                                                                    AudioConfig audioInput,
                                                                    //SpeechPrg programInstance,
                                                                    AzureChatService chat,
                                                                    CancellationToken ct = default)
        {
            using SpeechRecognizer? recognizer = new SpeechRecognizer(speechConfig, audioInput);

            recognizer.Recognized += async (s, e) =>
            {
                if (e.Result.Reason == ResultReason.RecognizedSpeech &&
                     !string.IsNullOrEmpty(e.Result.Text))
                {
                    string transcript = e.Result.Text;

                    //Console.WriteLine($"RECOGNIZED: {transcript}");

                    //programInstance.OnRecognized?.Invoke(s, transcript);
                    SpeechProcessor.OnRecognizedEvent(s, transcript);

                    // Send transcript to Azure OpenAI pipeline... off we go!
                    string aiResponse = await AIResponder.GetAIResponseAsync(chat, transcript, ct);

                    Console.WriteLine($"AI: {aiResponse}");

                    // command? answer?
                    // If the response starts with "CMD:", treat it as a command
                    if (CmdProcess.CommandExtract(aiResponse, out var cmd))
                        CmdProcess.ExecuteCommand(cmd);
                    else
                        // ...anything else as answer
                        Console.WriteLine($"ANS: {aiResponse}");
                }
                else if (e.Result.Reason == ResultReason.NoMatch)
                    Console.WriteLine("NEGATIVE: Huh?! I don't understand you.");
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
