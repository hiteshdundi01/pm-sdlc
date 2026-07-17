# Workflows

These are the canonical workflow definitions for pm-sdlc. Each file is a structured prompt that guides an AI coding assistant through a specific SDLC phase.

## Lifecycle Order

```
ideate → create-prd → create-stories → prime-for-feature
→ plan-feature ⇄ critique-plan → implement-feature → validate → code-review
→ retrospective
```

`create-global-rules` is standalone — use it once per project.

`ship-feature` orchestrates `prime-for-feature` through `code-review` as one run: the orchestrating agent plans and verifies, and dispatches `implement-feature` to a headless executor agent. Two human gates: plan approval and ship decision.

## Workflow Descriptions

| Workflow | Input | Output | Next Step |
|----------|-------|--------|-----------|
| **ideate** | Raw idea or topic | `.agents/ideas/*.idea.md` | `create-prd` |
| **create-prd** | Conversation or idea file | `.agents/PRDs/*.prd.md` | `create-stories` |
| **create-stories** | PRD file | `.agents/stories/*.md` + Jira issues | `prime-for-feature` |
| **prime-for-feature** | Jira issue, codebase | Context in memory | `plan-feature` |
| **plan-feature** | Feature description, PRD, or Jira issue | `.agents/plans/*.plan.md` | `critique-plan` |
| **critique-plan** | Plan file | `.agents/reviews/plan-reviews/*.review.md` | `implement-feature` |
| **implement-feature** | Plan file | Code changes + `.agents/reports/*.md` | `validate` |
| **validate** | Optional `--fix` or `--scope` | Structured pass/fail report | `code-review` |
| **code-review** | PR number, file, or folder | `.agents/reviews/*.md` | `retrospective` |
| **retrospective** | Feature name or `--sprint` | `.agents/retros/*.md` + convention updates | Next feature |
| **create-global-rules** | Codebase | `AGENTS.md` at project root | — |
| **ship-feature** | Story file, Jira key, or feature description | Orchestrated run: plan + critique + dispatched implementation + independent verification | `retrospective` |

## Reference Documents

Workflows load reference documents at runtime:

- **ideate** loads: `frameworks.md`, `refinement-criteria.md`, `examples.md`
- **code-review** loads: `review-standards.md`

These live in the `reference/` directory (sibling to this one in the canonical layout).

## File Format

Every workflow uses this structure:

1. **YAML frontmatter** — `name`, `description`, optional `argument-hint`
2. **Title and purpose** — what the workflow does
3. **When to use** — trigger conditions  
4. **Phases** — ordered steps with gates
5. **Absolute Constraints** — non-negotiable rules
6. **Integration Points** — connections to other workflows and tools
