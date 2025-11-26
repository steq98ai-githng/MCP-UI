# AI Agent Development Environment Setup

This document provides a comprehensive guide to setting up a powerful local development environment for creating AI agents that can interact with the Browser MCP server. The setup is tailored for machines with modern NVIDIA GPUs (like the RTX 5060 Ti) and prioritizes the Google AI ecosystem, with Microsoft's AI tools as a strong secondary option.

## Quick Start

1.  **Prerequisites**:
    *   A modern Linux distribution (e.g., Ubuntu 22.04+).
    *   The latest NVIDIA drivers for your GPU.
    *   Python 3.10 or newer.

2.  **Run the setup script**:
    The `setup_ai_environment.sh` script in this repository will guide you through the installation. It is recommended to run it in a fresh terminal session.
    ```bash
    chmod +x setup_ai_environment.sh
    ./setup_ai_environment.sh
    ```
    This script will create a Python virtual environment (`.venv`) and install all the necessary packages inside it.

3.  **Activate the Environment**:
    After the script completes, activate the virtual environment to use the installed packages:
    ```bash
    source .venv/bin/activate
    ```

4.  **Configure API Keys**:
    Follow the instructions at the end of the script to set up your API keys for Google AI and OpenAI (used by some agent frameworks).

## What's Included?

This setup script will install and configure the following key libraries inside the `.venv` virtual environment:

### Google AI Ecosystem (Priority 1)

*   **Google Generative AI SDK (`google-generativeai`)**: The official Python client for the Gemini API, allowing you to easily integrate Google's state-of-the-art models into your applications.
*   **TensorFlow (`tensorflow[and-cuda]`)**: A leading deep learning framework. The `[and-cuda]` extra ensures that it's installed with full GPU acceleration support, automatically handling CUDA and cuDNN dependencies.
    *   **Note**: The first time you run a TensorFlow operation on a new GPU architecture, it may perform a one-time Just-in-Time (JIT) compilation of CUDA kernels, which can take up to 30 minutes. This is normal.
*   **LangChain Google GenAI (`langchain-google-genai`)**: The official LangChain integration for Google's generative models, enabling you to build powerful AI agents and chains with Gemini.

### Microsoft AI Ecosystem (Priority 2)

*   **PyTorch (`torch`)**: A flexible and widely-used deep learning framework, installed with a pre-compiled CUDA toolchain for immediate GPU support.
*   **ONNX Runtime (`onnxruntime-gpu`)**: A high-performance inference engine for running models in the Open Neural Network Exchange (ONNX) format. This is crucial for deploying models across different platforms.
*   **TF2ONNX (`tf2onnx`)**: A utility to convert TensorFlow models to the ONNX format.
*   **Microsoft Autogen (`pyautogen`)**: An innovative framework for creating and orchestrating multi-agent conversational applications, allowing you to build complex systems where multiple AI agents collaborate to solve problems.

## Hardware Configuration Reference

This project was designed with the following hardware in mind, which is an ideal setup for local AI development:
*   **CPU**: AMD Ryzen 7 9700X 8-Core Processor
*   **GPU**: NVIDIA GeForce RTX 5060 Ti (Blackwell Architecture, CUDA Compute Capability 10.0+)

The scripts and configurations are optimized to leverage the full power of this GPU for tasks like model training, fine-tuning, and high-throughput inference.

## Integration with Browser MCP

The primary goal of this environment is to build AI agents that can control and automate a web browser by communicating with the **Browser MCP server**.

### Conceptual Architecture

1.  **AI Agent (Your Code)**: You will write a Python script using frameworks like **LangChain** or **Autogen**. This agent will contain the high-level logic. For example, "log into Gmail and find the latest email from 'John Doe'".
2.  **LLM (e.g., Gemini)**: Your AI agent will use a Large Language Model (LLM) like Google's Gemini to break down the high-level goal into a series of concrete browser actions (e.g., "Navigate to https://gmail.com", "Find the element with `type='email'` and type in the username", "Click the 'Next' button").
3.  **MCP Client**: Your agent will format these actions into **Model Context Protocol (MCP)** commands. It will then act as a client, sending these commands to the Browser MCP server, which is presumably running as a separate process.
4.  **Browser MCP Server**: This server listens for MCP commands. When it receives a command, it translates it into an action that the Chrome extension can understand.
5.  **Chrome Extension**: The extension executes the action in the user's browser (e.g., actually typing the username into the input field). It can also read the state of the web page and send this information back to the server, which can then relay it to your AI agent.

### Example Workflow (using LangChain)

While the exact MCP client implementation details are not in this repository, a typical workflow for your agent's code might look like this:

```python
# main_agent.py - This script runs in the activated .venv environment

import google.generativeai as genai
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.agents import AgentExecutor, create_json_chat_agent
# Hypothetical MCP client library
from browser_mcp_client import BrowserMCPTool

# 1. Configure the LLM
llm = ChatGoogleGenerativeAI(model="gemini-1.5-pro-latest", google_api_key="YOUR_API_KEY")

# 2. Instantiate the tool that connects to the Browser MCP server
# This tool would expose functions like 'click', 'type', 'read_page', etc.
# These functions would, under the hood, send MCP commands to the server.
tools = [BrowserMCPTool(host="localhost", port=12345)]

# 3. Create a LangChain Agent
# The agent uses the LLM to decide which tool function to call.
prompt = # ... (A prompt designed for browser automation)
agent = create_json_chat_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

# 4. Run the agent with a high-level goal
goal = "Go to GitHub, search for the 'Browser-MCP' repository, and open the issues tab."
result = agent_executor.invoke({"input": goal})

print(result)
```

This setup allows you to focus on the agent's logic and goals, while the Browser MCP server and extension handle the low-level details of browser manipulation.
