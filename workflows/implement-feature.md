---
name: implement-feature
description: Executes an implementation plan end-to-end with rigorous validation loops, test writing, E2E verification, and optional Jira updates. Use when the user asks to implement a plan, execute a plan, or build a feature from an existing .plan.md file.
---

# Implement Feature from Plan

Executes a `.plan.md` file produced by the `plan-feature` skill. Every change is validated immediately, tests are written for all new code, and a structured report is generated on completion.

**Core Philosophy**: Validation loops catch mistakes early. Run checks after every change. Fix issues immediately.

**Golden Rule**: If validation fails, fix it before moving on. Never accumulate broken state.

## When to use this skill

- The user asks to "implement" or "execute" a plan.
- The user provides a `.plan.md` file path and asks to build the feature.
- The user says "build it" or "go" after a plan has been created.
- The user references a plan in `.agents/plans/` and wants it executed.

## How to use it

**Input**: The user must provide a path to a `.plan.md` file (e.g., `.agents/plans/multi-tenant-migration.plan.md`). If no path is given, check `.agents/plans/` for the most recent plan and confirm with the user before proceeding.

---

### Phase 1: LOAD — Read and Parse the Plan

Read the plan file and extract:

- **Summary** — What we're building
- **Patterns to Mirror** — Code to copy from
- **Files to Change** — CREATE/UPDATE list
- **Tasks** — Implementation order
- **Validation Commands** — How to verify (from the plan's Validation section)
- **Jira Issue** — Check the plan's Metadata table for a Jira Issue key (e.g., `ANP0-5`). If present, this issue will be updated after implementation is complete.

> **GATE:** If the plan file is not found, stop and tell the user:
> `Error: Plan not found at {path}. Create a plan first with the plan-feature skill.`

---

### Phase 2: PREPARE — Ensure Clean Git State

```bash
git branch --show-current
git status
```

| State | Action |
|-------|--------|
| On main/master, clean working tree | Create branch: `git checkout -b feature/{plan-name}` |
| On main/master, dirty working tree | **STOP** — ask the user to stash or commit changes first |
| Already on a feature branch | Use it (confirm with user if branch name doesn't match the plan) |

---

### Phase 3: EXECUTE — Implement Each Task

For **each task** in the plan, in order:

#### 3.1 Verify Assumptions

Before writing any code:

- **Read the target file** you're about to create or modify
- **Read adjacent files** — files it imports from, and files that import it
- **Verify the plan's references** — do the functions, interfaces, tables, or endpoints the plan mentions actually exist? Do they match the plan's expectations?
- **If assumptions are wrong**, adapt your approach before implementing. Document what differs from the plan.

#### 3.2 Implement

- Read the **MIRROR** file reference from the task and understand the pattern to follow
- Make the change as specified in the plan
- **Check integration**: verify your change connects correctly to adjacent code — do imports resolve? Do callers/callees still work? Does the data flow correctly across boundaries?

#### 3.3 Validate Immediately

**After EVERY task**, run the project's build command (e.g., `pnpm run build`, `cargo build`, etc. — use whatever the plan's Validation section specifies).

If it fails:
1. Read the error
2. Fix the issue
3. Re-run validation
4. **Only proceed to the next task when validation passes**

#### 3.4 Track Progress

Maintain a running log:

```
Task 1: CREATE src/x.ts ✅
Task 2: UPDATE src/y.ts ✅
Task 3: UPDATE src/z.ts ⏳ (in progress)
```

If you deviate from the plan, document what changed and why.

---

### Phase 4: VALIDATE — Run All Checks and Write Tests

#### 4.1 Run All Checks

Execute every validation command from the plan's Validation section. Typically:

```bash
# Build / type check
{project-specific build command}

# Lint
{project-specific lint command}

# Tests
{project-specific test command}
```

**All must pass with zero errors.**

#### 4.2 Write Tests

You **MUST** write tests for new code:

- Every new function needs at least one test
- Error cases and edge cases need tests
- Update existing tests if behavior changed
- **Test across boundaries** — don't just test in isolation. If you added an API endpoint, test the response shape. If you added a service method, test it integrates correctly with its callers.
- Follow the test patterns documented in the plan's "Patterns to Follow" section

If tests fail:
1. Determine: bug in implementation or test?
2. Fix the actual issue
3. Re-run until green

#### 4.3 End-to-End Verification (REQUIRED)

> **⚠️ Do NOT proceed to Phase 5 until all E2E steps below pass.**

Re-read the plan and find the Acceptance Criteria and any end-to-end testing section. Execute every E2E test as a checklist:

- [ ] Start the application (dev servers, databases, etc.)
- [ ] For EACH end-to-end test in the plan:
  - [ ] Execute the test exactly as described
  - [ ] Verify the expected outcome matches the plan
  - [ ] If it fails: fix the issue, re-run, confirm it passes
- [ ] Confirm all E2E tests pass before proceeding

If the plan has no explicit E2E tests, perform a basic smoke test: start the app, exercise the new/changed feature, verify it works.

**This is a hard gate.** Static checks and unit tests alone are never sufficient.

---

### Phase 5: REPORT — Generate Implementation Report

Create the report at: `.agents/reports/{plan-name}-report.md`

```bash
mkdir -p .agents/reports
```

Use this template:

```markdown
# Implementation Report

**Plan**: `{plan-path}`
**Branch**: `{branch-name}`
**Status**: COMPLETE

## Summary

{Brief description of what was implemented}

## Tasks Completed

| # | Task | File | Status |
|---|------|------|--------|
| 1 | {description} | `src/x.ts` | ✅ |
| 2 | {description} | `src/y.ts` | ✅ |

## Validation Results

| Check | Result |
|-------|--------|
| Type check | ✅ |
| Lint | ✅ |
| Tests | ✅ ({N} passed) |

## Files Changed

| File | Action | Lines |
|------|--------|-------|
| `src/x.ts` | CREATE | +{N} |
| `src/y.ts` | UPDATE | +{N}/-{M} |

## Deviations from Plan

{List any deviations with rationale, or "None"}

## Tests Written

| Test File | Test Cases |
|-----------|------------|
| `src/x.test.ts` | {list of test case names} |
```

Then archive the plan:

```bash
mkdir -p .agents/plans/completed
mv {plan-path} .agents/plans/completed/
```

---

### Phase 6: UPDATE JIRA (if issue specified in plan)

**This phase is mandatory if the plan's Metadata table contains a Jira Issue key.** Skip only if the Jira Issue field is "N/A" or absent.

#### 6.1 Resolve Cloud ID

Resolve the Jira Cloud ID via the accessible-resources API.

#### 6.2 Transition the Issue

1. Fetch available transitions for the issue — each transition has a numeric `id` and a `name`
2. Find the most appropriate transition (prefer "In Review" or "In Progress"; fall back to "Done" if no review state exists)
3. Transition the issue using the numeric transition ID, NOT the status name

#### 6.3 Add Implementation Comment

Add a comment to the Jira issue (using markdown content format) with:
- What was implemented
- Branch name
- Files created/updated (count)
- Tests written (count)
- Any deviations from the plan
- Link to the implementation report file path

#### 6.4 Update Issue Description (if needed)

If the implementation resulted in meaningful deviations from the original issue description, update the issue description with the current state.

See `reference/tool-capabilities.md` for your environment's specific Jira API tool names.

---

### Phase 7: OUTPUT — Report to User

After all phases complete, provide a concise summary:

```
## Implementation Complete

**Plan**: `{plan-path}`
**Branch**: `{branch-name}`
**Status**: ✅ Complete

### Validation

| Check | Result |
|-------|--------|
| Type check | ✅ |
| Lint | ✅ |
| Tests | ✅ |

### Files Changed

- {N} files created
- {M} files updated
- {K} tests written

### Deviations

{Summary or "Implementation matched the plan."}

### Artifacts

- Report: `.agents/reports/{name}-report.md`
- Plan archived: `.agents/plans/completed/`

### Jira

{If issue was updated: "Updated {ISSUE_KEY}: transitioned to {status}, added implementation comment." Otherwise: "No Jira issue linked."}

### Next Steps

1. Review the report
2. Create PR: `gh pr create`
3. Merge when approved
```

---

## Failure Handling

| Failure | Action |
|---------|--------|
| Type check fails | Read error, fix issue, re-run |
| Tests fail | Fix implementation or test, re-run |
| Lint fails | Run auto-fix (e.g., `pnpm run lint --fix`), then manual fixes |
| Build fails | Check error output, fix and re-run |
| E2E smoke test fails | Debug, fix, restart app, re-verify |

**Never skip a failing check.** Every failure must be resolved before proceeding.

---

## Integration Points

- **plan-feature**: This skill consumes plans produced by the `plan-feature` skill. The plan's structure (Tasks, Validation, Metadata) is the contract between them.
- **Jira**: If a Jira issue key is present in the plan metadata, Phase 6 transitions the issue and adds an implementation comment.
- **Knowledge Base**: Check for project-specific context (startup scripts, service architecture, known gotchas) before executing.
- **Git**: This skill manages branch creation and expects a clean git state to start.

## Absolute Constraints

1. **NEVER skip validation after a task** — run the build/type-check after every single task.
2. **NEVER proceed past a failing check** — fix the failure before moving to the next task.
3. **NEVER skip the E2E gate** — static checks and unit tests alone are never sufficient.
4. **NEVER create a report claiming success if any check fails** — the report must reflect reality.
5. **ALWAYS archive the plan** to `.agents/plans/completed/` after successful implementation.
6. **Use capability language for Jira operations** — see `reference/tool-capabilities.md` for tool-specific API names.
