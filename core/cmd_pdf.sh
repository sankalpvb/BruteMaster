#!/bin/bash

# Initialize options
declare -A module_options
module_options["file"]="None"
module_options["wordlist"]="None"

show_options() {
  echo -e "\n+-----------+--------------------------------------------------------------------------------+"
  echo "| Option    | Value                                                                          |"
  echo "+-----------+--------------------------------------------------------------------------------+"
  printf "| %-9s | %-78s |\n" "file" "${file:-Not set}"
  printf "| %-9s | %-78s |\n" "wordlist" "${wordlist:-Not set}"
  printf "| %-9s | %-78s |\n" "verbose" "${verbose:-false}"
  echo "+-----------+--------------------------------------------------------------------------------+"
}

run_module() {
  echo "[*] Running pdf module..."
  if [[ -z "$file" || -z "$wordlist" ]]; then
    echo "[!] Please set both 'file' and 'wordlist' options first."
    return
  fi

  verbose_flag=""
  if [[ "$verbose" == "true" ]]; then
    verbose_flag="--verbose"
  fi

  echo "[*] Executing: .venv/bin/python modules/pdf.py -f \"$file\" -w \"$wordlist\" $verbose_flag"
  .venv/bin/python modules/pdf.py -f "$file" -w "$wordlist" $verbose_flag
}
