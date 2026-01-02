| Mermaid Node | C# Equivalent                                                   |
| ------------ | --------------------------------------------------------------- |
| A → B        | `SpeechProcessor` + `SpeechRecognizer` events                   |
| C            | `AIResp.ProcessAIAsync()`                                       |
| D            | Your “response type” logic (CMD, ANS, tool-call, search-call)   |
| E            | `SearchService.VectorQueryAsync()` or Hybrid search             |
| F            | Returned `SearchResult` documents                               |
| G            | Second LLM pass using retrieved context                         |
| H            | LLM returns ANS directly                                        |
| I            | `LangServices` (called directly; ToolContextProvider removed)          |
| Z            | Printed output to console or used by downstream systems         |

COMPONENT CODE:
```
flowchart TB

    %%========================
    %% User Layer
    %%========================
    subgraph UI[User Interaction]
        MIC[ Microphone Input]
        OUT[ Console Output]
    end

    %%========================
    %% Speech Layer
    %%========================
    subgraph SPEECH[Speech Processing Layer]
        SR[Azure Speech SDK<br/>SpeechRecognizer]
        SP[SpeechProcessor.cs]
    end

    %%========================
    %% AI Processing Layer
    %%========================
    subgraph AI[AI Processing Layer]
        AIRESP[AIResp.cs<br/>Intent Resolution]
        PROMPT[PromptComposer.cs<br/>Prompt Builder]
        CHAT[ChatServices.cs<br/>Azure OpenAI Gateway]
    end

    %%========================
    %% Tools / Agent Layer
    %%========================
    subgraph TOOLING[Tool/Utility Layer]
        CMD[CmdProcess.cs<br/>Command Executor]
        LANG[LangServices.cs<br/>Language Tools]
        RAG[SearchService.cs<br/>RAG Retrieval Engine]
    end

    %%========================
    %% Configuration Layer
    %%========================
    subgraph CONFIG[Configuration]
        CONF[ApplicationConf.cs<br/>Settings & Keys]
    end

    %%========================
    %% Flow Connections
    %%========================

    MIC --> SR
    SR --> SP

    SP --> AIRESP

    AIRESP --> PROMPT
    PROMPT --> CHAT

    %% Chat can call tools (direct; ToolContextProvider removed)
    CHAT --> CMD
    CHAT --> LANG
    CHAT --> RAG
    %% RAG returns context to AI models
    RAG --> CHAT

    %% Chat returns final answer
    CHAT --> AIRESP
    AIRESP --> OUT

    %% Config feeds everything
    CONF --> SR
    CONF --> CHAT
    CONF --> RAG
    CONF --> LANG
```

FLOWCHART CODE:
```
flowchart TD

    %% Speech Layer
    A[User Speech Input] --> B[Azure Speech-to-Text<br/>SpeechRecognizer]

    %% Intent Classification (LLM)
    B --> C[GPT-4o-mini<br/>AIResp Intent Processing]

    %% Intent Decision
    C --> D{Intent Type?}

    %% Branch: RAG Query
    D -->|Knowledge / Search Request| E[SearchService<br/>Azure AI Search -RAG-]
    E --> F[Top-K Chunks Retrieved]
    F --> G[GPT-4o-mini<br/>LLM with RAG Context]
 
    %% Branch: Direct Answer
    D -->|General Answer| H[GPT-4o-mini<br/>Direct Response]

    %% Branch: Analysis Tools
    D -->|Sentiment / Keywords / Translation| I[LangServices<br/>Analysis Pipeline]

    %% Merge to final output
    G --> Z[Final Response to User]
    H --> Z
    I --> Z
```

