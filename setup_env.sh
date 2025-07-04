#!/bin/bash

# Load the animated banner
source ./banner.sh
banner
echo "🛠️  BruteMaster Python Environment Setup Starting..."

# Progress bar function
progress_bar() {
  local total=$1
  local step=$2
  local message="$3"

  echo -n "$message"
  local current=0
  while [ $current -le $total ]; do
    local percent=$(( 100 * current / total ))
    local filled=$(( percent / 2 ))
    local empty=$(( 50 - filled ))
    local bar=$(printf "%${filled}s" | tr ' ' '#')$(printf "%${empty}s" | tr ' ' '-')
    printf "\r[%-50s] %3d%%" "$bar" "$percent"
    sleep $step
    current=$((current + 1))
  done
  echo -e "\n"
}

# Step 1: Check Python version
PYTHON_VERSION=$(python3 --version 2>&1)
echo "🐍 Detected Python: $PYTHON_VERSION"

# Step 2: Create virtual environment if not exists
if [ ! -d ".venv" ]; then
  echo "📁 Creating virtual environment (.venv)..."
  (python3 -m venv .venv &> /dev/null) &
  progress_bar 20 0.05 "🔧 Setting up virtual environment:"
  if [ $? -ne 0 ]; then
    echo "❌ Failed to create .venv. Make sure python3-venv is installed."
    exit 1
  fi
else
  echo "✅ Virtual environment already exists."
fi

# Step 3: Activate the virtual environment
source .venv/bin/activate

# Step 4: Install required packages (hidden output)
echo "📦 Installing Python dependencies..."
(
  pip install --upgrade pip &> /dev/null
  pip install requests tabulate pikepdf --break-system-packages &> /dev/null
) &
progress_bar 20 0.05 "📦 Installing dependencies:"
if [ $? -ne 0 ]; then
  echo "❌ Failed to install dependencies."
  exit 1
fi

# Step 5: Save requirements.txt
pip freeze > requirements.txt
echo "📋 Requirements saved to requirements.txt"

# Step 6: Success message
echo "✅ Environment setup complete. You can now run:"
echo
echo "    source .venv/bin/activate"
echo "    bash brutemaster.sh"
echo

# Step 7: Optional auto-launch
read -p "🚀 Do you want to launch BruteMaster now? (y/n): " launch
if [[ "$launch" =~ ^[Yy]$ ]]; then
  bash brutemaster
fi
