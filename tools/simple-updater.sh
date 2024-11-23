#!/bin/bash

#need to add to crontab by typing "crontab -e" in terminal "
#   */60 * * * * /bin/bash -c "path/to/freqtrade/tools/simple-updater.sh

# Configuration

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NFI_REPO_HOME="${SCRIPT_DIR}/.."

# Change to NFI directory
cd "$NFI_REPO_HOME" || { echo "Failed to change directory to $NFI_REPO_HOME"; exit 1; }

# Pull the latest changes from the repository
echo "Pulling latest changes in $NFI_REPO_HOME..."
git pull || { echo "Failed to pull latest changes"; exit 1; }

echo "Repository updated successfully."

