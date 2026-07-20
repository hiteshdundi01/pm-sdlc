#!/usr/bin/env bash
set -euo pipefail

# pm-sdlc installer
# Installs workflow files and reference documents into a target project
# for use with Claude Code, Antigravity (Gemini), or OpenAI Codex.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_DIR="$SCRIPT_DIR/workflows"
REFERENCE_DIR="$SCRIPT_DIR/reference"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${BOLD}${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║         pm-sdlc installer              ║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════╝${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}→${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}!${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Validate source files exist
check_source() {
    if [ ! -d "$WORKFLOW_DIR" ]; then
        print_error "Workflow directory not found: $WORKFLOW_DIR"
        print_info "Run this script from the pm-sdlc repository root."
        exit 1
    fi

    if [ ! -d "$REFERENCE_DIR" ]; then
        print_error "Reference directory not found: $REFERENCE_DIR"
        exit 1
    fi

    local workflow_count
    workflow_count=$(find "$WORKFLOW_DIR" -name "*.md" -not -name "README.md" | wc -l | tr -d ' ')
    if [ "$workflow_count" -eq 0 ]; then
        print_error "No workflow files found in $WORKFLOW_DIR"
        exit 1
    fi
    echo -e "Found ${BOLD}$workflow_count${NC} workflows and $(find "$REFERENCE_DIR" -name "*.md" | wc -l | tr -d ' ') reference docs"
}

# Ensure .agents/ runtime directories and .gitignore entry
setup_agents_dir() {
    local target="$1"

    mkdir -p "$target/.agents"
    print_success "Created .agents/ runtime directory"

    # Add .agents/ subdirectories to .gitignore if not already present
    local gitignore="$target/.gitignore"
    local entries=(
        ".agents/plans/"
        ".agents/reviews/"
        ".agents/stories/"
        ".agents/ideas/"
        ".agents/PRDs/"
        ".agents/reports/"
        ".agents/retros/"
        ".agents/rules/"
    )

    touch "$gitignore"
    for entry in "${entries[@]}"; do
        if ! grep -qF "$entry" "$gitignore" 2>/dev/null; then
            echo "$entry" >> "$gitignore"
        fi
    done
    print_success "Updated .gitignore with .agents/ entries"
}

# Install for Claude Code
install_claude_code() {
    local target="$1"

    echo ""
    echo -e "${BOLD}Installing for Claude Code...${NC}"
    echo ""

    local cmd_dir="$target/.claude/commands"
    local ref_dir="$target/.claude/reference"

    mkdir -p "$cmd_dir" "$ref_dir"

    # Copy workflows as commands
    local count=0
    for f in "$WORKFLOW_DIR"/*.md; do
        [ "$(basename "$f")" = "README.md" ] && continue
        cp "$f" "$cmd_dir/"
        count=$((count + 1))
    done
    print_success "Copied $count workflows to .claude/commands/"

    # Copy reference docs
    cp "$REFERENCE_DIR"/*.md "$ref_dir/"
    print_success "Copied reference docs to .claude/reference/"

    setup_agents_dir "$target"

    echo ""
    echo -e "${GREEN}${BOLD}Done!${NC} Use workflows as slash commands:"
    echo -e "  ${CYAN}/ideate${NC}             — Refine an idea"
    echo -e "  ${CYAN}/create-prd${NC}         — Generate a PRD"
    echo -e "  ${CYAN}/create-stories${NC}     — Create Jira stories"
    echo -e "  ${CYAN}/prime-for-feature${NC}  — Load project context"
    echo -e "  ${CYAN}/plan-feature${NC}       — Plan implementation"
    echo -e "  ${CYAN}/critique-plan${NC}      — Audit a plan"
    echo -e "  ${CYAN}/implement-feature${NC}  — Execute a plan"
    echo -e "  ${CYAN}/code-review${NC}        — Review code/PRs"
    echo -e "  ${CYAN}/create-global-rules${NC} — Generate AGENTS.md"
    echo -e "  ${CYAN}/validate${NC}           — Run quality checks"
    echo -e "  ${CYAN}/retrospective${NC}      — Capture lessons learned"
    echo -e "  ${CYAN}/ship-feature${NC}       — Orchestrate plan → implement → verify via executor"
}

# Install for Antigravity (Gemini)
install_antigravity() {
    local target="$1"

    echo ""
    echo -e "${BOLD}Installing for Antigravity...${NC}"
    echo ""

    local skills_dir="$target/.gemini/antigravity/skills"
    mkdir -p "$skills_dir"

    # Each workflow becomes its own skill directory with SKILL.md
    local count=0
    for f in "$WORKFLOW_DIR"/*.md; do
        local basename
        basename="$(basename "$f" .md)"
        [ "$basename" = "README" ] && continue

        local skill_dir="$skills_dir/$basename"
        mkdir -p "$skill_dir"
        cp "$f" "$skill_dir/SKILL.md"

        # Copy reference docs into each skill that needs them
        case "$basename" in
            ideate)
                mkdir -p "$skill_dir/resources"
                cp "$REFERENCE_DIR/frameworks.md" "$skill_dir/resources/"
                cp "$REFERENCE_DIR/refinement-criteria.md" "$skill_dir/resources/"
                cp "$REFERENCE_DIR/examples.md" "$skill_dir/resources/"
                ;;
            code-review)
                mkdir -p "$skill_dir/resources"
                cp "$REFERENCE_DIR/review-standards.md" "$skill_dir/resources/"
                ;;
            ship-feature)
                mkdir -p "$skill_dir/resources"
                cp "$REFERENCE_DIR/tool-capabilities.md" "$skill_dir/resources/"
                ;;
        esac

        count=$((count + 1))
    done
    print_success "Created $count skill directories in .gemini/antigravity/skills/"

    setup_agents_dir "$target"

    echo ""
    echo -e "${GREEN}${BOLD}Done!${NC} Workflows are available as Antigravity skills."
    echo -e "  The agent will discover them automatically from ${CYAN}.gemini/antigravity/skills/${NC}"
}

# Install for OpenAI Codex
install_codex() {
    local target="$1"

    echo ""
    echo -e "${BOLD}Installing for OpenAI Codex...${NC}"
    echo ""

    local workflow_dest="$target/.agents/workflows"
    local ref_dest="$target/.agents/reference"

    mkdir -p "$workflow_dest" "$ref_dest"

    # Copy workflows
    local count=0
    for f in "$WORKFLOW_DIR"/*.md; do
        [ "$(basename "$f")" = "README.md" ] && continue
        cp "$f" "$workflow_dest/"
        count=$((count + 1))
    done
    print_success "Copied $count workflows to .agents/workflows/"

    # Copy reference docs
    cp "$REFERENCE_DIR"/*.md "$ref_dest/"
    print_success "Copied reference docs to .agents/reference/"

    # Copy AGENTS.md if it doesn't exist
    if [ ! -f "$target/AGENTS.md" ]; then
        cp "$SCRIPT_DIR/AGENTS.md" "$target/"
        print_success "Created AGENTS.md at project root"
    else
        print_warn "AGENTS.md already exists — skipping (review $SCRIPT_DIR/AGENTS.md for reference)"
    fi

    setup_agents_dir "$target"

    echo ""
    echo -e "${GREEN}${BOLD}Done!${NC} Workflows are in ${CYAN}.agents/workflows/${NC}"
    echo -e "  Reference AGENTS.md for workflow descriptions and usage."
}

# Install for all tools
install_all() {
    local target="$1"

    echo ""
    echo -e "${BOLD}Installing for all tools...${NC}"

    install_claude_code "$target"
    echo ""
    install_antigravity "$target"
    echo ""
    install_codex "$target"
}

# Main
main() {
    print_header

    # Parse target directory
    local target="${1:-}"

    if [ -z "$target" ]; then
        echo -e "Usage: ${BOLD}./install.sh <project-directory>${NC} [--tool <tool>]"
        echo ""
        echo "Options:"
        echo "  --tool <tool>    Skip prompt. One of: claude-code, antigravity, codex, all"
        echo ""
        echo "Examples:"
        echo "  ./install.sh /path/to/my-project"
        echo "  ./install.sh . --tool claude-code"
        echo "  ./install.sh ../my-app --tool all"
        exit 1
    fi

    # Resolve to absolute path
    target="$(cd "$target" 2>/dev/null && pwd)" || {
        print_error "Directory not found: $1"
        exit 1
    }

    # Parse --tool flag
    local tool=""
    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --tool)
                if [ -z "${2:-}" ]; then
                    print_error "--tool requires a value. One of: claude-code, antigravity, codex, all"
                    exit 1
                fi
                tool="$2"
                shift 2
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    echo -e "Target: ${BOLD}$target${NC}"
    check_source

    # If no --tool flag, prompt
    if [ -z "$tool" ]; then
        echo ""
        echo -e "${BOLD}Which AI tool are you using?${NC}"
        echo ""
        echo "  1) Claude Code      — installs to .claude/commands/"
        echo "  2) Antigravity      — installs to .gemini/antigravity/skills/"
        echo "  3) OpenAI Codex     — installs to .agents/workflows/ + AGENTS.md"
        echo "  4) All of the above — supports all three tools"
        echo ""
        read -rp "Enter choice [1-4]: " choice

        case "$choice" in
            1) tool="claude-code" ;;
            2) tool="antigravity" ;;
            3) tool="codex" ;;
            4) tool="all" ;;
            *)
                print_error "Invalid choice: $choice"
                exit 1
                ;;
        esac
    fi

    case "$tool" in
        claude-code) install_claude_code "$target" ;;
        antigravity) install_antigravity "$target" ;;
        codex)       install_codex "$target" ;;
        all)         install_all "$target" ;;
        *)
            print_error "Unknown tool: $tool. Use: claude-code, antigravity, codex, or all"
            exit 1
            ;;
    esac

    echo ""
    echo -e "${BOLD}Workflow chain:${NC}"
    echo -e "  ideate → create-prd → create-stories → prime-for-feature"
    echo -e "  → plan-feature ⇄ critique-plan → implement-feature → validate"
    echo -e "  → code-review → retrospective"
    echo ""
    echo -e "  Or orchestrated: ${CYAN}ship-feature${NC} runs prime → review in one session"
    echo -e "  with implementation dispatched to a headless executor agent."
    echo ""
}

main "$@"
