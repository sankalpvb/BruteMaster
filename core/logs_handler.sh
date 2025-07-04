#!/bin/bash

LOG_DIR="logs"
LOG_ENABLED=false
LOG_FILE=""

# BruteMaster Banner Function
log_banner() {
  clear
  echo -e "\e[1;32m"  # Green start

  # Top border with dashes
  echo "--------------------------------------------------------------------------------------------------"

  # ASCII art lines framed with | and padded to 80 chars total width
  echo "| ██████╗ ██████╗ ██╗   ██╗████████╗███████╗███╗   ███╗ █████╗ ███████╗████████╗███████╗██████╗  |"
  echo "| ██╔══██╗██╔══██╗██║   ██║╚══██╔══╝██╔════╝████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗ |"
  echo "| ██████╔╝██████╔╝██║   ██║   ██║   █████╗  ██╔████╔██║███████║███████╗   ██║   █████╗  ██████╔╝ |"
  echo "| ██╔══██╗██╔══██╗██║   ██║   ██║   ██╔══╝  ██║╚██╔╝██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗ |"
  echo "| ██████╔╝██║  ██║╚██████╔╝   ██║   ███████╗██║ ╚═╝ ██║██║  ██║███████║   ██║   ███████╗██║  ██║ |"
  echo "| ╚═════╝ ╚═╝  ╚═╝ ╚═════╝    ╚═╝   ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝ |"

  # Blank line with borders
  echo "|                                                                              			 |"

  # Info lines with cyan color, framed
  echo -e "\e[0;36m|        	🔐 BruteMaster | A Bash-based Brute-Force Framework                  		 |"
  echo "|        	🐾 Created by CrazyCat | Learn. Build. Break. Secure.               		 |"
  echo "| ---------------------------------------------------------------------------------------------- |"

  # Guidelines in yellow framed inside
  echo -e "\e[0;33m| Guidelines:                                                             	          	 |"
  echo "| - 🚫 Do NOT target military, government, or banking websites!           		         |"
  echo "| - ✅ Only use on systems you OWN or have explicit permission for.    		         	 |"
  echo "| - 📚 Tool is for ethical hacking and educational purposes only.         		         |"

  # Bottom border
  echo "--------------------------------------------------------------------------------------------------"
  echo -e "\e[0;36m| USEFULL COMMANDS	1. show Modules		2. show options "

  # Reset color
  echo -e "\e[0m"
}

logs_menu() {
  echo -e "\n[🛠️] Log Commands:"
  echo -e "  • startlog   → Start saving all output to a file"
  echo -e "  • stoplog    → Stop logging"
  echo -e "  • tail -f <logfile> → View a log file in real-time"

  echo -e "\n[📜] Tip: Use \033[1mtail -f <logfile>\033[0m to follow logs in real-time."
  
    echo -e "\n[📂] Available Logs:"
  find logs/ -type f -name "*.log" | sort | while read -r file; do
    echo " - $file"
  done
}

