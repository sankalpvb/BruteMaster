#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # Reset

show_options() {
  echo -e "\nModule: http_login"

  # Prepare all options into an array of triples: ("name" "value" "description")
  options=(
    "url" "$url" "Target login URL"
    "username" "$username" "Username to brute-force"
    "wordlist" "$wordlist" "Path to password wordlist"
    "threads" "${threads:-1}" "Number of threads"
    "mode" "${mode:-all}" "Detection method (text/code/length/all)"
    "verbose" "${verbose:-false}" "Show verbose output"
  )

  # Calculate max column widths dynamically
  max_name=0
  max_value=0
  max_desc=0
  for ((i=0; i<${#options[@]}; i+=3)); do
    [[ ${#options[i]} -gt $max_name ]] && max_name=${#options[i]}
    [[ ${#options[i+1]} -gt $max_value ]] && max_value=${#options[i+1]}
    [[ ${#options[i+2]} -gt $max_desc ]] && max_desc=${#options[i+2]}
  done

  total_width=$((max_name + max_value + max_desc + 10))

  border=$(printf '+%*s+' "$total_width" '' | tr ' ' '-')
  echo -e "\n$options_box"
  echo "$border"
  printf "| %-${max_name}s | %-${max_value}s | %-${max_desc}s |\n" "Option" "Value" "Description"
  echo "$border"
  for ((i=0; i<${#options[@]}; i+=3)); do
    printf "| %-${max_name}s | %-${max_value}s | %-${max_desc}s |\n" "${options[i]}" "${options[i+1]}" "${options[i+2]}"
  done
  echo "$border"
}
run_module() {
  if [[ -z "$url" || -z "$username" || -z "$wordlist" ]]; then
    echo -e "${RED}[!] Missing required options.${NC} Use 'show options' and 'set <option> <value>'."
    return
  fi

  echo -e "${CYAN}[*] Running http_login module...${NC}"
  cmd=".venv/bin/python modules/http_login.py -u "$url" -U "$username" -w "$wordlist""
  [[ -n "$threads" ]] && cmd+=" --threads \"$threads\""
  [[ -n "$mode" ]] && cmd+=" -m \"$mode\""
  [[ "$verbose" == "true" ]] && cmd+=" --verbose"

  echo -e "${CYAN}[*] Executing:${NC} $cmd"
  eval $cmd
}

