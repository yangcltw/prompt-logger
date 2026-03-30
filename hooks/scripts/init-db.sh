#!/bin/bash
set -euo pipefail

DB_DIR="$HOME/.prompt-logger"
DB_PATH="$DB_DIR/logs.db"
EXPORT_DIR="$DB_DIR/exports"

# Create directories
mkdir -p "$DB_DIR" "$EXPORT_DIR"

# Create table + indexes (idempotent)
sqlite3 "$DB_PATH" <<'SQL'
PRAGMA journal_mode=WAL;

CREATE TABLE IF NOT EXISTS logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id TEXT NOT NULL,
  timestamp TEXT NOT NULL,
  project TEXT,
  branch TEXT,
  prompt TEXT NOT NULL,
  response_summary TEXT,
  tools_used TEXT,
  rating INTEGER,
  rating_note TEXT,
  tags TEXT,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_timestamp ON logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_project ON logs(project);
CREATE INDEX IF NOT EXISTS idx_rating ON logs(rating);
CREATE INDEX IF NOT EXISTS idx_session ON logs(session_id);
SQL

# Secure permissions
chmod 600 "$DB_PATH"

exit 0
