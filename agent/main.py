import os
import google.generativeai as genai
import argparse
import asyncio
import websockets

# --- Configuration ---
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")

# --- Argument Parsing ---
def parse_arguments():
    """Parses command-line arguments."""
    parser = argparse.ArgumentParser(description="AI Agent for Browser MCP")
    # The server address should use the WebSocket protocol (ws://)
    parser.add_argument("--mcp_server", default="ws://localhost:9002",
                        help="The WebSocket address of the Browser MCP server.")
    return parser.parse_args()

# --- AI Model Initialization ---
def initialize_ai_model():
    """Initializes the Google Gemini model."""
    if not GOOGLE_API_KEY:
        raise ValueError("GOOGLE_API_KEY environment variable not set.")

    genai.configure(api_key=GOOGLE_API_KEY)
    model = genai.GenerativeModel('gemini-pro')
    return model

# --- Core Agent Logic ---
async def agent_loop(server_address, model):
    """Connects to the MCP server and enters the main processing loop."""
    print(f"Attempting to connect to MCP server at {server_address}...")
    try:
        async with websockets.connect(server_address) as websocket:
            print("Connection established. Agent is running and waiting for messages.")

            # Main loop to process messages
            async for message in websocket:
                print(f"< Received from server: {message}")

                # Use the AI model to generate a response
                try:
                    # This is a simple prompt for demonstration purposes.
                    # A more complex implementation would involve structured prompts.
                    prompt = f"Based on the following browser context, what is the next logical action? Context: {message}"
                    response = model.generate_content(prompt)
                    ai_response = response.text

                    print(f"> Sending to server: {ai_response}")
                    await websocket.send(ai_response)

                except Exception as e:
                    error_message = f"Error processing message with AI model: {e}"
                    print(error_message)
                    # Optionally, send an error message back to the server
                    await websocket.send(f"Error: {error_message}")

    except websockets.exceptions.ConnectionClosed as e:
        print(f"Connection closed unexpectedly: {e}")
    except ConnectionRefusedError:
        print(f"Connection refused. Is the MCP server running at {server_address}?")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

# --- Main Execution ---
async def main():
    """Main asynchronous function to run the AI agent."""
    args = parse_arguments()

    print("Initializing AI agent...")

    try:
        model = initialize_ai_model()
        print("Google Gemini model initialized successfully.")
    except ValueError as e:
        print(f"Error initializing AI model: {e}")
        return

    await agent_loop(args.mcp_server, model)
    print("Agent has shut down.")

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nAgent shut down by user.")
