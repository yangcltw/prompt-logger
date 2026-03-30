---
name: log-rate
description: Rate a prompt interaction 1-5. Usage: /log-rate [id] [score] [--note text] [--tags tag1,tag2]
---

The user wants to rate their prompt interactions. Parse their request:

**No arguments:** Show unrated prompts for the user to choose from.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/rate.sh" list
```

**With ID and score:** Rate a specific prompt.

Extract:
- id: the log entry ID (required)
- score: 1-5 rating (required)
- --note: optional rating note text
- --tags: optional comma-separated tags

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/rate.sh" rate <id> <score> "<note>" "<tags>"
```

After rating, confirm what was updated. If the user doesn't provide an ID, show the unrated list first and ask which one to rate.
