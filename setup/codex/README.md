# OpenAI Codex Setup

## Automatic Installation

From the pm-sdlc repo root:

```bash
./install.sh /path/to/your/project --tool codex
```

This copies workflows to `.agents/workflows/`, reference docs to `.agents/reference/`, and creates an `AGENTS.md` at the project root.

## Manual Installation

```bash
cd /path/to/your/project

# Create directories
mkdir -p .agents/workflows .agents/reference

# Copy workflows (exclude the README)
for f in /path/to/pm-sdlc/workflows/*.md; do
  [ "$(basename "$f")" = "README.md" ] && continue
  cp "$f" .agents/workflows/
done

# Copy reference docs
cp /path/to/pm-sdlc/reference/*.md .agents/reference/

# Copy AGENTS.md to project root
cp /path/to/pm-sdlc/AGENTS.md ./

# Set up gitignore for runtime artifacts
cat >> .gitignore << 'EOF'
.agents/plans/
.agents/reviews/
.agents/stories/
.agents/ideas/
.agents/PRDs/
.agents/reports/
.agents/retros/
.agents/rules/
EOF
```

## Usage

### With AGENTS.md

Codex reads `AGENTS.md` at the project root. The installed file describes available workflows and how to use them. You can reference specific workflows in your prompts:

```
Read .agents/workflows/plan-feature.md and use it to plan the implementation
of the user authentication feature described in the PRD.
```

### Workflow Chain

For best results, follow the workflow chain:

1. "Read `.agents/workflows/ideate.md` and help me refine this idea: [idea]"
2. "Read `.agents/workflows/create-prd.md` and generate a PRD from our discussion"
3. "Read `.agents/workflows/plan-feature.md` and plan the first phase"
4. "Read `.agents/workflows/critique-plan.md` and audit the plan"
5. "Read `.agents/workflows/implement-feature.md` and execute the plan"
6. "Read `.agents/workflows/code-review.md` and review the changes"

### Reference Documents

When a workflow says to load a reference document, point Codex to `.agents/reference/`:

```
Load .agents/reference/review-standards.md and use it for the code review.
```

## Acting as the Executor for ship-feature

When another tool runs the `ship-feature` orchestrator, Codex is the default executor: the orchestrator shells out to `codex exec` with a work order pointing at `.agents/workflows/implement-feature.md` and an approved plan. No extra setup beyond this page — the requirements are:

- Codex CLI installed and authenticated
- pm-sdlc installed in the target project (this provides `AGENTS.md` and `.agents/workflows/`)

The work order scopes the run: implement the plan on a feature branch, write the report to `.agents/reports/`, skip Jira, don't archive the plan. The orchestrator independently re-validates and reviews the result.

Codex is also the **merge owner**: after the human approves shipping, the orchestrator dispatches a merge order — Codex re-runs validation, merges the feature branch into the default branch, and reports the merge SHA. Merge orders never edit code; on conflict or failure Codex aborts and the orchestrator fixes.

## Customizing AGENTS.md

The installed `AGENTS.md` is a starting point. Customize it to:

- Add project-specific conventions
- Reference your tech stack and patterns
- Include project-specific workflows or overrides
- Document team-specific processes
