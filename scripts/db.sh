#!/bin/bash
# Shared database configuration and helpers for prompt-logger
# Source this file: source "$(dirname "$0")/../scripts/db.sh"

DB_DIR="$HOME/.prompt-logger"
DB_PATH="$DB_DIR/logs.db"
EXPORT_DIR="$DB_DIR/exports"

ensure_db() {
  if [ ! -f "$DB_PATH" ]; then
    echo "prompt-logger: database not initialized" >&2
    exit 1
  fi
}

query() {
  sqlite3 -separator '|' "$DB_PATH" "$1"
}

query_csv() {
  sqlite3 -header -csv "$DB_PATH" "$1"
}

query_json() {
  sqlite3 -json "$DB_PATH" "$1"
}
