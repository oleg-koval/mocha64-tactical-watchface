#!/usr/bin/env bash
# Enforces RULES.md 2.2 -- no source file over 300 lines.
set -euo pipefail

MAX=300
status=0

for f in "$@"; do
  [ -f "$f" ] || continue
  lines=$(wc -l < "$f" | tr -d ' ')
  if [ "$lines" -gt "$MAX" ]; then
    echo "ERROR: $f has $lines lines (max $MAX)"
    status=1
  fi
done

exit $status
