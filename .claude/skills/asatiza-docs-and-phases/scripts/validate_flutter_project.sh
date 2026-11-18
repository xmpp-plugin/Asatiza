#!/usr/bin/env bash
set -euo pipefail

run_flutter_checks=0
verbose=0

for arg in "$@"; do
  case "$arg" in
    --run-flutter-checks)
      run_flutter_checks=1
      ;;
    --verbose)
      verbose=1
      ;;
    --quiet)
      verbose=0
      ;;
    *)
      echo "Usage: $0 [--run-flutter-checks] [--verbose]"
      exit 2
      ;;
  esac
done

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$repo_root"

echo "Project: $repo_root"

if [ "$verbose" -eq 1 ]; then
  branch="$(git branch --show-current 2>/dev/null || true)"
  status_output="$(git status --short 2>/dev/null || true)"
  echo "Git branch: ${branch:-UNKNOWN}"
  if [ "$status_output" = "" ]; then
    echo "Git status: clean"
  else
    echo "Git status: changed files"
    printf '%s\n' "$status_output"
  fi
else
  echo "Git branch/status: skipped in compact mode"
fi

missing=0
missing_paths=""
for path in pubspec.yaml lib/main.dart android/app/build.gradle.kts ios/Runner.xcodeproj analysis_options.yaml; do
  if [ -e "$path" ]; then
    if [ "$verbose" -eq 1 ]; then
      echo "OK: $path"
    fi
  else
    missing=1
    missing_paths="${missing_paths}${path}"$'\n'
  fi
done

if [ "$missing" -eq 0 ]; then
  echo "Required project files: OK"
else
  echo "Required project files: MISSING"
  printf '%s' "$missing_paths"
fi

run_logged() {
  local label="$1"
  shift
  local tmp_file
  tmp_file="$(mktemp)"
  if "$@" >"$tmp_file" 2>&1; then
    echo "$label: OK"
    if [ "$verbose" -eq 1 ]; then
      cat "$tmp_file"
    else
      grep -E "No issues found|issues found|All tests passed|Some tests failed|[0-9]+ tests? passed|[0-9]+ tests? failed" "$tmp_file" | tail -n 10 || true
    fi
    rm -f "$tmp_file"
  else
    local exit_code=$?
    echo "$label: FAILED (exit $exit_code)"
    cat "$tmp_file"
    rm -f "$tmp_file"
    return "$exit_code"
  fi
}

if [ "$run_flutter_checks" -eq 1 ]; then
  run_logged "Flutter analyze" flutter analyze
  run_logged "Flutter test" flutter test
else
  echo "Flutter analyze/test: skipped. Re-run with --run-flutter-checks when required."
fi
