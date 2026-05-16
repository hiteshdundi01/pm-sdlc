# Claude Code Setup

## Automatic Installation

From the pm-sdlc repo root:

```bash
./install.sh /path/to/your/project --tool claude-code
```

This copies workflows to `.claude/commands/` and reference docs to `.claude/reference/`.

## Manual Installation

```bash
cd /path/to/your/project

# Create directories
mkdir -p .claude/commands .claude/reference

# Copy workflows (exclude the README)
for f in /path/to/pm-sdlc/workflows/*.md; do
  [ "$(basename "$f")" = "README.md" ] && continue
  cp "$f" .claude/commands/
done

# Copy reference documents
cp /path/to/pm-sdlc/reference/*.md .claude/reference/

# Set up gitignore for runtime artifacts
echo '.agents/' >> .gitignore
```

## Usage

Workflows are available as slash commands in Claude Code:

| Command | Purpose |
|---------|---------|
| `/ideate` | Refine an idea |
| `/create-prd` | Generate a PRD |
| `/create-stories` | Create Jira stories from a PRD |
| `/prime-for-feature` | Load codebase and task context |
| `/plan-feature` | Create an implementation plan |
| `/critique-plan` | Audit a plan for bloat |
| `/implement-feature` | Execute a plan |
| `/code-review` | Review a PR or code scope |
| `/create-global-rules` | Generate AGENTS.md |

## Jira Integration

To enable Jira features in `create-stories`, `prime-for-feature`, and `implement-feature`:

1. Get an API token from https://id.atlassian.com/manage/api-tokens
2. Configure the Atlassian MCP server in your Claude Code settings
3. Workflows will automatically detect and use the MCP connection

## Reference Document Loading

Workflows reference documents in `.claude/reference/`:
- `ideate` loads `frameworks.md`, `refinement-criteria.md`, and `examples.md`
- `code-review` loads `review-standards.md`

These are loaded at runtime using `view_file` — no special configuration needed.
