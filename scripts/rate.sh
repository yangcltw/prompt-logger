#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/db.sh"
ensure_db

ACTION="${1:-list}"

case "$ACTION" in
  list)
    echo "Unrated prompts (most recent 5):"
    echo ""
    echo "ID|Time|Project|Prompt"
    echo "--|----|---------|----|"
    query "SELECT id, substr(timestamp, 1, 16) AS time, project, substr(prompt, 1, 60) AS prompt_preview FROM logs WHERE rating IS NULL ORDER BY timestamp DESC LIMIT 5;"
    ;;
  rate)
    ID="$2"
    SCORE="$3"
    NOTE="${4:-}"
    TAGS="${5:-}"

    # Validate score
    if [ "$SCORE" -lt 1 ] || [ "$SCORE" -gt 5 ] 2>/dev/null; then
      echo "Error: rating must be 1-5" >&2
      exit 1
    fi

    # Build UPDATE
    SET_PARTS="rating = $SCORE"
    if [ -n "$NOTE" ]; then
      ESCAPED_NOTE=$(echo "$NOTE" | sed "s/'/''/g")
      SET_PARTS="$SET_PARTS, rating_note = '$ESCAPED_NOTE'"
    fi
    if [ -n "$TAGS" ]; then
      # Convert comma-separated to JSON array
      TAGS_JSON=$(echo "$TAGS" | tr ',' '\n' | sed 's/^ *//;s/ *$//' | jq -R . | jq -s . 2>/dev/null || echo "[]")
      ESCAPED_TAGS=$(echo "$TAGS_JSON" | sed "s/'/''/g")
      SET_PARTS="$SET_PARTS, tags = '$ESCAPED_TAGS'"
    fi

    sqlite3 "$DB_PATH" "UPDATE logs SET $SET_PARTS WHERE id = $ID;"

    # Show updated record
    echo "Updated:"
    query "SELECT id, substr(prompt, 1, 60) AS prompt, rating, rating_note, tags FROM logs WHERE id = $ID;"
    ;;
  *)
    echo "Usage: rate.sh list | rate.sh rate <id> <1-5> [note] [tags]" >&2
    exit 1
    ;;
esac
