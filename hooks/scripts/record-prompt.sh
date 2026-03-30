#!/bin/bash
set -euo pipefail

DB_PATH="$HOME/.prompt-logger/logs.db"

# Exit silently if DB doesn't exist yet
[ -f "$DB_PATH" ] || exit 0

# Read hook input from stdin
INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')
USER_PROMPT=$(echo "$INPUT" | jq -r '.user_prompt // ""')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')

# Skip empty prompts
[ -z "$USER_PROMPT" ] && exit 0

# Derive metadata
PROJECT=$(basename "$CWD" 2>/dev/null || echo "unknown")
BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null || echo "")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Escape single quotes for SQL
ESCAPED_PROMPT=$(echo "$USER_PROMPT" | sed "s/'/''/g")
ESCAPED_PROJECT=$(echo "$PROJECT" | sed "s/'/''/g")

# INSERT record
sqlite3 "$DB_PATH" "INSERT INTO logs (session_id, timestamp, project, branch, prompt) VALUES ('$SESSION_ID', '$TIMESTAMP', '$ESCAPED_PROJECT', '$BRANCH', '$ESCAPED_PROMPT');"

exit 0
