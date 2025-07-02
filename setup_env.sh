#!/bin/bash

echo "🛠️  BruteMaster Python Environment Setup Starting..."

# Step 1: Check Python version
PYTHON_VERSION=$(python3 --version 2>&1)
echo "🐍 Detected Python: $PYTHON_VERSION"

# Step 2: Create virtual environment if not exists
if [ ! -d ".venv" ]; then
  echo "📁 Creating virtual environment (.venv)..."
  python3 -m venv .venv
  if [ $? -ne 0 ]; then
    echo "❌ Failed to create .venv. Make sure python3-venv is installed."
    exit 1
  fi
else
  echo "✅ Virtual environment already exists."
fi

# Step 3: Activate the virtual environment
source .venv/bin/activate

# Step 4: Install required packages
echo "📦 Installing Python dependencies..."
pip install --upgrade pip
pip install requests tabulate pikepdf --break-system-packages

# Step 5: Save requirements.txt
pip freeze > requirements.txt
echo "📋 Requirements saved to requirements.txt"

# Step 6: Success message
echo "✅ Environment setup complete. You can now run:"
echo
echo "    source .venv/bin/activate"
echo "    bash brutemaster.sh"
echo

# Optional: Auto-run brutemaster?
read -p "🚀 Do you want to launch BruteMaster now? (y/n): " launch
if [[ "$launch" =~ ^[Yy]$ ]]; then
  bash brutemaster
fi
