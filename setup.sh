#!/bin/bash

# Color codes
GREEN='\033[1;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}[*] Welcome to BruteMaster Installer${NC}"
echo

# Ask for GitHub URL
read -p "Enter the GitHub Repository URL (e.g., https://github.com/sankalpvb/BruteMaster): " repo_url

# Validate URL
if [[ -z "$repo_url" ]]; then
  echo -e "${RED}[!] Repository URL cannot be empty.${NC}"
  exit 1
fi

# Clone repo
echo -e "${CYAN}[*] Cloning BruteMaster repository...${NC}"
git clone "$repo_url" BruteMaster || { echo -e "${RED}[!] Git clone failed.${NC}"; exit 1; }

cd BruteMaster || exit

# Rename main file if needed
if [[ ! -f "brutemaster" ]]; then
  mv brutemaster.sh brutemaster 2>/dev/null
fi

# Make main script executable
chmod +x brutemaster

# Install Python requirements
if [[ -f "requirements.txt" ]]; then
  echo -e "${CYAN}[*] Installing Python dependencies...${NC}"
  pip3 install -r requirements.txt || { echo -e "${RED}[!] pip install failed.${NC}"; exit 1; }
else
  echo -e "${YELLOW}[!] No requirements.txt found, skipping pip install.${NC}"
fi

# Move to /usr/local/bin for global use
echo -e "${CYAN}[*] Installing BruteMaster globally...${NC}"
sudo mv brutemaster /usr/local/bin/ || { echo -e "${RED}[!] Failed to move file. Are you root?${NC}"; exit 1; }

# Optional: keep source files for future development
read -p "Do you want to keep the cloned BruteMaster folder? (y/n): " keep_src
if [[ "$keep_src" != "y" && "$keep_src" != "Y" ]]; then
  cd ..
  rm -rf BruteMaster
fi

# Done
echo -e "\n${GREEN}[✓] BruteMaster installed successfully!${NC}"
echo -e "${CYAN}You can now run it using: ${GREEN}brutemaster${NC}"
echo -e "${CYAN}Try: ${NC}brutemaster --help"
