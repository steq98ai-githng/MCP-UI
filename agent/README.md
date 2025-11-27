# AI Agent for Browser MCP

[繁體中文說明 (Traditional Chinese Readme)](./README.zh-TW.md)

---

This directory contains the Python-based AI agent designed to interact with the Browser MCP (Model Context Protocol) server. The agent uses Google's Gemini Pro model to process information and decide on actions to be executed in the browser.

## Functionality

The primary role of this agent is to act as the "brain" for browser automation. It uses a persistent WebSocket connection to communicate with the Browser MCP server in real-time.

1.  **Connects** to the Browser MCP server using the WebSocket protocol (`ws://`).
2.  **Receives** messages (representing browser context or tasks) from the server.
3.  **Processes** each message using the Google Gemini AI to determine the appropriate next action.
4.  **Sends** the AI-generated action back to the server as a response.
5.  **Listens** continuously for new messages in an asynchronous loop.

## Configuration

Before running the agent, you need to configure your Google AI API key.

1.  **Obtain a Google AI API Key**: If you don't have one, you can get it from the [Google AI Studio](https://aistudio.google.com/app/apikey).

2.  **Set the Environment Variable**: The agent reads the API key from an environment variable named `GOOGLE_API_KEY`. You need to set this variable in your terminal session.

    **On Linux/macOS:**
    ```bash
    export GOOGLE_API_KEY="YOUR_API_KEY_HERE"
    ```

    **On Windows (Command Prompt):**
    ```bash
    set GOOGLE_API_KEY="YOUR_API_KEY_HERE"
    ```

    **On Windows (PowerShell):**
    ```powershell
    $env:GOOGLE_API_KEY="YOUR_API_KEY_HERE"
    ```

    Replace `"YOUR_API_KEY_HERE"` with your actual API key.

## How to Run

1.  **Activate the Virtual Environment**: Make sure you have activated your Python virtual environment.

    ```bash
    source .venv/bin/activate
    ```

2.  **Install Dependencies**: This agent requires additional Python packages. Install them using pip:

    ```bash
    pip install google-generativeai websockets
    ```

3.  **Run the Agent**: Navigate to the project's root directory and run the `main.py` script from the `agent` directory.

    ```bash
    python agent/main.py
    ```

    You can also specify the address of the MCP server if it's not running on the default location. Note that the agent now expects a WebSocket address (starting with `ws://`).
    ```bash
    python agent/main.py --mcp_server "ws://your_server_address:port"
    ```

## Future Development

This script provides a solid foundation for the AI agent. Future enhancements could include:

-   **More Sophisticated Prompts**: Developing structured and context-aware prompts for the Gemini model to handle complex tasks more reliably.
-   **Error Handling**: Improving the error handling for both network issues and AI model failures.
-   **State Management**: Implementing a mechanism for the agent to maintain state across multiple interactions.
-   **Configuration File**: Moving settings like the server address and model name to a dedicated configuration file.
