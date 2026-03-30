# prompt-logger

A Claude Code plugin that automatically records every prompt you send, for evaluating and improving your AI usage.

## Features

- **Auto-record** — Every prompt is logged automatically via hooks (SessionStart, UserPromptSubmit, SessionEnd)
- **Rate interactions** — Score 1-5 with notes and tags
- **Search history** — Full-text search with project/date/rating filters
- **Statistics** — Usage trends, rating progress, tool analysis
- **Export** — CSV, JSON, or Markdown reports

## Installation

### From GitHub

```bash
git clone https://github.com/bart/prompt-logger.git
mkdir -p ~/.claude/plugins/local
cp -r prompt-logger ~/.claude/plugins/local/prompt-logger
```

### One-liner

```bash
git clone https://github.com/bart/prompt-logger.git ~/.claude/plugins/local/prompt-logger
```

Restart Claude Code after installation. The database will be auto-created on first session.

### For development

```bash
git clone https://github.com/bart/prompt-logger.git ~/prompt-logger
ln -s ~/prompt-logger ~/.claude/plugins/local/prompt-logger
```

## Commands

| Command | Description |
|---------|-------------|
| `/log-search [keyword]` | Search prompts. Filters: `--project`, `--from`, `--to`, `--rating`, `--tag`, `--limit` |
| `/log-rate [id] [1-5]` | Rate an interaction. Options: `--note`, `--tags` |
| `/log-stats [--days 30]` | View usage statistics and trends |
| `/log-export [--format csv\|json\|md]` | Export logs. Filters: `--from`, `--to` |

## How It Works

```
SessionStart  → init-db.sh       → Create DB + tables (idempotent)
UserPromptSubmit → record-prompt.sh → INSERT prompt with project/branch metadata
SessionEnd    → session-summary.sh → UPDATE tools_used from transcript
```

All hooks run automatically. No manual setup needed after installation.

## Plugin Structure

```
prompt-logger/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── commands/
│   ├── log-search.md            # /log-search command
│   ├── log-rate.md              # /log-rate command
│   ├── log-stats.md             # /log-stats command
│   └── log-export.md            # /log-export command
├── hooks/
│   ├── hooks.json               # Hook event configuration
│   └── scripts/
│       ├── init-db.sh           # SessionStart: create DB + tables
│       ├── record-prompt.sh     # UserPromptSubmit: INSERT prompt
│       └── session-summary.sh   # SessionEnd: UPDATE tools_used
├── scripts/
│   ├── db.sh                    # Shared DB path + helper functions
│   ├── search.sh                # /log-search logic
│   ├── rate.sh                  # /log-rate logic
│   ├── stats.sh                 # /log-stats logic
│   └── export.sh                # /log-export logic
└── README.md
```

## Data Storage

All data is stored locally in `~/.prompt-logger/logs.db` (SQLite).

Exports go to `~/.prompt-logger/exports/`.

No data is sent anywhere. Everything stays on your machine.

## Requirements

- `sqlite3` CLI (pre-installed on macOS/Linux)
- `jq` (for JSON parsing in hooks)

## License

MIT
