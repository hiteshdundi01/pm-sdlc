# Best Practices

Lessons learned from real-world use of pm-sdlc workflows across multiple projects.

## General Principles

### 1. Trust the Chain, Respect the Gates

The workflows are sequenced for a reason. Skipping steps feels faster but costs more:

| Shortcut | What Goes Wrong |
|----------|----------------|
| Skip `ideate`, jump to PRD | PRD solves the wrong problem. Rework at the spec level. |
| Skip `prime-for-feature` | Plan uses generic patterns. Implementation doesn't match codebase. |
| Skip `critique-plan` | Plan has scope creep. Implementation takes 3x longer. |
| Skip `validate` before review | Code review finds build failures instead of design issues. |
| Skip `retrospective` | Same mistakes recur. Conventions stay stale. |

Phase gates exist because AI assistants are eager to please and will happily proceed with insufficient information. The gates force completeness.

### 2. Feed Context, Get Quality

AI workflows are only as good as their input. Provide:

- **Jira issue keys** — not just descriptions. The workflow will fetch full context.
- **PRD file paths** — not summaries. The workflow reads the whole document.
- **Specific files** — "review `src/services/`" beats "review the services layer."

### 3. Push Back on the AI

These workflows are designed to resist sycophancy, but the user needs to do their part:

- If `ideate` generates only variations you'd expect, say "push harder"
- If `critique-plan` says everything is fine, ask "what's the riskiest assumption?"
- If `code-review` only finds nits, ask "what would you worry about in production?"

---

## Workflow-Specific Tips

### ideate

- **Don't accept the first framing.** The HMW statement shapes everything — iterate on it.
- **The "Not Doing" list is the real output.** If nothing was cut, the scope is too vague.
- **Name your user.** "Everyone" is not a user. A specific persona unlocks specific solutions.

### create-prd

- **Review the phases carefully.** These become your sprint plan. Unrealistic phases create technical debt.
- **Challenge the tech stack.** If the PRD assumes a technology, make sure it's justified.

### create-stories

- **Check story independence.** Each story should be independently deployable and reviewable.
- **Challenge story size.** If a story takes more than 2 days, it needs to be split.
- **Validate Jira before creating issues.** Use `--project` and `--epic` to pre-validate.

### prime-for-feature

- **Run this EVERY TIME you start a new feature.** Context loading is not optional.
- **Include Jira keys.** The AC reconciliation catches stale tickets that would waste implementation time.
- **Check the conventions.** If priming finds no AGENTS.md or CLAUDE.md, run `create-global-rules` first.

### plan-feature

- **Verify the `file:line` citations.** Open the cited files and confirm the patterns match what the plan describes.
- **Count the tasks.** More than 10 tasks for a single story usually means the story is too big.
- **Check the validation commands.** Plans sometimes reference commands that don't exist in the project.

### critique-plan

- **Don't skip this.** It's the cheapest quality gate in the chain.
- **Read the minimum-viable sketch.** If the plan is 3x the minimum, something is wrong.
- **Act on CUT items.** Cutting scope before implementation is free. Cutting after is expensive.

### implement-feature

- **Trust the validation loop.** If the build breaks, fix it before moving on. Accumulating broken state is the #1 cause of failed implementations.
- **Read the mirror files.** The plan references specific code to copy patterns from. Read it.
- **Don't skip E2E.** Static analysis and unit tests don't catch integration issues.

### validate

- **Run without `--fix` first.** Understand what's broken before auto-fixing.
- **Use `--scope` for targeted checks** when you only changed one area.
- **If validate passes locally but CI fails**, your local environment doesn't match CI.

### code-review

- **Use `--plan` for plan conformance checking.** This catches scope creep and missing acceptance criteria.
- **Review test quality, not just test existence.** Tests that only assert mock interactions don't catch real bugs.
- **Check the git workflow section.** Merge commits in feature branches cause problems downstream.

### retrospective

- **Do it while it's fresh.** Within 24 hours of shipping, not next sprint.
- **Review actual artifacts.** Don't rely on feelings — read the reports.
- **Apply the "Must Do" actions immediately.** Deferred actions never happen.

---

## Common Pitfalls

### 1. Over-Engineering Plans

**Symptom**: Plans have 15+ tasks, create 8+ new files, introduce abstractions "for flexibility."

**Fix**: Run `critique-plan`. If the minimum-viable sketch has 5 tasks and the plan has 15, the delta needs justification.

### 2. Under-Priming

**Symptom**: Plans reference generic patterns ("use a service layer") instead of specific code ("mirror `src/services/client-service.ts:45-52`").

**Fix**: Run `prime-for-feature` before planning. Every plan should have `file:line` citations.

### 3. Skipping Validation Loops

**Symptom**: Implementation fails at the end with cascading type errors.

**Fix**: The `implement-feature` workflow runs validation after every task. If you're implementing manually, run `validate` after each change.

### 4. Rubber-Stamp Reviews

**Symptom**: Reviews say "LGTM" with 2 nits and no substantive findings.

**Fix**: Check the review for all 5 axes (correctness, readability, architecture, security, performance). If an axis is missing, the review is incomplete.

### 5. Stale Jira Tickets

**Symptom**: Acceptance criteria on Jira tickets don't match the PRD.

**Fix**: `prime-for-feature` reconciles ACs against the PRD. Run it before planning to catch drift.

---

## Measuring Workflow Effectiveness

Track these across features to see if the workflows are improving your process:

| Metric | How to Measure | Target |
|--------|---------------|--------|
| Plan accuracy | (Tasks completed as planned) / (Total tasks) | > 80% |
| Review rework | Critical/High issues found in review | < 2 per PR |
| Critique hit rate | CUT/CHANGE items that were actually needed | > 60% |
| Deviation rate | Deviations from plan per feature | < 3 |
| Retro action completion | Actions applied / Actions proposed | > 90% |
