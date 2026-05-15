# Antigravity (Gemini) Setup

## Automatic Installation

From the pm-sdlc repo root:

```bash
./install.sh /path/to/your/project --tool antigravity
```

This creates individual skill directories under `.gemini/antigravity/skills/` with the correct `SKILL.md` structure.

## Manual Installation

```bash
cd /path/to/your/project
SKILL_DIR=".gemini/antigravity/skills"

# Create a skill directory for each workflow
for f in /path/to/pm-sdlc/workflows/*.md; do
  name=$(basename "$f" .md)
  [ "$name" = "README" ] && continue
  mkdir -p "$SKILL_DIR/$name"
  cp "$f" "$SKILL_DIR/$name/SKILL.md"
done

# Copy reference docs for workflows that need them
mkdir -p "$SKILL_DIR/ideate/resources"
cp /path/to/pm-sdlc/reference/frameworks.md "$SKILL_DIR/ideate/resources/"
cp /path/to/pm-sdlc/reference/refinement-criteria.md "$SKILL_DIR/ideate/resources/"
cp /path/to/pm-sdlc/reference/examples.md "$SKILL_DIR/ideate/resources/"

mkdir -p "$SKILL_DIR/code-review/resources"
cp /path/to/pm-sdlc/reference/review-standards.md "$SKILL_DIR/code-review/resources/"

# Set up gitignore for runtime artifacts
echo '.agents/' >> .gitignore
```

## How It Works

Antigravity discovers skills automatically from `.gemini/antigravity/skills/`. Each skill directory contains:

```
.gemini/antigravity/skills/
├── ideate/
│   ├── SKILL.md                    # The workflow
│   └── resources/
│       ├── frameworks.md           # Ideation frameworks
│       ├── refinement-criteria.md  # Evaluation rubric
│       └── examples.md            # Example sessions
├── plan-feature/
│   └── SKILL.md
├── code-review/
│   ├── SKILL.md
│   └── resources/
│       └── review-standards.md
├── ...
```

## Usage

The agent will see these as available skills. You can reference them by name:

- "Use the **ideate** skill to refine this idea"
- "Run **plan-feature** for this Jira issue"
- "Do a **code-review** of PR #42"

Or the agent may automatically select the right skill based on your request.

## Jira Integration

Antigravity's Atlassian MCP server works natively with these workflows. If configured, `create-stories`, `prime-for-feature`, and `implement-feature` will automatically use MCP tools to interact with Jira.
