#!/bin/bash
set -euo pipefail

DB_PATH="$HOME/.prompt-logger/logs.db"

# Exit silently if DB doesn't exist
[ -f "$DB_PATH" ] || exit 0

# Read hook input from stdin
INPUT=$(cat)

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // ""')

[ -z "$SESSION_ID" ] && exit 0

# Extract tool names from transcript if available
TOOLS_JSON="[]"
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  # Extract unique tool names from transcript (tool_use lines)
  TOOLS=$(grep -o '"tool_name":"[^"]*"' "$TRANSCRIPT_PATH" 2>/dev/null \
    | sed 's/"tool_name":"//;s/"//' \
    | sort -u \
    | jq -R . | jq -s . 2>/dev/null || echo "[]")
  TOOLS_JSON="$TOOLS"
fi

# Escape for SQL
ESCAPED_TOOLS=$(echo "$TOOLS_JSON" | sed "s/'/''/g")

# Update all records for this session
sqlite3 "$DB_PATH" "UPDATE logs SET tools_used = '$ESCAPED_TOOLS' WHERE session_id = '$SESSION_ID' AND tools_used IS NULL;"

exit 0
