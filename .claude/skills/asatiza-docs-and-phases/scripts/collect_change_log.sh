#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
phase_file=""
verbose=0

for arg in "$@"; do
  case "$arg" in
    --verbose)
      verbose=1
      ;;
    --quiet)
      verbose=0
      ;;
    -*)
      echo "Usage: $0 [--verbose] [phase-file]" >&2
      exit 2
      ;;
    *)
      if [ "$phase_file" != "" ]; then
        echo "Usage: $0 [--verbose] [phase-file]" >&2
        exit 2
      fi
      phase_file="$arg"
      ;;
  esac
done

if [ "$phase_file" != "" ] && [ ! -f "$phase_file" ]; then
  echo "Missing phase file: $phase_file" >&2
  exit 1
fi

cd "$repo_root"

echo "## Change Collection"
echo
echo "- Repository: $repo_root"
if [ "$phase_file" != "" ]; then
  echo "- Phase file: $phase_file"
fi
echo "- Generated at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

git diff --name-status >"$tmp_file" 2>/dev/null || true
git status --short 2>/dev/null | awk '
  /^\?\?/ {
    path = substr($0, 4)
    print "??\t" path
  }
' >>"$tmp_file"

if [ "$verbose" -eq 1 ]; then
  echo "### Git Status"
  echo
  echo '```text'
  git status --short 2>/dev/null || true
  echo '```'
  echo

  echo "### Git Diff Name/Status"
  echo
  echo '```text'
  git diff --name-status 2>/dev/null || true
  echo '```'
  echo
fi

echo "### File-by-file Change Log Scaffold"
echo
echo "| File path | Change type | Approved in phase | What changed | Why it changed | Existing behavior preserved | Possible side effects | File-level checks |"
echo "|---|---|---|---|---|---|---|---|"

if [ ! -s "$tmp_file" ]; then
  echo "| None | Not changed | Not applicable | Not applicable | Not applicable | Not applicable | Not applicable | Not applicable |"
  exit 0
fi

awk -F '\t' '
  function label(status) {
    if (status == "A") return "Added"
    if (status == "M") return "Modified"
    if (status == "D") return "Deleted"
    if (status == "R") return "Renamed"
    if (status == "C") return "Copied"
    if (status == "??") return "Untracked"
    return status
  }
  {
    status = $1
    file = $2
    if (status ~ /^R/ || status ~ /^C/) {
      file = $2 " -> " $3
      status = substr(status, 1, 1)
    }
    gsub(/\|/, "\\|", file)
    print "| " file " | " label(status) " | Fill in | Fill in | Fill in | Fill in | Fill in | Fill in |"
  }
' "$tmp_file"
