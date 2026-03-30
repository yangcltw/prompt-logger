# prompt-logger

A Claude Code plugin that automatically records every prompt you send, for evaluating and improving your AI usage.

## Features

- **Auto-record** — Every prompt is logged automatically via hooks
- **Rate interactions** — Score 1-5 with notes and tags
- **Search history** — Full-text search with project/date/rating filters
- **Statistics** — Usage trends, rating progress, tool analysis
- **Export** — CSV, JSON, or Markdown reports

## Installation

Copy or symlink this directory to your Claude Code plugins:

```bash
cp -r prompt-logger ~/.claude/plugins/local/prompt-logger
```

Or for development (live changes):

```bash
ln -s "$(pwd)/prompt-logger" ~/.claude/plugins/local/prompt-logger
```

Restart Claude Code after installation.

## Commands

| Command | Description |
|---------|-------------|
| `/log-search [keyword]` | Search prompts. Filters: `--project`, `--from`, `--to`, `--rating`, `--tag`, `--limit` |
| `/log-rate [id] [1-5]` | Rate an interaction. Options: `--note`, `--tags` |
| `/log-stats [--days 30]` | View usage statistics and trends |
| `/log-export [--format csv\|json\|md]` | Export logs. Filters: `--from`, `--to` |

## Data Storage

All data is stored locally in `~/.prompt-logger/logs.db` (SQLite).

Exports go to `~/.prompt-logger/exports/`.

## Requirements

- `sqlite3` CLI (pre-installed on macOS/Linux)
- `jq` (for JSON parsing in hooks)
