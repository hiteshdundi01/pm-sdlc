---
name: validate
description: Runs the project's linter, type checker, and test suite. Reports any failures with actionable context. Use as a quick pre-commit or pre-PR check.
argument-hint: "[--fix] [--scope <path>]"
---

# Validate: Run All Quality Checks

A fast, comprehensive validation pass that runs the project's full quality pipeline — type checking, linting, and tests — and reports results in a structured format.

**Core Principle**: Run everything, report everything, fix nothing (unless `--fix` is passed). This is a read-only diagnostic by default.

## When to use this skill

- Before creating a PR or committing code
- After `implement-feature` completes, as a final sanity check
- When you want a quick health check of the project
- When the user asks to "validate", "check", "verify", or "run tests"
- As a pre-flight before `code-review`

## How to use it

**Input**: $ARGUMENTS

### Parse Flags

| Flag | Effect |
|------|--------|
| `--fix` | Run auto-fixers (lint `--fix`, format) before reporting. Without this flag, validation is read-only. |
| `--scope <path>` | Limit checks to a specific file or directory where possible |
| (none) | Run all checks across the full project |

---

### Phase 1: DETECT — Identify the Project's Quality Stack

Discover what tools are available by checking project configuration:

```bash
# Check for configuration files
ls package.json Cargo.toml pyproject.toml Makefile justfile 2>/dev/null
```

#### For Node.js / TypeScript projects:

Read `package.json` scripts to find the actual commands:

| Check | Common Script Names | Fallback |
|-------|-------------------|----------|
| Type check | `typecheck`, `type-check`, `check-types`, `build` | `npx tsc --noEmit` |
| Lint | `lint`, `lint:check` | `npx eslint .` |
| Format check | `format:check`, `prettier:check` | `npx prettier --check .` |
| Tests | `test`, `test:unit`, `test:run` | `npx vitest run` or `npx jest` |

**Always prefer the project's own scripts** over generic commands. Check `package.json` `"scripts"` first.

#### For Rust projects:

| Check | Command |
|-------|---------|
| Type check + build | `cargo build` |
| Lint | `cargo clippy -- -D warnings` |
| Format check | `cargo fmt --check` |
| Tests | `cargo test` |

#### For Python projects:

| Check | Command |
|-------|---------|
| Type check | `mypy .` or `pyright` (check `pyproject.toml` for configured tool) |
| Lint | `ruff check .` or `flake8` |
| Format check | `ruff format --check .` or `black --check .` |
| Tests | `pytest` |

### Phase 2: EXECUTE — Run Each Check

Run checks in this order (fastest feedback first):

#### 2.1 Type Check

```bash
{type-check-command}
```

Capture exit code and output. If it fails, continue to the next check — do NOT stop.

#### 2.2 Lint

If `--fix` was passed:
```bash
{lint-fix-command}    # e.g., pnpm run lint --fix
```

Otherwise:
```bash
{lint-check-command}  # e.g., pnpm run lint
```

#### 2.3 Format (if available)

If `--fix` was passed:
```bash
{format-fix-command}  # e.g., npx prettier --write .
```

Otherwise:
```bash
{format-check-command}  # e.g., npx prettier --check .
```

#### 2.4 Tests

```bash
{test-command}
```

If the project has multiple test suites (unit, integration, e2e), run them all and report separately.

### Phase 3: REPORT — Structured Results

Output a concise, actionable summary:

```markdown
## Validation Results

| Check | Status | Details |
|-------|--------|---------|
| Type Check | {✅ PASS / ❌ FAIL} | {error count or "clean"} |
| Lint | {✅ PASS / ❌ FAIL} | {error count, warning count} |
| Format | {✅ PASS / ❌ FAIL / ⏭️ SKIP} | {file count or "N/A"} |
| Tests | {✅ PASS / ❌ FAIL} | {passed}/{total}, {failed} failed |

**Overall**: {✅ ALL PASSING / ❌ FAILURES FOUND}
```

#### If failures exist, add detail:

```markdown
### Type Check Failures

| # | File | Line | Error |
|---|------|------|-------|
| 1 | `src/service.ts` | 42 | Type 'string' is not assignable to type 'number' |
| 2 | `src/handler.ts` | 15 | Property 'foo' does not exist on type 'Bar' |

### Lint Failures

| # | File | Line | Rule | Message |
|---|------|------|------|---------|
| 1 | `src/utils.ts` | 10 | no-unused-vars | 'helper' is defined but never used |

### Test Failures

| # | Test | Suite | Error |
|---|------|-------|-------|
| 1 | `should handle empty input` | `parser.test.ts` | Expected [] but received undefined |

### Recommended Fixes

1. {Specific, actionable fix for failure #1}
2. {Specific, actionable fix for failure #2}
```

If `--fix` was used:
```markdown
### Auto-fixed

- Lint: {N} issues auto-fixed
- Format: {N} files reformatted

### Remaining (manual fix needed)

{List of issues that couldn't be auto-fixed}
```

---

## Absolute Constraints

1. **NEVER modify files without `--fix`** — default mode is read-only diagnostic.
2. **NEVER skip a check because a previous one failed** — run all checks and report all results.
3. **NEVER invent commands** — always discover them from the project's configuration files.
4. **NEVER run `--fix` on files outside the `--scope`** when scope is specified.
5. **Report ALL failures**, not just the first one — developers need the full picture.

## Integration Points

- **implement-feature**: Run `validate` after implementation to verify all checks pass before reporting.
- **code-review**: Run `validate` in the isolated worktree during Phase 4.
- **Git hooks**: Can be used as a pre-commit or pre-push check.
- **CI**: Mirrors what CI should run — if `validate` passes locally, CI should pass too.
