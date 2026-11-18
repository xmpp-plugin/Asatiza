#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "" ]; then
  echo "Usage: $0 <phase-file>"
  exit 2
fi

phase_file="$1"
if [ ! -f "$phase_file" ]; then
  echo "Missing phase file: $phase_file"
  exit 1
fi

phase_file="$(cd "$(dirname "$phase_file")" && pwd)/$(basename "$phase_file")"

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
items_dir="$repo_root/docs/phases/items"
failed=0

field_value() {
  local label="$1"
  sed -n -E "s/^- ${label}:[[:space:]]*//p" "$phase_file" | head -n 1 | sed 's/`//g'
}

readiness_items() {
  awk '
    /^## Readiness Checklist$/ { in_section=1; next }
    /^## / && in_section { exit }
    in_section { print }
  ' "$phase_file"
}

require_field() {
  local label="$1"
  local expected="$2"
  local actual
  actual="$(field_value "$label")"
  if [ "$actual" != "$expected" ]; then
    echo "NOT READY: $label must be $expected (found: ${actual:-missing})"
    failed=1
  fi
}

require_checked_item() {
  local item="$1"
  if ! readiness_items | grep -Fqx -- "- [x] $item"; then
    echo "NOT READY: readiness item is not checked: $item"
    failed=1
  fi
}

require_field "Current status" "APPROVED"
require_field "Approval" "APPROVED"
require_field "Outcome" "NONE"
phase_id="$(field_value "Phase ID")"

unchecked="$(readiness_items | grep -E '^- \[ \]' || true)"
if [ "$unchecked" != "" ]; then
  echo "NOT READY: readiness checklist has incomplete items"
  printf '%s\n' "$unchecked"
  failed=1
fi

for required in \
  "Developer approval is recorded" \
  "Rollback plan is defined" \
  "Manual tests are defined" \
  "Automated tests are defined" \
  "Proposed files are identified" \
  "New files/classes are approved"; do
  require_checked_item "$required"
done

dependencies="$(field_value "Dependency phases")"
if [ "$dependencies" = "" ] || [ "$dependencies" = "UNVERIFIED — developer confirmation required" ]; then
  echo "NOT READY: dependency phases are not verified"
  failed=1
elif [ "$dependencies" != "None" ]; then
  dependencies="$(printf '%s' "$dependencies" | sed 's/[[:space:]]*(.*$//' | tr ';' ',')"
  old_ifs="$IFS"
  IFS=','
  for dependency in $dependencies; do
    dependency="$(printf '%s' "$dependency" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    dependency_file="$items_dir/$dependency.md"
    if [ ! -f "$dependency_file" ]; then
      echo "NOT READY: dependency phase is missing: $dependency"
      failed=1
      continue
    fi
    dependency_status="$(sed -n -E 's/^- Current status:[[:space:]]*//p' "$dependency_file" | head -n 1 | sed 's/`//g')"
    dependency_outcome="$(sed -n -E 's/^- Outcome:[[:space:]]*//p' "$dependency_file" | head -n 1 | sed 's/`//g')"
    if [ "$dependency_status" != "CLOSED" ] || [ "$dependency_outcome" != "COMPLETED" ]; then
      echo "NOT READY: dependency is not CLOSED/COMPLETED: $dependency"
      failed=1
    fi
  done
  IFS="$old_ifs"
fi

while IFS= read -r other_phase; do
  other_phase_id="$(sed -n -E 's/^- Phase ID:[[:space:]]*//p' "$other_phase" | head -n 1 | sed 's/`//g')"
  [ "$other_phase" = "$phase_file" ] && continue
  [ "$phase_id" != "" ] && [ "$other_phase_id" = "$phase_id" ] && continue
  other_status="$(sed -n -E 's/^- Current status:[[:space:]]*//p' "$other_phase" | head -n 1 | sed 's/`//g')"
  if [ "$other_status" = "ACTIVE" ]; then
    echo "NOT READY: another phase is ACTIVE: $other_phase"
    failed=1
  fi
done < <(find "$items_dir" -type f -name 'PHASE_*.md' -print 2>/dev/null)

if [ "$failed" -eq 0 ]; then
  echo "Phase readiness OK"
fi

exit "$failed"
