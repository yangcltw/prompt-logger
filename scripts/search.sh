#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/db.sh"
ensure_db

# Parse arguments
KEYWORD=""
PROJECT=""
FROM_DATE=""
TO_DATE=""
RATING=""
TAG=""
LIMIT=20

while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT="$2"; shift 2 ;;
    --from) FROM_DATE="$2"; shift 2 ;;
    --to) TO_DATE="$2"; shift 2 ;;
    --rating) RATING="$2"; shift 2 ;;
    --tag) TAG="$2"; shift 2 ;;
    --limit) LIMIT="$2"; shift 2 ;;
    *) KEYWORD="$1"; shift ;;
  esac
done

# Build WHERE clause
CONDITIONS=()
if [ -n "$KEYWORD" ]; then
  ESCAPED_KW=$(echo "$KEYWORD" | sed "s/'/''/g")
  CONDITIONS+=("prompt LIKE '%${ESCAPED_KW}%'")
fi
if [ -n "$PROJECT" ]; then
  CONDITIONS+=("project = '$(echo "$PROJECT" | sed "s/'/''/g")'")
fi
if [ -n "$FROM_DATE" ]; then
  CONDITIONS+=("timestamp >= '$FROM_DATE'")
fi
if [ -n "$TO_DATE" ]; then
  CONDITIONS+=("timestamp <= '$TO_DATE'")
fi
if [ -n "$RATING" ]; then
  CONDITIONS+=("rating = $RATING")
fi
if [ -n "$TAG" ]; then
  ESCAPED_TAG=$(echo "$TAG" | sed "s/'/''/g")
  CONDITIONS+=("tags LIKE '%\"${ESCAPED_TAG}\"%'")
fi

WHERE=""
if [ ${#CONDITIONS[@]} -gt 0 ]; then
  WHERE="WHERE $(IFS=' AND '; echo "${CONDITIONS[*]}")"
fi

SQL="SELECT id, substr(timestamp, 1, 16) AS time, project, substr(prompt, 1, 60) AS prompt_preview, COALESCE(CAST(rating AS TEXT), '-') AS rating FROM logs $WHERE ORDER BY timestamp DESC LIMIT $LIMIT;"

echo "ID|Time|Project|Prompt|Rating"
echo "--|----|---------|----|------"
query "$SQL"
