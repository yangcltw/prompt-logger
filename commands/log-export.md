---
name: log-export
description: Export prompt logs. Usage: /log-export [--format csv|json|md] [--from YYYY-MM-DD] [--to YYYY-MM-DD]
---

The user wants to export their prompt logs. Parse their request:

Extract:
- --format: csv (default), json, or md
- --from: start date in YYYY-MM-DD format (optional)
- --to: end date in YYYY-MM-DD format (optional)

Run the export script:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/export.sh" <format> "<from_date>" "<to_date>"
```

After export, show the file path and file size. If markdown format, offer to show a preview of the first few entries.
