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
| `/ship-feature` | Orchestrate plan → implement → verify with a dispatched executor |

## Jira Integration

To enable Jira features in `create-stories`, `prime-for-feature`, and `implement-feature`:

1. Get an API token from https://id.atlassian.com/manage/api-tokens
2. Configure the Atlassian MCP server in your Claude Code settings
3. Workflows will automatically detect and use the MCP connection

## Multi-Model Execution (ship-feature)

`/ship-feature` uses Claude Code as the reasoning agent and dispatches implementation to a headless executor CLI. To enable the default Codex executor:

1. Install the Codex CLI and authenticate it (`codex login`)
2. Install pm-sdlc into the project with `--tool all` so the executor finds `AGENTS.md` and `.agents/workflows/implement-feature.md`
3. Allow the `codex` command in your Claude Code permission settings (the dispatch runs through the Bash tool)

Then:

```
/ship-feature .agents/stories/my-story.md --executor codex --model <model>
```

`--model` is passed through to the executor CLI unchanged — use any model your Codex account exposes. Dispatch command details live in `.claude/reference/tool-capabilities.md` (Executor Dispatch section).

## Reference Document Loading

Workflows reference documents in `.claude/reference/`:
- `ideate` loads `frameworks.md`, `refinement-criteria.md`, and `examples.md`
- `code-review` loads `review-standards.md`

These are loaded at runtime when the workflow needs them — no special configuration needed.
