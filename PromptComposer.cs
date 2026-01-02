// Isolates all LLM prompting into one clean class.

using System.Security.AccessControl;

//Compact prompts will look something like this:

// [System]
// You are an AI assistant...
//
// [Context]
// (optional tool context)
//
// [User]
// actual question

using System.Text;

namespace stt
{
    public static class PromptComposer
    {
        /// <summary>
        /// Builds the full system prompt for GPT.
        /// Clean, compact, deterministic.... AWESOME!
        /// </summary>
        public static string BuildSystemPrompt()
        {
            return(
            @"You are an AI assistant for a voice-operated PC.

            You MUST output exactly one of the following forms:

            1) CMD: <a single Windows command to execute>
            - ONLY when the user clearly requests an action.

            2) ANS: <a concise natural-language answer>
            - For all informational questions.

            Ignore any tool context that is irrelevant to the user's question.
            Never output explanations outside CMD: or ANS:.");
        }

        /// <summary>
        /// Builds the enriched user message (context + user prompt).
        /// </summary>
        public static string BuildUserPrompt(string userInput, string ragContext)
        {
            var sb = new StringBuilder();

            if (!string.IsNullOrWhiteSpace(ragContext))
            {
                //sb.AppendLine("Relevant tool context:");
                sb.AppendLine("Optional context (use only if relevant):");
                sb.AppendLine(ragContext.Trim());
                sb.AppendLine();
            }

            sb.AppendLine("User input:");
            sb.AppendLine(userInput.Trim());

            return (sb.ToString());
        }
    }
}