SEQUENCE DIAGRAM CODE:
```
sequenceDiagram
    autonumber

    participant User as User
    participant Speech as SpeechRecognizer<br/>SpeechProcessor
    participant AIResp as AIResp
    participant Prompt as PromptComposer
    participant Chat as ChatServices<br/>Azure OpenAI
    participant Search as SearchService<br/>RAG Engine
    participant Lang as LangServices
    participant Cmd as CmdProcess
    participant Console as Console

    User ->> Speech: Speak phrase
    Speech ->> Speech: Recognize speech (Continuous)
    Speech ->> AIResp: OnRecognized(text)

    AIResp ->> Prompt: Build final prompt
    Prompt -->> AIResp: PromptModel

    AIResp ->> Chat: AskAsync(prompt)
    Chat ->> Chat: Evaluate intent

    alt Search Intent (RAG)
        Chat ->> Search: Query docs (RAG)
        Search ->> Search: Vector / Hybrid Query
        Search -->> Chat: Top-K Results
        
        Chat -->> AIResp: LLM response w/ context
    else Language / Sentiment / Keywords
        Chat ->> Lang: Process text
        Lang ->> Lang: Process text
        Lang -->> Chat: Output
        
        Chat -->> AIResp: Final response
    else General Answer
        Chat -->> AIResp: Direct ANS
    else CMD Execution
        Chat -->> AIResp: CMD:<command>
        AIResp ->> Cmd: ExecuteCommand(command)
        Cmd -->> Console: Output process results
    end

    AIResp ->> Console: Print answer
    Console -->> User: Display response
```

CLASS DIAGRAM CODE:
```
classDiagram
    class SpeechProcessor {
        +StartContinuousRecognitionAsync()
        +StopContinuousRecognitionAsync()
        +OnRecognized(text: string)
    }

    class AIResp {
        +ProcessAIAsync(text: string): string
        -DetermineIntent(text: string): IntentType
        -ExecuteCommand(command: string): string
    }

    class PromptComposer {
        +BuildPromptModel(text: string, context: List<Document>): PromptModel
    }

    class ChatServices {
        +AskAsync(prompt: PromptModel): string
    }    class SearchService {
        +VectorQueryAsync(query: string): List<Document>
    }
    class LangServices {
        +ProcessText(text: string, analysisType: AnalysisType): string
    }
    class CmdProcess {
        +ExecuteCommand(command: string): string
    }
    SpeechProcessor --> AIResp : OnRecognized
    AIResp --> PromptComposer : BuildPromptModel    
    AIResp --> ChatServices : AskAsync
    ChatServices --> SearchService : Vector/Hybrid query
    ChatServices --> LangServices : Translate/Keywords/Sentiment
    AIResp --> CmdProcess : ExecuteCommand
```

CLASS DIAGRAM CODE 2 (TODO Correct these relationships):
```
classDiagram

    class Program {
        +Main()
        -LoadConfig()
    }

    class SpeechProcessor {
        +OnRecognized
        +RecognizeSpeechContinuouslyAsyncEx()
    }

    class AIResp {
        +ProcessAIAsync(text)
    }

    class PromptComposer {
        +ComposeUserPrompt(text)
    }

    class ChatServices {
        +AskAsync(prompt)
        -HandleToolCalls()
    }
    class SearchService {
        +VectorQueryAsync(text)
        +HybridQueryAsync(text)
    }

    class LangServices {
        +Translate(text)
        +DetectLanguage(text)
        +Sentiment(text)
    }

    class CmdProcess {
        +ExecuteCommand(cmd)
        +CommandExtract(text)
    }

    class ApplicationConf {
        +Load()
        speechKey
        openAIKey
        searchIndex
    }

    %% Relationships
    Program --> SpeechProcessor : uses
    Program --> ChatServices : creates
    Program --> LangServices : creates
    Program --> SearchService : creates

    SpeechProcessor --> AIResp : calls
    AIResp --> PromptComposer : uses
    AIResp --> ChatServices : queries LLM
    ChatServices --> SearchService : RAG queries
    ChatServices --> LangServices : language tools
    AIResp --> CmdProcess : invokes on CMD
    ChatServices --> ApplicationConf : config

    ApplicationConf --> Program : provides settings

```

