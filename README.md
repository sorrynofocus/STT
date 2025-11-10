# Simplistic Speech-to-Text and AI Assistant Application

**Project:** STT <BR>
**Codename:** function_0 <BR>
**Method:** Cloud<BR>
**Lang/Dev Env:** C#, .NET 9.0 - Visual Studio 2022.


## Introduction

I’ve decided to get more serious about AI development, and this project marks my first _working cloud_ deployment. I chose Azure because I recently earned my Microsoft AI-900 certification and have been exploring both Azure and Foundry. There’s a lot to learn, especially around responsible AI practices.

For the first stage of this project, I wanted to start with Speech-to-Text (STT) using Azure OpenAI since it’s both practical and fun to work with.

I also experiment with local large language models using OpenWebUI, Python, and LLaMA, connected through a Twingate VPN backend so I can access them remotely. Hugging Face is another platform I really enjoy exploring!

This project represents my shift toward cloud-based AI development to gain stronger enterprise-level experience.


This application is a **voice-operated assistant** that integrates **Azure Cognitive Services** and **Azure OpenAI** to provide speech-to-text 
transcription, natural language understanding, and respond to queries or execute commands. The end user will give utterances, it is then transcribed, sent to a model, and determines if it should **answer** ("What is 6 + 2?!") or **execute a command** on the local system ("Open task manager!")

In this project, I’ll be separating new features into individual branches to make it easier for others to follow the progression. I’ve often found myself spending a lot of time reading through large amounts of uncommented or undocumented code, so my goal here is to make the development process clearer. By separating features into branches, it’s easier to see how the project builds up step by step.



## Technologies Used
- **Azure Cognitive Services Speech SDK**: For speech-to-text transcription and text-to-speech synthesis.
- **Azure OpenAI Service**: For natural language understanding and generating responses.
- **.NET9.0**: Application framework.
- **Newtonsoft.Json**: For configuration management and JSON serialization.
- **Azure Language SDK**: For interacting with Azure services; sentiment analysis, keyphrase extraction. (Added 2025/11/09)


## Architecture Overview
### ...and future pipeline flow
![Pipeline](./img/pipeline/pipelineflow-2025-01-13-1802.png)

### Current Pipeline Flow
This is _somewhat_ similar to the image above, but with some differences. The start of the project's flow is as follows:

1. **Speech-to-Text**:
- The application captures audio input from the microphone.
- Azure Cognitive Services transcribes the audio into text.

2. **Natural Language Understanding**:
- The transcribed text is sent to Azure OpenAI for processing.
- Azure OpenAI generates a response or command based on the input.

3. **Queries/Command Execution**:
- If the response is a command (example: " List all drives under current directory" or "Open notepad"), the application executes it.
- If the response is an answer to query, it is displayed to the user.


## Future Enhancements
1. **Text To Speech AI responses**:
 - Play synthesized audio responses directly through the system's device output.

2. **Keyword Spotting**:
 - Implement keyword spotting to trigger specific actions based on recognized phrases ("Hey Assistant! Do X!").

3. **Interrupt Handling**:
 - Allow users to interrupt the assistant's speech or processing by detecting new audio input and stopping current operations.

4. **Sentiment Analysis and Keyphrase Extraction**:
 - Integrate Azure Language SDK for advanced text analytics, including sentiment analysis and keyphrase extraction.



## Azure Setup

To get all of this to work, you'll need to set up Azure services: Azure Cognitive Services for Speech and Azure OpenAI Service. Once these are set up, you'll need to deploy a model in Azure OpenAI and get the necessary keys and endpoints.

Finally, in the application, you'll need to configure the keys and endpoints for both services. After compilation, the application will now use the services and models you've set up in Azure.

  > Note: Embedding the keys directly in the code is not recommended for production applications. Consider using secure configuration management practices. This is done here for simplicity and demonstration purposes.

### Azure Speech Services

1. **Create a Speech Service Resource**:
 - Go to the [Azure Portal](https://portal.azure.com).
 - Search for "Speech" and create a new Speech Service resource.
 - Note the **key**, **region**, and **endpoint**.

2. **Enable Speech-to-Text and Text-to-Speech**:
 - Ensure both transcription and synthesis capabilities are enabled.

### Azure OpenAI Service
1. **Create an Azure OpenAI Resource**:
 - Go to the [Azure Portal](https://portal.azure.com).
 - Search for "Azure OpenAI" and create a new resource.
 - Note the **key**, **endpoint**, and **deployment name**.

2. **Deploy a Model**:
 - In the Azure OpenAI resource, deploy a model like `gpt-4-mini` or `gpt-3.5-turbo`.
 - Note the deployment name for use in the application.

 ### Create Language Service Resource (Added 2025/11/09)
1. **Create an Azure Language Resource**:
 - Go to the [Azure Portal](https://portal.azure.com).
 - Search for "Language" and create a new Language Service resource.
 - Note the **key**, **region**, and **endpoint**.



## Application Build Instructions


Under each branch will give details on building the project.

##  Active Branches
| Branch | Description |
|---------|-------------|
| `main` | README.md (your project intro, branching policy, etc.) |
| `feature/winters/init-working-commit` | Initial commit, first working build |
| `feature/winters/lang-srvc-analysis` | Language service analysis -this branch is from `feature/winters/init-working-commit` |
| -- | -- |




