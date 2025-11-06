/*
 CWinters / Thinkpad T15g Gen 1 / Arizona / AZ / USA
 Purpose: Azure Cognitive Services
 Delivery: Speech to text project using C# 13.0 and .NET 9.0
*/
using Microsoft.CognitiveServices.Speech.Audio;
using System;

namespace stt
{
    /// <summary>
    /// Notification attribute metadata for function updates
    /// Not related to functionality, just for tracking changes.
    /// </summary>
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
        public class NotificationAttribute : Attribute
        {
            public string Notification { get; }
            public string NotificationContext { get; }

            public NotificationAttribute(string notification, string notificationContext)
            {
                Notification = notification;
                NotificationContext = notificationContext;
            }
        }

    /// <summary>
    /// BasicInputDeviceConfig class: Provides a single func to configure audio input device.
    /// Minimal errror handling, can be expanded to list devices and select one.
    /// </summary>
    public static class BasicInputDeviceConfig
    {
        // Setup microphone input with error handling
        public static AudioConfig? SetupMicInput()
        {
            try
            {
                // TODO: Add logic to list available audio input devices and select one if needed
                AudioConfig? audioConfig = AudioConfig.FromDefaultMicrophoneInput();
                return (audioConfig);

            }
            catch (Exception ex)
            {
                Console.WriteLine($"An error occurred while accessing the microphone: {ex.Message}");
                Console.WriteLine("Make sure your microphone is properly connected AND set as the default recording input device.");
            }
            return (null);
        }
    }
}
