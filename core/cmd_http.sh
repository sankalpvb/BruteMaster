#!/bin/bash

# Color codes
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

show_options() {
  echo -e "\nModule: http_login"

  options=(
    "url" "${module_options[url]:-Not set}" "Target login URL"
    "username" "${module_options[username]:-Not set}" "Username to brute-force"
    "wordlist" "${module_options[wordlist]:-Not set}" "Path to password wordlist"
    "threads" "${module_options[threads]:-1}" "Number of threads"
    "mode" "${module_options[mode]:-all}" "Detection method (text/code/length/all)"
    "verbose" "${module_options[verbose]:-false}" "Show verbose output"
  )

  max_name=0; max_value=0; max_desc=0
  for ((i=0; i<${#options[@]}; i+=3)); do
    [[ ${#options[i]} -gt $max_name ]] && max_name=${#options[i]}
    [[ ${#options[i+1]} -gt $max_value ]] && max_value=${#options[i+1]}
    [[ ${#options[i+2]} -gt $max_desc ]] && max_desc=${#options[i+2]}
  done

  total_width=$((max_name + max_value + max_desc + 10))
  border=$(printf '+%*s+\n' "$total_width" '' | tr ' ' '-')
  echo "$border"
  printf "| %-${max_name}s | %-${max_value}s | %-${max_desc}s |\n" "Option" "Value" "Description"
  echo "$border"
  for ((i=0; i<${#options[@]}; i+=3)); do
    printf "| %-${max_name}s | %-${max_value}s | %-${max_desc}s |\n" "${options[i]}" "${options[i+1]}" "${options[i+2]}"
  done
  echo "$border"
}

run_module() {
  local url="${module_options[url]}"
  local username="${module_options[username]}"
  local wordlist="${module_options[wordlist]}"
  local threads="${module_options[threads]}"
  local mode="${module_options[mode]}"
  local verbose="${module_options[verbose]}"

  if [[ -z "$url" || -z "$username" || -z "$wordlist" ]]; then
    echo -e "${RED}[!] Missing required options.${NC} Use 'show options' and 'set <option> <value>'"
    return 1
  fi

  echo -e "${CYAN}[*] Running http_login module...${NC}"

  # Build command safely as array
  cmd=(.venv/bin/python modules/http_login.py -u "$url" -U "$username" -w "$wordlist")
  [[ -n "$threads" ]] && cmd+=("--threads" "$threads")
  [[ -n "$mode" ]] && cmd+=("-m" "$mode")
  [[ "$verbose" == "true" ]] && cmd+=("--verbose")

  echo -e "${CYAN}[*] Executing:${NC} ${cmd[*]}"

  # Handle Logging
  if [[ "$LOGGING_ENABLED" == true ]]; then
    log_dir="logs/http_login"
    mkdir -p "$log_dir"
    timestamp=$(date +%Y%m%d_%H%M%S)
    log_file="$log_dir/session_$timestamp.log"

    echo "[📡] Logging to: $log_file"
    "${cmd[@]}" 2>&1 | tee -a "$log_file"
  else
    "${cmd[@]}"
  fi
}

