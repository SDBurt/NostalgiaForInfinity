#!/bin/bash

#need to add to crontab by typing "crontab -e" in terminal "
#   */60 * * * * /bin/bash -c "ft_userdata/user_data/tools/docker-updater.sh
#

# Configuration
TG_TOKEN=""  # Telegram bot token
TG_CHAT_ID=""  # Telegram chat ID

ROOT="/home/sdburt/development/freqtrade/NostalgiaForInfinity"
NFI_REPO_HOME="/root/freqtrade/NostalgiaForInfinity"
FREQTRADE_HOME="/root/freqtrade/freqtrade-docker/ft_userdata"

# Change to NFI directory
cd "$NFI_REPO_HOME" || { echo "Failed to change directory to $NFI_REPO_HOME"; exit 1; }

# Fetch latest tags from the repository
git fetch --tags || { echo "Failed to fetch tags"; exit 1; }

# Get the latest and current tags
latest_tag=$(git describe --tags "$(git rev-list --tags --max-count=1)")
current_tag=$(git describe --tags)

# Check if an update is needed
if [ "$latest_tag" != "$current_tag" ]; then
    echo "New tag detected: $latest_tag (current: $current_tag). Updating..."

    # Checkout the latest tag
    git checkout "tags/$latest_tag" -b "$latest_tag" || git checkout "$latest_tag"

    # Notify via Telegram about the update
    if [ -n "$TG_TOKEN" ] && [ -n "$TG_CHAT_ID" ]; then
        curl -s --data "text=NFI updated to tag: *${latest_tag}*. Reloading..." \
             --data "parse_mode=markdown" \
             --data "chat_id=${TG_CHAT_ID}" \
             "https://api.telegram.org/bot${TG_TOKEN}/sendMessage"
    fi

    echo "Starting reload..."
    sleep 120

    # Pull latest NFI strategy and copy to Freqtrade
    echo "Updating NFI Strategy..."
    git pull || { echo "Failed to pull latest updates"; exit 1; }
    cp NostalgiaForInfinityX5.py "$FREQTRADE_HOME/user_data/strategies" || { echo "Failed to copy strategy"; exit 1; }
    echo "Copied NFI Strategy to Freqtrade."

    # Restart Freqtrade using Docker Compose
    echo "Restarting Freqtrade with updated NFI Strategy..."
    cd "$FREQTRADE_HOME" || { echo "Failed to change directory to $FREQTRADE_HOME"; exit 1; }
    docker compose stop
    docker compose build
    docker compose up -d || { echo "Failed to restart Freqtrade"; exit 1; }

    echo "Reload completed!"

    # Notify via Telegram about reload completion
    if [ -n "$TG_TOKEN" ] && [ -n "$TG_CHAT_ID" ]; then
        curl -s --data "text=NFI reload completed successfully!" \
             --data "parse_mode=markdown" \
             --data "chat_id=${TG_CHAT_ID}" \
             "https://api.telegram.org/bot${TG_TOKEN}/sendMessage"
    fi
else
    echo "No update required. Current tag: $current_tag"
fi
