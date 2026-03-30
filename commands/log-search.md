---
name: log-search
description: Search prompt history. Usage: /log-search [keyword] [--project name] [--from date] [--to date] [--rating 1-5] [--tag tag] [--limit n]
---

The user wants to search their prompt history. Parse their request and run the search script.

Extract from the user's message:
- keyword: free text to search in prompts (optional)
- --project: project name filter (optional)
- --from / --to: date range in YYYY-MM-DD format (optional)
- --rating: 1-5 rating filter (optional)
- --tag: tag name filter (optional)
- --limit: number of results, default 20 (optional)

Run the search script with the extracted parameters:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/search.sh" [keyword] [--project name] [--from YYYY-MM-DD] [--to YYYY-MM-DD] [--rating N] [--tag name] [--limit N]
```

Present the results as a formatted table. If no results found, say so.
