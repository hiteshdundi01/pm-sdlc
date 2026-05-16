#!/usr/bin/env bash
set -euo pipefail

# check-workflows.sh
# Validates workflow files for required structure, frontmatter, and
# tool-agnostic language. Designed to run in CI alongside markdownlint.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_DIR="${1:-$SCRIPT_DIR/../workflows}"
REFERENCE_DIR="${SCRIPT_DIR}/../reference"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

error() {
    echo -e "${RED}ERROR${NC} [$1]: $2"
    ERRORS=$((ERRORS + 1))
}

warn() {
    echo -e "${YELLOW}WARN${NC}  [$1]: $2"
    WARNINGS=$((WARNINGS + 1))
}

pass() {
    echo -e "${GREEN}OK${NC}    [$1]: $2"
}

echo "Checking workflows in: $WORKFLOW_DIR"
echo ""

for f in "$WORKFLOW_DIR"/*.md; do
    name="$(basename "$f")"

    # Skip README
    [ "$name" = "README.md" ] && continue

    # --- Frontmatter checks ---
    if ! head -1 "$f" | grep -q '^---$'; then
        error "$name" "Missing YAML frontmatter (must start with ---)"
        continue
    fi

    # Check for required frontmatter fields
    # Extract frontmatter between the two --- lines (skip first ---, stop at second ---)
    frontmatter=$(sed -n '2,/^---$/p' "$f" | sed '$d')
    if ! echo "$frontmatter" | grep -q '^name:'; then
        error "$name" "Missing 'name:' in frontmatter"
    fi
    if ! echo "$frontmatter" | grep -q '^description:'; then
        error "$name" "Missing 'description:' in frontmatter"
    fi

    # --- Required sections ---
    if ! grep -qi '## When to use' "$f"; then
        error "$name" "Missing '## When to use this skill' section"
    else
        pass "$name" "Has 'When to use' section"
    fi

    if ! grep -qi '## Absolute Constraints' "$f" && ! grep -qi '## Hard Constraint' "$f"; then
        error "$name" "Missing '## Absolute Constraints' section"
    else
        pass "$name" "Has constraints section"
    fi

    # --- Tool-specific language checks ---
    # Check for bare tool function names (not inside code blocks or tool-capabilities references)
    tool_violations=""

    # Check for tool-specific API calls used as instructions (not in examples or reference text)
    while IFS= read -r line; do
        # Skip lines inside code blocks (rough heuristic: starts with spaces/tabs or ```)
        [[ "$line" =~ ^[[:space:]]*\` ]] && continue
        [[ "$line" =~ ^\`\`\` ]] && continue

        # Check for direct tool invocation patterns
        if echo "$line" | grep -qE '`(view_file|list_dir|grep_search|write_to_file|run_command)`' 2>/dev/null; then
            # Allow if it's in an "Integration Points" or "Absolute Constraints" note about capabilities
            if ! echo "$line" | grep -qi 'tool-capabilities\|reference/tool\|canonical location'; then
                tool_violations="${tool_violations}\n  - Line: $(echo "$line" | head -c 120)"
            fi
        fi

        # Check for hardcoded MCP tool names
        if echo "$line" | grep -qE 'mcp__atlassian__|mcp_atlassian-mcp-server_' 2>/dev/null; then
            tool_violations="${tool_violations}\n  - MCP: $(echo "$line" | head -c 120)"
        fi
    done < "$f"

    if [ -n "$tool_violations" ]; then
        warn "$name" "Contains tool-specific language (should use capability language):$tool_violations"
    else
        pass "$name" "Uses tool-agnostic language"
    fi
done

echo ""
echo "---"

# --- Installer coverage check ---
echo ""
echo "Checking installer gitignore coverage..."

INSTALL_SCRIPT="$SCRIPT_DIR/../install.sh"
if [ -f "$INSTALL_SCRIPT" ]; then
    # Find all .agents/ output paths referenced in workflows (look for mkdir, save, write, create, output patterns)
    agent_paths=$(grep -rhoE '\.agents/[a-zA-Z]+/' "$WORKFLOW_DIR" 2>/dev/null | sort -u)

    # Known non-output directories that may be referenced in prose
    known_non_output=(".agents/skills/" ".agents/workflows/" ".agents/reference/")

    for path in $agent_paths; do
        # Skip non-output directories
        skip=false
        for known in "${known_non_output[@]}"; do
            [ "$path" = "$known" ] && skip=true && break
        done
        $skip && continue

        if grep -qF "\"$path\"" "$INSTALL_SCRIPT" 2>/dev/null; then
            pass "install.sh" "Covers $path"
        else
            error "install.sh" "Missing gitignore entry for $path (referenced in workflows)"
        fi
    done
fi

echo ""
echo "---"
echo ""

if [ "$ERRORS" -gt 0 ]; then
    echo -e "${RED}FAILED${NC}: $ERRORS error(s), $WARNINGS warning(s)"
    exit 1
elif [ "$WARNINGS" -gt 0 ]; then
    echo -e "${YELLOW}PASSED WITH WARNINGS${NC}: $WARNINGS warning(s)"
    exit 0
else
    echo -e "${GREEN}PASSED${NC}: All checks clean"
    exit 0
fi
