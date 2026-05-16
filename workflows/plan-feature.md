---
name: plan-feature
description: Generates a battle-tested implementation plan by analyzing the codebase for patterns, conventions, and architecture before producing an ordered task list. Use when the user asks to plan a feature, create an implementation plan, or prepare for a coding task from a PRD or feature description.
---

# Implementation Plan Generator

Transforms a feature description, PRD phase, or free-form requirement into a codebase-aware implementation plan. The plan is a context-rich document that enables one-pass implementation with zero guesswork.

**Core Principle**: PLAN ONLY — no code is written. Solutions must fit existing patterns. Explore the codebase FIRST.

## When to use this skill

- The user asks to "plan" a feature, story, or task.
- The user provides a PRD (`.prd.md`) and asks to plan the next phase.
- The user wants an implementation plan before coding begins.
- The user references a Jira issue and asks for a plan of attack.

## How to use it

### Phase 1: PARSE — Determine Input & Extract Requirements

Determine what the user provided and extract the feature understanding:

| Input | Action |
|-------|--------|
| `.prd.md` file path | Read the PRD file, extract the next pending phase |
| Other `.md` file path | Read the file, extract feature description |
| Jira issue key (e.g., `ANP0-5`) | Fetch the Jira issue (with markdown content format). See `reference/tool-capabilities.md` for your environment's Jira API. |
| Free-form text | Use directly as feature input |
| Blank / no argument | Use conversation context and active document state |

Extract and document:

- **Problem**: What are we solving?
- **User Story**: As a [user], I want to [action], so that [benefit]
- **Type**: `NEW_CAPABILITY` / `ENHANCEMENT` / `REFACTOR` / `BUG_FIX`
- **Complexity**: `LOW` / `MEDIUM` / `HIGH`
- **Jira Issue**: Capture if available from context, PRD, or user mention (optional — used by downstream skills)

> **GATE:** If the feature is ambiguous or critical information is missing, ask clarifying questions. Do NOT proceed until the user responds.

### Phase 2: EXPLORE — Study the Codebase

This is the most important phase. Explore the codebase to find:

1. **Similar implementations** — analogous features with `file:line` references
2. **Naming conventions** — actual variable, function, file naming examples from the codebase
3. **Error handling patterns** — how errors are created, propagated, and handled
4. **Type definitions** — relevant interfaces, types, schemas
5. **Test patterns** — test file structure, assertion styles, test runner configuration
6. **Build & validation commands** — check `package.json` scripts, `Cargo.toml`, `Makefile`, etc.

Document patterns in a structured table:

| Category | File:Lines | Pattern |
|----------|------------|---------|
| NAMING | `path/to/file.ts:10-15` | {pattern description} |
| ERRORS | `path/to/file.ts:20-30` | {pattern description} |
| TYPES | `path/to/file.ts:1-10` | {pattern description} |
| TESTS | `path/to/test.ts:1-25` | {pattern description} |

### Phase 3: DESIGN — Map Changes & Identify Risks

Using the patterns discovered in Phase 2:

- Determine which files need to be **created**
- Determine which files need to be **modified**
- Establish the **dependency order** (what must be done first)
- Identify the correct **validation commands** from the project

Document risks:

| Risk | Mitigation |
|------|------------|
| {potential issue} | {how to handle} |

### Phase 4: GENERATE — Write the Plan File

Create the plan as an artifact file at: `.agents/plans/{kebab-case-name}.plan.md`

Use the following template structure:

```markdown
# Plan: {Feature Name}

## Summary

{One paragraph: What we're building and the approach}

## User Story

As a {user type}
I want to {action}
So that {benefit}

## Metadata

| Field | Value |
|-------|-------|
| Type | {NEW_CAPABILITY / ENHANCEMENT / REFACTOR / BUG_FIX} |
| Complexity | {LOW / MEDIUM / HIGH} |
| Systems Affected | {list} |
| Jira Issue | {issue key if available, or "N/A"} |

---

## Patterns to Follow

### Naming
```
// SOURCE: {file:lines}
{actual code snippet from codebase}
```

### Error Handling
```
// SOURCE: {file:lines}
{actual code snippet from codebase}
```

### Tests
```
// SOURCE: {file:lines}
{actual code snippet from codebase}
```

---

## Files to Change

| File | Action | Purpose |
|------|--------|---------|
| `path/to/file.ts` | CREATE | {why} |
| `path/to/other.ts` | UPDATE | {why} |

---

## Tasks

Execute in order. Each task is atomic and verifiable.

### Task 1: {Description}

- **File**: `path/to/file.ts`
- **Action**: CREATE / UPDATE
- **Implement**: {what to do — be specific}
- **Mirror**: `path/to/example.ts:lines` — follow this pattern
- **Validate**: {project-specific command}

### Task 2: {Description}

- **File**: `path/to/file.ts`
- **Action**: CREATE / UPDATE
- **Implement**: {what to do}
- **Mirror**: `path/to/example.ts:lines`
- **Validate**: {project-specific command}

{Continue for each task...}

---

## Validation

```bash
# Build / type check
{project-specific build command}

# Lint
{project-specific lint command}

# Tests
{project-specific test command}
```

---

## Acceptance Criteria

- [ ] All tasks completed
- [ ] Build passes
- [ ] Tests pass
- [ ] Follows existing codebase patterns
```

### Phase 5: OUTPUT — Report to User

After creating the plan file, provide a concise summary in your response:

```
## Plan Created

**File**: `.agents/plans/{name}.plan.md`

**Summary**: {2-3 sentence overview}

**Scope**:
- {N} files to CREATE
- {M} files to UPDATE
- {K} total tasks

**Key Patterns**:
- {Pattern 1 with file:line}
- {Pattern 2 with file:line}

**Next Step**: Review the plan, then implement tasks in order.
```

## Absolute Constraints

1. **NEVER write implementation code** — this skill produces plans only.
2. **NEVER invent patterns** — every pattern reference must come from actual codebase files with `file:line` citations.
3. **NEVER guess validation commands** — always check `package.json`, `Makefile`, `Cargo.toml`, or equivalent for actual project commands.
4. **If a plan already exists** at the target path, confirm with the user before overwriting.

## Integration Points

- **Jira**: If a Jira issue key is available, fetch it for context. Include the key in plan metadata so downstream workflows can update issue status.
- **PRDs**: Plans can be generated from PRD phases stored in `.agents/PRDs/`.
- **Knowledge Base**: If your environment provides a persistent knowledge store (e.g., knowledge items, memory, or context files), check it for project-specific context (startup scripts, service architecture, known gotchas) before planning. See `reference/tool-capabilities.md` for your environment's specifics.
- **Existing Skills**: Reference other `.agents/skills/` files for layer-specific implementation guidance when relevant.
