#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/db.sh"
ensure_db

DAYS="${1:-30}"
SINCE=$(date -u -v-${DAYS}d +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -d "$DAYS days ago" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "2000-01-01T00:00:00Z")

echo "=== Prompt Logger Stats (last $DAYS days) ==="
echo ""

# Total interactions
TOTAL=$(query "SELECT COUNT(*) FROM logs WHERE timestamp >= '$SINCE';")
DAYS_WITH_DATA=$(query "SELECT COUNT(DISTINCT date(timestamp)) FROM logs WHERE timestamp >= '$SINCE';")
if [ "$DAYS_WITH_DATA" -gt 0 ] 2>/dev/null; then
  DAILY_AVG=$((TOTAL / DAYS_WITH_DATA))
else
  DAILY_AVG=0
fi
echo "Total interactions: $TOTAL"
echo "Days with activity: $DAYS_WITH_DATA"
echo "Daily average: $DAILY_AVG"
echo ""

# By project
echo "--- By Project ---"
query "SELECT project, COUNT(*) AS count FROM logs WHERE timestamp >= '$SINCE' GROUP BY project ORDER BY count DESC LIMIT 10;"
echo ""

# Rating distribution
echo "--- Rating Distribution ---"
query "SELECT COALESCE(CAST(rating AS TEXT), 'unrated') AS rating, COUNT(*) AS count FROM logs WHERE timestamp >= '$SINCE' GROUP BY rating ORDER BY rating;"
echo ""

# Top tools
echo "--- Top Tools ---"
query "SELECT value AS tool, COUNT(*) AS count FROM logs, json_each(logs.tools_used) WHERE timestamp >= '$SINCE' AND tools_used IS NOT NULL AND tools_used != '[]' GROUP BY value ORDER BY count DESC LIMIT 5;"
echo ""

# Rating trend: recent half vs older half
MIDPOINT=$(query "SELECT datetime(MIN(julianday(timestamp)) + (MAX(julianday(timestamp)) - MIN(julianday(timestamp))) / 2) FROM logs WHERE timestamp >= '$SINCE' AND rating IS NOT NULL;")
if [ -n "$MIDPOINT" ] && [ "$MIDPOINT" != "" ]; then
  echo "--- Rating Trend ---"
  OLDER_AVG=$(query "SELECT ROUND(AVG(rating), 2) FROM logs WHERE timestamp >= '$SINCE' AND timestamp < '$MIDPOINT' AND rating IS NOT NULL;")
  RECENT_AVG=$(query "SELECT ROUND(AVG(rating), 2) FROM logs WHERE timestamp >= '$SINCE' AND timestamp >= '$MIDPOINT' AND rating IS NOT NULL;")
  echo "Older period avg: ${OLDER_AVG:-N/A}"
  echo "Recent period avg: ${RECENT_AVG:-N/A}"
fi
