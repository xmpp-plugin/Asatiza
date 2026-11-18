#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
missing=0

required_paths=(
  "CLAUDE.md"
  "docs/PROJECT_OVERVIEW.md"
  "docs/ARCHITECTURE.md"
  "docs/DIRECTORY_STRUCTURE.md"
  "docs/CODING_STANDARDS.md"
  "docs/NAMING_CONVENTIONS.md"
  "docs/COMMON_COMPONENTS.md"
  "docs/STATE_MANAGEMENT.md"
  "docs/API_REFERENCE.md"
  "docs/DATABASE_AND_CACHE.md"
  "docs/NAVIGATION.md"
  "docs/ERROR_HANDLING.md"
  "docs/TESTING_GUIDE.md"
  "docs/PHASE_WORKFLOW.md"
  "docs/CHANGE_APPROVAL_RULES.md"
  "docs/KNOWN_ISSUES.md"
  "docs/FILE_CATALOG.md"
  "docs/CLASS_AND_COMPONENT_RULES.md"
  "docs/product/VERSION_1_PLAN.md"
  "docs/product/FULL_PRODUCT_PLAN.md"
  "docs/phases/README.md"
  "docs/phases/PHASE_INDEX.md"
  "docs/phases/items"
  "docs/phases/state"
  "docs/phases/state/PHASE_STATE.md"
  "docs/phases/templates/PHASE_TEMPLATE.md"
  "docs/phases/templates/PHASE_ANALYSIS_TEMPLATE.md"
  "docs/phases/templates/PHASE_EXECUTION_TEMPLATE.md"
  "docs/phases/templates/PHASE_CLOSURE_TEMPLATE.md"
  "docs/phases/templates/PHASE_BLOCKED_TEMPLATE.md"
  "docs/phases/templates/NEW_DOCUMENTATION_GENERATE_PROMPT.md"
  ".claude/skills/asatiza-docs-and-phases/SKILL.md"
  ".claude/skills/asatiza-docs-and-phases/references/create-phase.md"
  ".claude/skills/asatiza-docs-and-phases/references/approve-phase.md"
  ".claude/skills/asatiza-docs-and-phases/references/execute-phase.md"
  ".claude/skills/asatiza-docs-and-phases/references/close-phase.md"
  ".claude/skills/asatiza-docs-and-phases/references/architecture-review.md"
  ".claude/skills/asatiza-docs-and-phases/references/minimum-change-policy.md"
  ".claude/skills/asatiza-docs-and-phases/references/api-change-policy.md"
  ".claude/skills/asatiza-docs-and-phases/references/reusable-components-policy.md"
  ".claude/skills/asatiza-docs-and-phases/references/approval-policy.md"
  ".claude/skills/asatiza-docs-and-phases/references/testing-policy.md"
  ".claude/skills/asatiza-docs-and-phases/references/completion-report.md"
  ".claude/skills/asatiza-docs-and-phases/references/one-active-phase-policy.md"
  ".claude/skills/asatiza-docs-and-phases/references/phase-readiness.md"
  ".claude/skills/asatiza-docs-and-phases/references/phase-index-policy.md"
  ".claude/skills/asatiza-docs-and-phases/references/documentation-policy.md"
  ".claude/skills/asatiza-docs-and-phases/references/product-facts.md"
  ".claude/skills/asatiza-docs-and-phases/references/security-and-secrets-policy.md"
  ".claude/skills/asatiza-docs-and-phases/scripts/create_phase.sh"
  ".claude/skills/asatiza-docs-and-phases/scripts/validate_phase_structure.sh"
  ".claude/skills/asatiza-docs-and-phases/scripts/validate_phase_readiness.sh"
  ".claude/skills/asatiza-docs-and-phases/scripts/update_phase_index.sh"
  ".claude/skills/asatiza-docs-and-phases/scripts/validate_flutter_project.sh"
  ".claude/skills/asatiza-docs-and-phases/scripts/collect_change_log.sh"
  ".claude/skills/asatiza-docs-and-phases/assets/PHASE_TEMPLATE.md"
  ".claude/skills/asatiza-docs-and-phases/assets/PHASE_PROMPTS.md"
  ".claude/skills/asatiza-docs-and-phases/assets/EXECUTION_REPORT_TEMPLATE.md"
  ".claude/skills/asatiza-docs-and-phases/assets/CLOSURE_REPORT_TEMPLATE.md"
)

for path in "${required_paths[@]}"; do
  if [ ! -e "$repo_root/$path" ]; then
    echo "MISSING: $path"
    missing=1
  fi
done

if [ -e "$repo_root/phases" ]; then
  echo "INVALID: root-level phases/ directory still exists"
  missing=1
fi

if ! grep -q '^name: asatiza-docs-and-phases$' "$repo_root/.claude/skills/asatiza-docs-and-phases/SKILL.md"; then
  echo "INVALID: SKILL.md name frontmatter"
  missing=1
fi

for phrase in "Create Phase" "Approve Phase" "Execute Phase" "Close Phase"; do
  if ! grep -q "$phrase" "$repo_root/.claude/skills/asatiza-docs-and-phases/SKILL.md"; then
    echo "INVALID: $phrase not documented in SKILL.md"
    missing=1
  fi
done

if grep -R "docs/phases/planned\\|docs/phases/active\\|docs/phases/blocked\\|docs/phases/completed\\|docs/phases/cancelled" "$repo_root/.claude/skills/asatiza-docs-and-phases" "$repo_root/docs/PHASE_WORKFLOW.md" "$repo_root/CLAUDE.md" \
  | grep -v "scripts/validate_phase_structure.sh" >/dev/null; then
  echo "INVALID: old status-directory phase path reference found"
  missing=1
fi

if [ "$missing" -eq 0 ]; then
  echo "Phase structure OK"
fi

exit "$missing"
