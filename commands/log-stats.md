---
name: log-stats
description: Show prompt usage statistics. Usage: /log-stats [--days 30]
---

The user wants to see statistics about their prompt usage. Parse their request:

Extract:
- --days: number of days to analyze (default 30)

Run the stats script:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/stats.sh" <days>
```

Present the output in a well-formatted way. Add brief insights if any trends are notable (e.g., "Your average rating improved from 3.2 to 4.1 — nice progress!").
