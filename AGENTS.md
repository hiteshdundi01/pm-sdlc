# pm-sdlc — AGENTS.md

> This file provides project context for OpenAI Codex and other AI agents that use AGENTS.md conventions.

## Project Overview

pm-sdlc is an AI-powered SDLC framework: structured markdown workflows that turn AI coding assistants into disciplined engineering partners. There is no runtime code — only markdown files consumed by AI tools.

## Directory Structure

```
workflows/          # 12 canonical workflow definitions
reference/          # Supporting docs loaded by workflows at runtime
setup/              # Per-tool installation instructions
  claude-code/
  antigravity/
  codex/
examples/           # Real-world workflow output examples
docs/               # Extended documentation (workflow guide, best practices, FAQ)
```

## Available Workflows

Use these workflows in order for a complete development lifecycle:

1. **ideate** — Refine raw ideas into actionable concepts
2. **create-prd** — Generate Product Requirements Documents
3. **create-stories** — Break PRDs into Jira stories
4. **prime-for-feature** — Load codebase and task context
5. **plan-feature** — Create implementation plans grounded in actual code patterns
6. **critique-plan** — Audit plans for scope creep, YAGNI, and bloat
7. **implement-feature** — Execute plans with validation loops
8. **code-review** — 5-axis code review with isolated validation
9. **create-global-rules** — Generate AGENTS.md from codebase analysis
10. **validate** — Run linter, type checker, and tests with structured reporting
11. **retrospective** — Capture lessons learned and update project conventions
12. **ship-feature** — Orchestrate prime → plan → critique → implement → verify → merge as one run, dispatching implementation and the post-approval merge to a headless executor agent (two human gates: plan approval, ship decision)

## How to Use in a Project

When installed into a project (via `install.sh`), workflows live in the tool-specific location. To use a workflow:

1. Read the workflow file to understand its phases and constraints
2. Follow the phases in order, respecting all gates
3. Produce artifacts in the `.agents/` directory structure
4. Use the output as input to the next workflow in the chain

## Conventions

- Workflow *runtime outputs* go in `.agents/` subdirectories (plans, reviews, reports, retros, rules — all gitignored)
- For Codex installs, `.agents/workflows/` and `.agents/reference/` contain installed source and *are* tracked
- Plans require `file:line` citations from the actual codebase
- Reviews are read-only — never modify the working tree during review
- All workflows have "Absolute Constraints" sections — respect them

## Key Files

| File | Purpose |
|------|---------|
| `workflows/*.md` | Canonical workflow definitions |
| `reference/frameworks.md` | 7 ideation frameworks (SCAMPER, HMW, JTBD, etc.) |
| `reference/refinement-criteria.md` | Evaluation rubric for stress-testing ideas |
| `reference/review-standards.md` | 5-axis review framework and severity levels |
| `reference/tool-capabilities.md` | Maps capability language to tool-specific APIs |
| `install.sh` | Setup script for installing into projects |
