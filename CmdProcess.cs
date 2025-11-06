/*
 CWinters / Thinkpad T15g Gen 1 / Arizona / AZ / USA
 Purpose: Azure Cognitive Services
 Delivery: Speech to text project using C# 13.0 and .NET 9.0
*/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static stt.SpeechPrg;

namespace stt
{
    /// <summary>
    /// CmdProcess class handles command extraction and execution from AI responses.
    /// The process execution is simple, but effective for this experimentation.
    /// </summary>
    internal class CmdProcess
    {
        // This function attempts to extract a command from the AI response.
        [Notification("CommandExtract()", " - Currently operational")]
        public static bool CommandExtract(string? aiText, out string? cmd)
        {
            cmd = "";

            if (string.IsNullOrWhiteSpace(aiText)) return false;

            string? trimmedAiText = aiText.Trim();

            if (trimmedAiText.StartsWith("CMD:", StringComparison.OrdinalIgnoreCase))
            {
                cmd = trimmedAiText.Substring(4).Trim();

                return (!string.IsNullOrWhiteSpace(cmd));
            }
            return (false);
        }

        //Crude but effective ~fire~ process starter.
        [Notification("ExecuteCommand()", " - Currently operational")]
        public static void ExecuteCommand(string? command)
        {
            try
            {
                System.Diagnostics.Process? process = new System.Diagnostics.Process
                {
                    StartInfo = new System.Diagnostics.ProcessStartInfo
                    {
                        FileName = "cmd.exe",
                        Arguments = $"/C {command}",
                        RedirectStandardOutput = true,
                        RedirectStandardError = true,
                        UseShellExecute = false,
                        CreateNoWindow = true
                    }
                };

                process.Start();
                string? stdout = process.StandardOutput.ReadToEnd();
                string? stderr = process.StandardError.ReadToEnd();
                process.WaitForExit();

                if (!string.IsNullOrWhiteSpace(stdout)) Console.WriteLine(stdout);
                if (!string.IsNullOrWhiteSpace(stderr)) Console.WriteLine("STDERR:\n" + stderr);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error executing cmd: {ex.Message}");
            }
        }
    }
}
