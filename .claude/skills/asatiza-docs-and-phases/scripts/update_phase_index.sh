#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
phase_root="$repo_root/docs/phases"
items_dir="$phase_root/items"
index="$phase_root/PHASE_INDEX.md"

mkdir -p "$phase_root" "$items_dir"

index_tmp="$(mktemp "${index}.tmp.XXXXXX")"
trap 'rm -f "$index_tmp"' EXIT

field_value() {
  local file="$1"
  local label="$2"
  grep -m1 "^- ${label}:" "$file" | sed -E "s/^- ${label}:[[:space:]]*//; s/\`//g" || true
}

is_active_status() {
  case "$1" in
    ACTIVE)
      return 0
      ;;
  esac
  return 1
}

phase_files() {
  find "$items_dir" -type f -name 'PHASE_*.md' -print 2>/dev/null | sort
}

write_index() {
  echo "# Phase Index"
  echo
  echo "| Phase ID | Phase title | Module | Priority | Risk | Dependency phases | Current status | Current step | Approval | Outcome | Phase file path | Created date | Started date | Completed date |"
  echo "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|"

  phase_files | while IFS= read -r file; do
    rel="${file#$repo_root/}"
    id="$(field_value "$file" "Phase ID")"
    title="$(field_value "$file" "Phase title")"
    module="$(field_value "$file" "Module")"
    priority="$(field_value "$file" "Priority")"
    risk="$(field_value "$file" "Risk level")"
    deps="$(field_value "$file" "Dependency phases")"
    status="$(field_value "$file" "Current status")"
    step="$(field_value "$file" "Current step")"
    approval="$(field_value "$file" "Approval")"
    outcome="$(field_value "$file" "Outcome")"
    created="$(field_value "$file" "Created date")"
    started="$(field_value "$file" "Started date")"
    completed="$(field_value "$file" "Completed date")"

    id="${id:-$(basename "$file" .md)}"
    title="${title:-UNVERIFIED - developer confirmation required}"
    module="${module:-UNVERIFIED - developer confirmation required}"
    priority="${priority:-UNVERIFIED - developer confirmation required}"
    risk="${risk:-UNVERIFIED - developer confirmation required}"
    deps="${deps:-UNVERIFIED - developer confirmation required}"
    status="${status:-UNVERIFIED - developer confirmation required}"
    step="${step:-UNVERIFIED - developer confirmation required}"
    approval="${approval:-UNVERIFIED - developer confirmation required}"
    outcome="${outcome:-UNVERIFIED - developer confirmation required}"
    created="${created:-UNVERIFIED - developer confirmation required}"
    started="${started:-Not started}"
    completed="${completed:-Not completed}"

    echo "| \`$id\` | $title | $module | $priority | $risk | $deps | \`$status\` | \`$step\` | \`$approval\` | \`$outcome\` | \`$rel\` | $created | $started | $completed |"
  done

  echo
  echo "## Active Phase"
  echo

  active_count=0
  phase_files | while IFS= read -r file; do
    status="$(field_value "$file" "Current status")"
    if is_active_status "$status"; then
      echo "- ${file#$repo_root/}"
      active_count=$((active_count + 1))
    fi
  done

  if ! phase_files | while IFS= read -r file; do is_active_status "$(field_value "$file" "Current status")" && exit 0; done; then
    echo "None."
  fi
}

write_index > "$index_tmp"
mv "$index_tmp" "$index"

echo "$index"
