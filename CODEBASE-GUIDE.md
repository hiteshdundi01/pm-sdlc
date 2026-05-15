# pm-sdlc Codebase Guide

## What This Is

pm-sdlc is a pure-markdown framework — no runtime, no dependencies, no build step. It's a collection of structured prompts (called "workflows") that AI coding assistants consume to perform disciplined software development tasks.

## Architecture

### The Workflow Chain

Workflows are designed to be used in sequence, where the output of one feeds into the next:

```
ideate → create-prd → create-stories
                            ↓
              prime-for-feature → plan-feature ⇄ critique-plan
                                       ↓
                              implement-feature → code-review
```

**create-global-rules** is a standalone workflow used once per project to bootstrap conventions.

### Workflow Anatomy

Every workflow follows the same internal structure:

1. **Frontmatter** — YAML metadata (name, description, argument-hint)
2. **Purpose** — What the workflow does and its core philosophy
3. **When to use** — Trigger conditions
4. **Phases** — Ordered steps with explicit gates between them
5. **Constraints** — Non-negotiable rules
6. **Integration Points** — How it connects to other workflows and external tools

### Phase Gates

Workflows enforce quality through phase gates — conditions that MUST be met before proceeding. For example:

- `ideate` won't proceed past Phase 1 without user input on who the product is for
- `implement-feature` won't generate a report until E2E tests pass
- `code-review` won't write reports unless `.agents/reviews/` is gitignored

### Reference Documents

Workflows load reference documents at runtime for domain-specific knowledge:

| Document | Used By | Purpose |
|----------|---------|---------|
| `frameworks.md` | `ideate` | 7 structured ideation frameworks |
| `refinement-criteria.md` | `ideate` | Evaluation rubric for stress-testing ideas |
| `review-standards.md` | `code-review` | 5-axis review framework and severity conventions |
| `examples.md` | `ideate` | Example ideation session outputs |

### Runtime Artifacts

Workflows produce artifacts in `.agents/` subdirectories (all gitignored):

| Directory | Produced By | Contains |
|-----------|-------------|----------|
| `.agents/ideas/` | `ideate` | `.idea.md` one-pagers |
| `.agents/PRDs/` | `create-prd` | Product Requirements Documents |
| `.agents/stories/` | `create-stories` | Story breakdowns |
| `.agents/plans/` | `plan-feature` | Implementation plans |
| `.agents/plans/completed/` | `implement-feature` | Archived completed plans |
| `.agents/reviews/` | `code-review` | Review reports |
| `.agents/reviews/plan-reviews/` | `critique-plan` | Plan audit reports |
| `.agents/reports/` | `implement-feature` | Implementation reports |

### External Integrations

- **Jira** — `create-stories`, `prime-for-feature`, `implement-feature` can create/read/transition Jira issues via the Atlassian MCP server
- **Confluence** — `prime-for-feature` can load Confluence pages for context
- **Git/GitHub** — `code-review` fetches PR diffs via `gh` CLI, `implement-feature` manages branches

## Key Design Decisions

### Why Pure Markdown?

AI assistants read markdown natively. No parsing, no compilation, no runtime. The framework is as simple as it can possibly be while still being useful.

### Why Anti-Sycophancy Guards?

AI assistants have a tendency to agree with everything and find positive things to say. Several workflows explicitly counteract this:
- `critique-plan` has a "rationalization scan" that requires concrete justification for common phrases like "for testability" or "for flexibility"
- `code-review` has an "anti-patterns" section that names common rationalizations
- `ideate` requires the AI to "push back on weak ideas with specificity and kindness"

### Why Codebase Grounding?

Plans and reviews are useless if they're generic. The `plan-feature` workflow requires `file:line` citations from the actual codebase for every pattern reference. This prevents the AI from inventing patterns that don't exist in the project.

### Why Read-Only Reviews?

The `code-review` workflow uses isolated git worktrees and explicitly prohibits modifying the working tree. This prevents the review process from accidentally breaking the developer's in-progress work.

## Adding a New Workflow

1. Create `workflows/your-workflow.md` following the [workflow anatomy](#workflow-anatomy)
2. Add it to the workflow chain diagram in this file and in README.md
3. Add setup instructions in each `setup/*/README.md`
4. Update `install.sh` to include the new file
5. Test the full chain with a real codebase
