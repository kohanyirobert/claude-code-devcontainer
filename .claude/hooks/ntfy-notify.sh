#!/bin/bash
set -euo pipefail

MESSAGE=$(cat | jq -r '.message // empty')
[ -z "$MESSAGE" ] && MESSAGE="Claude has a message for you"

NTFY_HOST="${NTFY_HOST:-host.docker.internal}"
NTFY_PORT="${NTFY_PORT:-80}"
NTFY_TOPIC="${NTFY_TOPIC:-claude}"

curl -s -X POST \
  -H "Title: Claude Code" \
  -H "Priority: default" \
  -d "$MESSAGE" \
  "http://${NTFY_HOST}:${NTFY_PORT}/${NTFY_TOPIC}" || true
