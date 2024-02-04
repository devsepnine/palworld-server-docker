#!/bin/bash

# Command usage
usage() {
cat << EOH
Usage: $0 [OPTION]... -i WEBHOOK_ID -t CONNECT_TIMEOUT -m MAX_TIMEOUT -j JSON
Post a discord message via a discord webhook. By default uses a 30s connect-timeout and 30s max-timeout. Webhook id an json are required to send a discord webhook. A good example for discord json formatting is located here: https://birdie0.github.io/discord-webhooks-guide/discord_webhook.html
Package requirement: curl

Examples:
    $0 -i 01234/56789 -t 30 -m 30 -j {"username":"Palworld","content":"Server starting..."}
    $0 --webhook-id  01234/56789 --connect-timeout 30 --max-timeout 30 --json {"username":"Palworld","content":"Server starting..."}

Options:
    -i, --webhook-id        The unique id that is used by discord to determine what server/channel/thread to post. ex: https://discord.com/api/webhooks/<your id>
    -t, --connect-timeout   The timeout for connecting to the discord webhook (Default: 30)
    -m, --max-timeout       The maximum time curl will wait for a response (Default: 30)
    -j, --json              The json message body sent to the discord webhook
    -h, --help              Display help text and exit
EOH
}

# DISCORD_WEBHOOK
# DISCORD_USER
# DISCORD_TIMEOUT
# NICE_SHUTDOWN_TIME

# Defaults
RED='\033[0;31m'
NC='\033[0m'
REQ=2
REQ_FLAG=0
DEFAULT_CONNECT_TIMEOUT=30
DEFAULT_MAX_TIMEOUT=30

# # Decimal Colors
# INFO=1127128 # blue
# IN_PROGRESS=15258703 # yellow
# WARN=14177041 # orange
# FAILURE=14614528 # red
# SUCCESS=52224 # green

# Show usage if no arguments specified
if [[ $# -eq 0 ]]; then
    usage
    exit 0
fi

# Parse arguments
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -i|--webhook-id )
            WEBHOOK_ID="$2"
            ((REQ_FLAG++))
            shift
            shift
            ;;
        -t|--connect-timeout )
            CONNECT_TIMEOUT="$2"
            shift
            shift
            ;;
        -m|--max-timeout )
            MAX_TIMEOUT="$2"
            shift
            shift
            ;;
        -j|--json )
            JSON="$2"
            ((REQ_FLAG++))
            shift
            shift
            ;;
        -h|--help )
            usage
            exit 0
            ;;
        * )
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done
set -- "${POSITIONAL[@]}"

# Check required options
if [ $REQ_FLAG -lt $REQ ]; then
    printf "%b\n" "${RED}webhook-id and json are required${NC}"
    usage
    exit 1
fi

if [ -n "${$CONNECT_TIMEOUT}" ] &&  [[ "${CONNECT_TIMEOUT}" =~ ^[0-9]+$ ]]; then
    CONNECT_TIMEOUT=$DISCORD_CONNECT_TIMEOUT
else
    echo "CONNECT_TIMEOUT is not an integer, using default ${$DEFAULT_CONNECT_TIMEOUT} seconds."
    CONNECT_TIMEOUT=$DEFAULT_CONNECT_TIMEOUT
fi

if [ -n "${MAX_TIMEOUT}" ] && [[ "${MAX_TIMEOUT}" =~ ^[0-9]+$ ]]; then
    MAX_TIMEOUT=$DISCORD_MAX_TIMEOUT
else
    echo "MAX_TIMEOUT is not an integer, using default ${DEFAULT_MAX_TIMEOUT} seconds."
    MAX_TIMEOUT=$DEFAULT_MAX_TIMEOUT
fi

# Set discord webhook
DISCORD_WEBHOOK="https://discord.com/api/webhooks/$WEBHOOK_ID"
echo "Sending Discord json: ${JSON}"
curl -sfSL --connect-timeout "$CONNECT_TIMEOUT" --max-time "$MAX_TIMEOUT" -H "Content-Type: application/json" -d "$JSON" "$DISCORD_WEBHOOK"
