#!/usr/bin/env bash
# A leaked developer key cannot be revoked -- losing control of it means losing the
# ability to publish updates under the same app identity.
set -euo pipefail

staged=$(git diff --cached --name-only --diff-filter=ACM)

if printf '%s\n' "$staged" | grep -qE '\.(der|pem)$|developer_key'; then
  echo "ERROR: a signing key is staged. Unstage it and add it to .gitignore."
  printf '%s\n' "$staged" | grep -E '\.(der|pem)$|developer_key'
  exit 1
fi

exit 0
