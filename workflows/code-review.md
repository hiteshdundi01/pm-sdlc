---
name: code-review
description: Code review - reviews PRs, files, folders, or any code scope, optionally against an implementation plan. Read-only with respect to the repo working tree and current branch.
argument-hint: <pr-number|file|folder|scope> [--plan <path-to-plan>]
---

# Code Review

**Input**: $ARGUMENTS

## Your Mission

Perform a thorough code review:
1. **Understand** what you're reviewing and its purpose
2. **Load plan and project Git rules** to understand intended behavior and workflow constraints
3. **Check** the code against project patterns, plan specifications, and Git workflow rules
4. **Validate** in an isolated worktree (never on the user's current branch)
5. **Identify** issues by severity
6. **Report** to `.agents/reviews/` (which must be gitignored)

**Golden Rule**: Be constructive and actionable. Every issue should have a clear recommendation.

**Hard Constraint — Repo State Safety**: This skill is **read-only** with respect to the user's working tree and currently checked-out branch, with one exception: writing review reports into `.agents/reviews/` (which must be gitignored — see Phase 5). You MUST NOT:
- Run `git checkout`, `git switch`, or `gh pr checkout` on the main working tree.
- Write any file inside the repository other than under `.agents/reviews/`. Never touch `.git/` or any tracked path.
- Stage, commit, push, or amend anything during the review.
- Run formatters, linters, or codegen that modify files in the working tree.

If validation requires the PR's code locally, use an isolated `git worktree` (see Phase 4). Clean it up before finishing.

---

## Phase 1: DETERMINE SCOPE

### Capture Starting State

Before doing anything else, record the user's current state so you can verify it is untouched at the end:

```bash
git rev-parse --abbrev-ref HEAD     # current branch
git status --porcelain              # working tree state
pwd                                 # repo root
```

Hold these values for the post-review check in Phase 6.

### Parse Input

| Input Type | Example | Action |
|------------|---------|--------|
| PR number | `123`, `#123` | Fetch PR diff with `gh pr diff 123` (no checkout) |
| PR URL | `github.com/.../pull/123` | Extract number, fetch PR diff (no checkout) |
| File path | `src/api/flags.ts` | Review single file |
| Folder path | `server/src/` | Review all files in folder |
| Blank | (none) | Review unstaged git changes |

### Parse Optional Plan

| Flag | Example | Action |
|------|---------|--------|
| `--plan <path>` | `--plan .agents/plans/anp0-9.plan.md` | Load plan as review baseline |

If `--plan` is provided, read the plan file and extract:
- **Tasks**: The ordered task list with file targets and expected implementations
- **Acceptance Criteria**: The checklist of required outcomes
- **Types/Contracts**: Any type definitions, API shapes, or interface contracts specified
- **Risks & Mitigations**: Documented risks the code should address
- **Files to Change**: The expected file manifest (creates, updates, renames, deletes)
- **Patterns to Follow**: Codebase conventions the plan calls out

If no `--plan` is provided, the review proceeds normally without plan conformance checks.

### Get Review Target (Read-Only)

**For PR:** fetch metadata, diff, and commits without checking out.
```bash
gh pr view {NUMBER} --json number,title,author,headRefName,baseRefName,files,commits,mergeable,mergeStateStatus
gh pr diff {NUMBER}
# Commit graph of the PR — used in Phase 3 for Git workflow checks:
gh pr view {NUMBER} --json commits --jq '.commits[] | {oid: .oid, message: .messageHeadline, parents: (.parents // [] | length)}'
```

**For file/folder:**
```bash
find {path} -name "*.ts" -o -name "*.tsx" | grep -v node_modules
```

**For blank (unstaged changes):**
```bash
git diff --name-only
git diff
```

### Sizing Pre-flight

Count changed lines in the diff. Use this table to decide how to proceed:

| Diff Size | Action |
|-----------|--------|
| ≤ ~300 lines | Proceed normally |
| ~300–1000 lines | Proceed, but flag size in the report |
| > 1000 lines | **Stop and recommend splitting** unless the change is a pure deletion, automated refactor, or generated code. Note this in the output and ask the user whether to proceed anyway. |

Large changes hide issues. A review of an unreviewable change is worse than no review.

---

## Phase 2: CONTEXT

### Load the Judgment Framework

Load the `review-standards.md` reference file. It defines the five-axis review (correctness, readability, architecture, security, performance), the approval philosophy, severity conventions, and rationalizations to watch for. (Canonical location: `reference/review-standards.md`; when installed, check `resources/` in this skill directory or the tool-specific reference path.)

### Read Project Rules — Including Git Workflow

Read **all** of the following if present, in this order:
1. `AGENTS.md` at the repo root (and any nested `AGENTS.md` files relevant to the diff)
2. `GEMINI.md` at the repo root (Antigravity-specific overrides)
3. `CONTRIBUTING.md`
4. Any file under `.agents/rules/`

Extract specifically:
- **Branch naming conventions** (e.g., `feat/`, `fix/`, `chore/` prefixes)
- **Merge strategy** (rebase-and-merge, squash-and-merge, merge commit) — needed in Phase 3 to know what to flag
- **Sync strategy** (rebase vs merge for keeping branches current) — needed to flag merge commits in the PR
- **Linear history requirements**
- **Commit hygiene rules** (atomic commits, message format, no `wip`/`fixup` commits surviving to merge)
- **Force-push rules**
- **Hard prohibitions** (anything the project says agents must never do)

If no Git workflow file is present, default to: rebase-only sync, rebase-and-merge target, linear history required, atomic commits, no merge commits inside feature branches.

### Understand Intent

- For PRs: Read title and description
- For files: Understand the file's purpose in the codebase
- For changes: What was modified and why?

### Extract Plan Baseline (if plan provided)

Build a structured checklist from the plan:

1. **Acceptance Criteria Checklist**: Convert every `- [ ]` item into a verifiable check
2. **Task Completion Matrix**: Map each task to the files it touches — mark as DONE / PARTIAL / MISSING based on whether the files exist and contain the described implementation
3. **Contract Registry**: Collect all type definitions, API shapes, and interface contracts from the plan into a lookup table for Phase 3 verification
4. **Scope Boundary**: Note the plan's "Files to Change" manifest — flag any files in the PR that are NOT in the plan (scope creep) or plan files missing from the PR (incomplete)

---

## Phase 3: REVIEW

### Git Workflow Check (PRs only)

Before reviewing any code, audit the PR's commit graph against the workflow rules loaded in Phase 2. These findings are **High severity by default** because they violate the project's enforced workflow.

| Check | How |
|-------|-----|
| **No merge commits inside the PR branch** | Any commit with `parents > 1` in the PR's commit list is a merge commit. If sync strategy is rebase, this is a violation. |
| **Branch is rebased on the target branch** | If `mergeStateStatus` is `BEHIND` or non-mergeable due to staleness, flag it. |
| **Branch naming follows convention** | Check `headRefName` against the prefix rules from `AGENTS.md`. |
| **No `wip`, `fixup!`, `squash!`, or `temp` commits** | Scan commit message headlines. These must be squashed before merge. |
| **Atomic commits** | Look for commits that touch unrelated areas, or single logical changes split across many commits without reason. |
| **No secrets, large binaries, or generated artifacts in the diff** | Scan for credential-like strings, `.env*` files, lockfile-only PRs with no manifest change, etc. |
| **Commit messages follow project format** | Imperative mood, type prefix if Conventional Commits is used, etc. |

Record violations in the report under a dedicated **Git Workflow Issues** section.

### Review the Tests First

Tests reveal intent and what the author considered important. Before reading the implementation, walk the tests:

| Check | Question |
|-------|----------|
| **Presence** | Are there tests for the change? If not, why? (Some refactors and generated code are legitimately uncovered.) |
| **Behavior vs implementation** | Do tests assert on outputs and observable behavior, not internal state? |
| **Edge cases** | Empty, null, boundary, error paths — covered? |
| **Naming** | Would the test name alone tell you what failed? |
| **Regression value** | If someone broke this code, would the tests catch it? |

For bug fixes specifically: there should be a regression test that fails before the fix and passes after.

### Review Each File

For each file in scope, check:

| Category | Check |
|----------|-------|
| **Correctness** | Does the code work as intended? Edge cases handled? Error paths handled? |
| **Type Safety** | Are types explicit, no implicit `any`? |
| **Patterns** | Does it follow existing codebase patterns? |
| **Error Handling** | Are errors handled appropriately and at the right layer? |
| **Security** | User input validated? Secrets out of code/logs? Auth checks present? Injection-safe? External data treated as untrusted? |
| **Performance** | N+1 queries? Unbounded loops? Missing pagination? Synchronous work that should be async? |
| **Tests** | (Already reviewed above — confirm they actually exercise this file's behavior.) |

### Dependency Check

If the diff includes `package.json`, `pnpm-lock.yaml`, or other dependency manifests, run a dedicated dependency review:
- Does the existing stack already solve this?
- Bundle size impact?
- Actively maintained? Check last commit and open issues.
- Known vulnerabilities? (`pnpm audit`)
- License compatibility?

Every new dependency is a liability. Prefer existing utilities.

### Dead Code Check

After reviewing the change, look for orphaned code that the change has rendered unused or unreachable. List explicitly — don't silently flag for deletion. The author may have left it intentionally during a transition.

### Plan Conformance (if plan provided)

For each file, additionally check:

| Category | Check |
|----------|-------|
| **Task Fidelity** | Does the implementation match the task description? |
| **Contract Match** | Do types/interfaces match the plan's contract registry? |
| **Risk Coverage** | Are documented risks from the plan actually mitigated? |
| **Scope Alignment** | Are there changes outside the plan's file manifest? |
| **Acceptance Gaps** | Which acceptance criteria are NOT satisfied by this code? |

> **Important**: Plan conformance is additive — it does NOT replace correctness checks.
> If the code deviates from the plan but is *correct*, flag it as "Plan Deviation" (Medium)
> with a note on whether the plan or the code should be updated.
> If the plan itself appears to have errors, flag it as "Plan Issue" (informational).

### AI-Generated Code

If the change appears AI-generated (commit metadata, PR description, telltale patterns), apply *more* scrutiny, not less. AI code is confident and plausible even when wrong. Pay special attention to:
- Fabricated APIs or imports that don't exist
- Plausible-but-incorrect error handling
- Tests that pass without exercising real behavior
- Over-engineering or unnecessary abstractions

### Categorize Issues

| Severity | Criteria | Blocks merge? |
|----------|----------|---------------|
| **Critical** | Security issues, data loss, crashes, broken functionality, secrets committed | Yes — always |
| **High** | Type violations, missing error handling, logic errors, acceptance criteria failures, **Git workflow violations** | Yes — unless explicitly deferred with written justification |
| **Medium** | Pattern inconsistencies, missing edge cases, plan deviations | No — but should be addressed |
| **Low** | Style suggestions, minor improvements, nits | No — author may ignore |

---

## Phase 4: VALIDATE (Isolated Worktree)

Validation must run against the **PR's code**, not the user's current branch, and must NOT change the user's working tree.

### Set Up an Isolated Worktree (PRs only)

```bash
# Create a temporary worktree outside the user's working area
WT_DIR="$(mktemp -d)/pr-{NUMBER}"
git fetch origin pull/{NUMBER}/head:pr-{NUMBER}-review-tmp
git worktree add "$WT_DIR" pr-{NUMBER}-review-tmp
cd "$WT_DIR"
```

For file/folder/blank scope, skip the worktree — validation runs in place on what's already there, **but do not run anything that modifies files** (no `--write`, no `--fix`, no codegen).

### Run Checks

```bash
pnpm install --frozen-lockfile     # if package.json changed
pnpm run build                     # type check
pnpm run lint                      # lint (read-only — no --fix)
pnpm test                          # tests
```

**If validation fails:** continue the review rather than aborting — the author needs both feedback and the failure information. Record failures in the report. A failing build, lint, or test set automatically makes the recommendation **NEEDS WORK** regardless of other findings.

### Tear Down the Worktree

When done, return to the original directory and remove the worktree and temp branch:

```bash
cd -                                          # back to the repo root
git worktree remove "$WT_DIR" --force
git branch -D pr-{NUMBER}-review-tmp 2>/dev/null || true
rm -rf "$(dirname "$WT_DIR")"
```

If any step fails, surface the error — do not leave dangling worktrees.

---

## Phase 5: REPORT

### Recommendation Rubric

| Condition | Recommendation |
|-----------|----------------|
| Any Critical issue | NEEDS WORK |
| Any High issue not explicitly deferred (including Git workflow violations) | NEEDS WORK |
| Validation (build/lint/tests) failing | NEEDS WORK |
| Otherwise | APPROVE |

Apply the principle: **approve if the change improves overall code health**. Do not block on Medium/Low issues, personal style preferences, or "this isn't how I would have written it." Comment on them, but approve.

### Create Report — In Repo, Gitignored

Reports live at `.agents/reviews/` inside the repo. This directory MUST be gitignored. The skill verifies this before writing and refuses to proceed if it isn't.

**Output path**: `.agents/reviews/{scope-name}-review.md`

```bash
REPO_ROOT="$(git rev-parse --show-toplevel)"
REPORT_DIR="$REPO_ROOT/.agents/reviews"
REPORT_PATH="$REPORT_DIR/{scope-name}-review.md"

# Verify .agents/reviews/ is gitignored before writing anything.
# If it isn't, STOP. Do not auto-modify .gitignore mid-review — that would
# create a tracked change bundled with whatever PR is being reviewed.
if ! git check-ignore -q "$REPORT_DIR/probe" 2>/dev/null; then
  cat >&2 <<EOF
ERROR: .agents/reviews/ is not gitignored. Refusing to write a review file
that would appear as a tracked change in the working tree.

Fix this once, on its own chore branch:

    git checkout -b chore/gitignore-agent-reviews origin/main
    echo '.agents/reviews/' >> .gitignore
    git add .gitignore
    git commit -m "Ignore agent review artifacts"
    # ...then open and merge a PR for this change.

Re-run the review after that PR is merged.
EOF
  exit 1
fi

mkdir -p "$REPORT_DIR"
```

**Report template (with plan)**:

```markdown
# Code Review: {SCOPE}

**Scope**: {PR #N / file path / folder path / unstaged changes}
**Diff Size**: {N lines changed across M files}
**Plan**: {plan file path or "None"}
**Recommendation**: {APPROVE / NEEDS WORK}

## Summary

{2-3 sentences: What was reviewed and overall assessment}

## Required Changes

> Issues that block merge — Critical and non-deferred High items.

{List or "None — ready to merge"}

## Git Workflow Issues

> Violations of the project's Git workflow rules (from AGENTS.md / CONTRIBUTING.md / defaults).

{List or "None"} — examples: merge commit inside PR branch, branch behind target, non-conforming branch name, `wip` commits not squashed, secrets in diff.

## Plan Coverage

> This section is included when a `--plan` was provided.

### Acceptance Criteria

| # | Criterion | Status | Notes |
|---|-----------|--------|-------|
| 1 | {criterion from plan} | {PASS/FAIL/PARTIAL} | {details} |

**Coverage**: {N}/{Total} criteria met

### Task Completion

| Task | Files | Status | Notes |
|------|-------|--------|-------|
| Task 1: {name} | {files} | {DONE/PARTIAL/MISSING} | {details} |

### Scope Analysis

- **Plan files implemented**: {N}/{Total}
- **Extra files not in plan**: {list or "None"}
- **Plan files missing from PR**: {list or "None"}

### Plan Deviations

{List of intentional or accidental deviations from the plan, with assessment of whether the code or the plan should be updated}

### Plan Issues

{Any errors, ambiguities, or gaps found in the plan itself — informational}

## Issues Found

### Critical
{List or "None"}

### High Priority
{List or "None" — note any that are explicitly deferred and why}

### Medium Priority
{List or "None"}

### Suggestions / Nits
{List or "None"}

## Dead Code Identified

{List of code rendered unused by this change, with file:line references, or "None". Do not delete — surface for the author's decision.}

## Validation Results

| Check | Status | Notes |
|-------|--------|-------|
| Type Check | {PASS/FAIL} | {failure summary if FAIL} |
| Lint | {PASS/FAIL} | {failure summary if FAIL} |
| Tests | {PASS/FAIL} | {failed test names if FAIL} |

> Validation was run in an isolated worktree against the PR's HEAD commit. The user's working tree was not modified.

## What's Good

{Include only if there is something genuinely noteworthy — a clean abstraction, a thoughtful test, a hard-won simplification. Skip this section if there isn't.}

## Recommendation

{What needs to happen next — concrete actions for the author}
```

**Report template (without plan)**: Use the same template but omit the "Plan Coverage" section entirely.

### Post to GitHub (if PR)

```bash
gh pr review {NUMBER} --comment --body-file "$REPORT_PATH"
```

The body file lives under `.agents/reviews/` which is gitignored, so it never enters the PR diff.

---

## Phase 6: VERIFY CLEAN STATE & OUTPUT

### Verify the User's Working Tree Is Untouched

Compare against the values captured in Phase 1. Files under `.agents/reviews/` are gitignored, so they don't appear in `git status --porcelain` and won't affect this check:

```bash
test "$(git rev-parse --abbrev-ref HEAD)" = "{starting-branch}"
test "$(git status --porcelain)" = "{starting-porcelain}"
git worktree list                                                 # no leftover review worktrees
```

If any check fails, surface a warning prominently in the output and tell the user what was left behind. Do not exit silently.

### Output Summary

```markdown
## Review Complete

**Scope**: {what was reviewed}
**Diff Size**: {N lines / M files}
**Plan**: {plan path or "None"}
**Recommendation**: {APPROVE / NEEDS WORK}

**Working tree**: unchanged (branch {starting-branch}, {N} uncommitted files — same as before review)

### Git Workflow Issues

| Type | Count |
|------|-------|
| Merge commits in branch | {N} |
| Non-conforming commits (wip/fixup/etc.) | {N} |
| Branch out of date with target | {Yes/No} |
| Other workflow violations | {N} |

### Plan Coverage (if applicable)

| Metric | Value |
|--------|-------|
| Acceptance Criteria Met | {N}/{Total} |
| Tasks Complete | {N}/{Total} |
| Plan Deviations | {N} |
| Plan Issues Found | {N} |

### Issues Found

| Severity | Count | Blocks Merge |
|----------|-------|--------------|
| Critical | {N} | {N} |
| High | {N} | {N} |
| Medium | {N} | 0 |
| Low | {N} | 0 |

### Validation

| Check | Result |
|-------|--------|
| Type Check | {PASS/FAIL} |
| Lint | {PASS/FAIL} |
| Tests | {PASS/FAIL} |

### Report

`.agents/reviews/{scope-name}-review.md` (gitignored — not committed)
```