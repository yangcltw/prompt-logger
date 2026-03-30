#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/db.sh"
ensure_db

FORMAT="${1:-csv}"
FROM_DATE="${2:-}"
TO_DATE="${3:-}"

# Build WHERE
CONDITIONS=()
if [ -n "$FROM_DATE" ]; then
  CONDITIONS+=("timestamp >= '$FROM_DATE'")
fi
if [ -n "$TO_DATE" ]; then
  CONDITIONS+=("timestamp <= '$TO_DATE'")
fi

WHERE=""
if [ ${#CONDITIONS[@]} -gt 0 ]; then
  WHERE="WHERE $(IFS=' AND '; echo "${CONDITIONS[*]}")"
fi

SQL="SELECT id, session_id, timestamp, project, branch, prompt, response_summary, tools_used, rating, rating_note, tags FROM logs $WHERE ORDER BY timestamp DESC;"

mkdir -p "$EXPORT_DIR"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

case "$FORMAT" in
  csv)
    OUTFILE="$EXPORT_DIR/prompt-log-$TIMESTAMP.csv"
    query_csv "$SQL" > "$OUTFILE"
    echo "Exported to: $OUTFILE"
    ;;
  json)
    OUTFILE="$EXPORT_DIR/prompt-log-$TIMESTAMP.json"
    query_json "$SQL" > "$OUTFILE"
    echo "Exported to: $OUTFILE"
    ;;
  md)
    OUTFILE="$EXPORT_DIR/prompt-log-$TIMESTAMP.md"
    {
      echo "# Prompt Log Report"
      echo ""
      echo "Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
      echo ""
      # Summary stats
      TOTAL=$(query "SELECT COUNT(*) FROM logs $WHERE;")
      RATED=$(query "SELECT COUNT(*) FROM logs $WHERE AND rating IS NOT NULL;" 2>/dev/null || echo "0")
      AVG_RATING=$(query "SELECT ROUND(AVG(rating), 2) FROM logs $WHERE AND rating IS NOT NULL;" 2>/dev/null || echo "N/A")
      echo "| Metric | Value |"
      echo "|--------|-------|"
      echo "| Total prompts | $TOTAL |"
      echo "| Rated | $RATED |"
      echo "| Average rating | ${AVG_RATING:-N/A} |"
      echo ""
      echo "## Entries"
      echo ""
      # Each entry
      query "SELECT id, timestamp, project, prompt, COALESCE(CAST(rating AS TEXT), '-') AS rating, COALESCE(rating_note, '') AS note FROM logs $WHERE ORDER BY timestamp DESC;" | while IFS='|' read -r id ts proj prompt rating note; do
        echo "### #$id — $ts"
        echo "**Project:** $proj | **Rating:** $rating"
        echo ""
        echo "> $prompt"
        if [ -n "$note" ]; then
          echo ""
          echo "*Note: $note*"
        fi
        echo ""
        echo "---"
        echo ""
      done
    } > "$OUTFILE"
    echo "Exported to: $OUTFILE"
    ;;
  *)
    echo "Error: format must be csv, json, or md" >&2
    exit 1
    ;;
esac
