#!/bin/bash

# get directory where this script is located
ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

timestamp() {
    echo "$(date +"%Y-%m-%d %T")"
}
