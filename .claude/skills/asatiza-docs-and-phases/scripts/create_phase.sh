#!/usr/bin/env bash
set -euo pipefail

if [ "${3:-}" = "" ]; then
  echo "Usage: $0 <MODULE> <ACTION> \"Short description\""
  echo "Example: $0 AUTH FIX \"Session Expiry\""
  exit 2
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "Python 3 is required to create a phase. Install Python 3, then retry." >&2
  exit 127
fi

module="$(printf '%s' "$1" | tr '[:lower:]' '[:upper:]' | sed -E 's/[^A-Z0-9]+/_/g; s/^_+//; s/_+$//')"
action="$(printf '%s' "$2" | tr '[:lower:]' '[:upper:]' | sed -E 's/[^A-Z0-9]+/_/g; s/^_+//; s/_+$//')"
short="$(printf '%s' "$3" | tr '[:lower:]' '[:upper:]' | sed -E 's/[^A-Z0-9]+/_/g; s/^_+//; s/_+$//' | cut -c 1-48)"

if [ "$module" = "" ] || [ "$action" = "" ] || [ "$short" = "" ]; then
  echo "Module, action, and short description must contain letters or digits."
  exit 2
fi

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
phase_root="$repo_root/docs/phases"
items_dir="$phase_root/items"
template="$phase_root/templates/PHASE_TEMPLATE.md"
date_value="$(date +%F)"

if [ ! -f "$template" ]; then
  echo "Missing template: $template"
  exit 1
fi

mkdir -p "$items_dir" "$phase_root/state"

max_sequence="$(
  find "$items_dir" -type f -name 'PHASE_[0-9][0-9][0-9]_*.md' -print 2>/dev/null \
    | sed -E 's/.*PHASE_([0-9]{3})_.*/\1/' \
    | sort -n \
    | tail -n 1
)"

if [ "$max_sequence" = "" ]; then
  next_sequence="001"
else
  next_sequence="$(printf '%03d' "$((10#$max_sequence + 1))")"
fi

phase_id="PHASE_${next_sequence}_${module}_${action}_${short}"
file_name="${phase_id}.md"
output="$items_dir/$file_name"
title_words="$(printf '%s' "$short" | tr '_' ' ')"

if [ -e "$output" ]; then
  echo "Phase already exists: $output"
  exit 1
fi

PHASE_TEMPLATE="$template" \
PHASE_OUTPUT="$output" \
PHASE_ID="$phase_id" \
PHASE_FILE_NAME="$file_name" \
PHASE_MODULE="$module" \
PHASE_ACTION="$action" \
PHASE_TITLE="$title_words" \
PHASE_DATE="$date_value" \
python3 - <<'PY'
import os
from pathlib import Path

text = Path(os.environ["PHASE_TEMPLATE"]).read_text()
replacements = {
    "[PHASE_ID]": os.environ["PHASE_ID"],
    "[Module]": os.environ["PHASE_MODULE"].title(),
    "[Readable Title]": os.environ["PHASE_TITLE"].title(),
    "[Readable title]": os.environ["PHASE_TITLE"].title(),
    "[FILE_NAME]": os.environ["PHASE_FILE_NAME"],
    "[MODULE]": os.environ["PHASE_MODULE"],
    "[YYYY-MM-DD]": os.environ["PHASE_DATE"],
    "[REQUEST]": f"{os.environ['PHASE_MODULE']} {os.environ['PHASE_ACTION']} {os.environ['PHASE_TITLE'].title()}",
}
for old, new in replacements.items():
    text = text.replace(old, new)
Path(os.environ["PHASE_OUTPUT"]).write_text(text)
PY

if [ -x "$repo_root/.claude/skills/asatiza-docs-and-phases/scripts/update_phase_index.sh" ]; then
  "$repo_root/.claude/skills/asatiza-docs-and-phases/scripts/update_phase_index.sh" >/dev/null
fi

echo "$output"
