# STT Project Code Flow Map

Below is a **code-flow**  document.

---

# **1. High-Level Execution Summary**
The STT application forms a processing pipeline:

**Microphone -> SpeechRecognizer -> Recognized Text -> AI (LLM) -> CMD/ANS -> Console**

Optional supporting layers:
- **SearchService** (Azure AI Search for RAG)
- **LangServices** (translation, language utilities)
- **ToolContextProvider** (LLM-exposed functions)

Everything begins with `Program.cs`.

---

# **2. Program.cs: Startup -> Suppl Wiring -> Launch**

### **Main Flow**
1. Load configuration:
   - `ApplicationConf.AppSettingsEntity.Load()` retrieves:
     - Speech key, region
     - OpenAI endpoint and deployment
     - Search settings
     - Language settings

2. Construct service settings:
   - `SpeechConfig`, `AudioConfig`
   - `ChatSettings`, `SearchSettings`, `LangSettings`

3. Initialize runtime services:
   - `AzureChatService` (LLM core)
   - `LangService` (language tools)
   - `SearchService` (current BM25 ,future: vector)
   
      -  Better Matching 25 - similar to Term Frequency-Inverse Document Frequency (TF-IDF) but with improvements.
   https://vishwasg.dev/blog/2025/01/20/bm25-explained-a-better-ranking-algorithm-than-tf-idf/


4. Wire events:
   - Subscribe to `SpeechProcessor.OnRecognized`

5. Begin continuous recognition:
   - Calls: `SpeechProcessor.RecognizeSpeechContinuouslyAsyncEx(...)`

6. Await shutdown:
   - Press enter -> cancel token -> stop recognition

**Program.cs = orchestrator.**

---

# **3. SpeechProcessor.cs: Recognition + Event Dispatch**

### **RecognizeSpeechContinuouslyAsyncEx(...)**
This method performs the real-time loop.

1. Create SpeechRecognizer:
   ```csharp
   var recognizer = new SpeechRecognizer(speechConfig, audioConfig);
   ```

2. Attach recognizer events:
   - **Recognizing** (partial text)
   - **Recognized** (final text)
     - Fires `OnRecognizedEvent(text)`
     - Calls `AIResp.ProcessAIAsync(text)`
   - **Canceled**
   - **SessionStopped**

3. Start:
   - `StartContinuousRecognitionAsync()`

4. Keep running until cancellation token signals stop.

5. Stop:
   - `StopContinuousRecognitionAsync()`

**SpeechProcessor = the "ear" of the system.**

---

# **4. AIResp.cs: LLM Evaluation -> Command or Answer**

### **ProcessAIAsync(text)**
1. Build final prompt: `PromptComposer.ComposeUserPrompt(text)`
2. Query LLM: `chatService.AskAsync(...)`
3. Parse LLM response:
   - If starts with `CMD:` -> extract -> `CmdProcess.ExecuteCommand(cmd)`
   - If starts with `ANS:` -> print answer
   - If neither -> return fallback message

**AIResp = interpreter that decides whether the LLM is answering or taking action.**

---

# **5. ChatServices.cs: Azure OpenAI Gateway**
Handles:
- Crafting chat request payloads
- System and user messages
- Tool invocation plumbing
- Returning AI responses

This class is the "channel" between application and Azure OpenAI.

---

# **6. CmdProcess.cs: Windows Command Executor**

### **CommandExtract(response)**
Extracts the content following `CMD:` prefix.

### **ExecuteCommand(cmd)**
- Launches `cmd.exe` hidden
- Captures stdout and stderr
- Writes back to console

This allows speech to trigger real system changes (safely constrained by  system prompt).

---

# **7. ToolContextProvider.cs: Tooling for the LLM**

Removed from application: failed 

```
Exposes tools the LLM can call.

Examples:
- Search operations
- Translation utilities
- Context lookup helpers
- Keyword extraction

This is the agent tool layer.
```

---

# **8. SearchService.cs: RAG**
If enabled:
1. LLM calls a search tool (ex:, `searchDocs`, `searchVector`)
2. SearchService performs:
   - Vector search
   - Keyword search
   - Document lookup
3. Returns chunks to LLM
4. LLM incorporates retrieved context into its final answer

**SearchService = your RAG librarian.**

---

# **9. LangServices.cs: Multilingual Helpers**
Provides:
- Language detection

_Disabled for this demo._

---

# **10. ApplicationConf.cs: Configuration Loader**
Handles mapping of appsettings to typed objects used by the pipeline.

All service flags (enable/disable features) originate here.

---

# **11. Complete Call Graph (Condensed)**

```
Program.cs
 ├── Load config
 ├── Initialize services
 ├── Configure ToolContextProvider
 ├── Subscribe to SpeechProcessor.OnRecognized
 └── Start -> SpeechProcessor.RecognizeSpeechContinuouslyAsyncEx()
        ├── Recognized(text)
        │      ├── OnRecognizedEvent(text)
        │      └── AIResp.ProcessAIAsync(text)
        │             ├── PromptComposer
        │             ├── chatService.AskAsync
        │             ├── SearchService (RAG)
        │             ├── LangServices
        │             ├── CMD -> CmdProcess.ExecuteCommand
        │             └── ANS -> Console.WriteLine
        ├── Canceled
        └── SessionStopped
```

---
