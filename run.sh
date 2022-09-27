#!/bin/bash

# get directory where this script is located
ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# create logs directory
mkdir -p "$ROOT/logs"

# call actual script
# because it is executed in subshell, variables cannot be affected
"$ROOT/main.sh" 2>&1 | tee "$ROOT/logs/log_$(date +"%Y-%m-%d_%H-%M-%S").txt"
