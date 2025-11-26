#!/bin/bash
#
# AI Development Environment Setup Script
#
# This script installs the necessary Python packages for a comprehensive AI
# development environment, focusing on Google and Microsoft ecosystems.
# It automatically creates and uses a Python virtual environment (.venv).
#
# Prerequisites:
# - A modern Linux distribution (e.g., Ubuntu 22.04+)
# - NVIDIA Driver already installed
# - Python 3.10+ and pip

# --- Configuration ---
VENV_DIR=".venv"
PYTHON_CMD="python3"
PYTORCH_CUDA_VERSION="cu121"

# --- Helper Functions ---
print_info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

print_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

print_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
    exit 1
}

# --- Pre-flight Checks ---
print_info "Starting AI development environment setup..."

# Check for Python 3.10+
if ! $PYTHON_CMD -c 'import sys; assert sys.version_info >= (3, 10)' &>/dev/null; then
    print_error "Python 3.10 or higher is required. Please upgrade your Python version."
fi

# Check for venv module
if ! $PYTHON_CMD -m venv -h &>/dev/null; then
    print_error "The 'venv' module is not available. Please install the python3-venv package (e.g., 'sudo apt install python3.11-venv')."
fi

print_info "Prerequisites met. Proceeding with installation."

# --- Virtual Environment Setup ---
if [ -d "$VENV_DIR" ]; then
    print_warning "Virtual environment '$VENV_DIR' already exists. Skipping creation."
else
    print_info "Creating Python virtual environment in '$VENV_DIR'..."
    $PYTHON_CMD -m venv $VENV_DIR
    if [ $? -ne 0 ]; then
        print_error "Failed to create virtual environment."
    fi
fi

print_info "Activating virtual environment..."
source $VENV_DIR/bin/activate

# --- Installation ---

# Upgrade pip
print_info "Upgrading pip in the virtual environment..."
pip install --upgrade pip

# Install Google AI Ecosystem
print_info "Installing Google AI Ecosystem packages..."
pip install --upgrade google-generativeai
pip install 'tensorflow[and-cuda]'
pip install langchain-google-genai

# Install Microsoft AI Ecosystem
print_info "Installing Microsoft AI Ecosystem packages..."
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/${PYTORCH_CUDA_VERSION}
pip install onnxruntime-gpu
pip install tf2onnx
pip install pyautogen

# --- Post-installation ---
print_success "All packages have been installed successfully into the '$VENV_DIR' virtual environment!"
echo ""
print_info "Next Steps:"
echo "1. Activate the virtual environment in your shell to use these packages:"
echo "   source $VENV_DIR/bin/activate"
echo "2. Get your Google AI API Key from Google AI Studio."
echo "3. Set it as an environment variable or configure it in your scripts:"
echo "   export GOOGLE_API_KEY='YOUR_API_KEY'"
echo "4. For OpenAI models used in Autogen, set the OpenAI API Key:"
echo "   export OPENAI_API_KEY='YOUR_OPENAI_KEY'"
echo ""
print_warning "Remember: The first time you use TensorFlow on your GPU, it may take a long time (up to 30+ minutes) to compile the CUDA kernels. This is a one-time process."
echo ""
print_info "Setup complete. Happy coding!"
