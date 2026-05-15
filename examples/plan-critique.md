# Plan Critique: Internal Funnel Analytics

## Anchors Used

- **Goal**: Track anonymous section transitions in the dashboard to inform feature prioritization (from PROJ-122).
- **Hard constraints**: No PII collection (AGENTS.md §Security); all tables must have RLS (AGENTS.md §Database Patterns); analytics failures must not break the UI.
- **Established patterns**: Service class with error handling (`client-service.ts`); RLS-enabled migrations (`0012_add_audit_log.sql`); co-located `__tests__/` with RLS verification.
- **Mode**: One-pass agentic execution.
- **Minimum-viable plan**:
  1. Migration: `funnel_events` table with RLS
  2. Service: `recordEvent()` + `getTopPaths()`
  3. Route: POST + GET endpoints
  4. Hook: `useSectionTracker()` with silent failure
  5. Tests: RLS isolation verification

## Strongest Things

1. **RLS-first data model**: The migration mirrors the established pattern exactly, including the firm_isolation policy. This is the hardest thing to retrofit.
2. **Silent failure in the hook**: Analytics should never break the product. The plan correctly treats telemetry as fire-and-forget.
3. **Test coverage for RLS isolation**: The most important test (cross-firm data leakage) is explicitly called out in Task 7.

## Findings by Axis

### 1. Scope Integrity — `fine`

Every task traces to a Jira AC or a hard constraint. No speculative additions.

### 2. Necessity — `minor`

**Task 4 (Register funnel routes)** and **Task 6 (Wire section tracker)** are trivially small — 1-2 line changes each. These could be merged into their preceding tasks (3 and 5 respectively) without losing atomicity, reducing the plan from 7 tasks to 5.

### 3. Pattern Fidelity — `fine`

Verified `client-service.ts:45-52` — the error handling pattern matches. Verified `0012_add_audit_log.sql:1-15` — the RLS pattern matches. Both citations are accurate.

### 4. Sequencing & Atomicity — `fine`

Tasks are correctly ordered: migration → service → routes → registration → hook → wiring → tests. Each task has a validation command.

### 5. Acceptance Criteria — `minor`

The AC "No PII in event data (no user IDs, names, or client data)" is not testable from outside. **Suggestion**: Add a specific AC: "Event table schema contains only `id`, `firm_id`, `section_from`, `section_to`, `created_at` — no user-identifying columns." This is verifiable by inspecting the migration.

### 6. Risk Coverage — `fine`

All three risks have concrete mitigations (debounce, integration test, try/catch). No vague intentions.

### 7. YAGNI / Speculative Generality — `fine`

No abstractions, no configuration knobs, no "for future flexibility" language. The plan builds exactly what's needed.

## CUT / CHANGE / ADD

### CHANGE

| # | Item | Action | Rationale |
|---|------|--------|-----------|
| 1 | Tasks 3+4 | Merge into single task | Route creation + registration is a single atomic change. Two tasks adds overhead without adding safety. |
| 2 | Tasks 5+6 | Merge into single task | Hook creation + wiring is inseparable — a hook that isn't wired is not verifiable. |
| 3 | AC: "No PII" | Make testable | Change to: "Event table schema contains only id, firm_id, section_from, section_to, created_at" |

### CUT

None.

### ADD

None.

## Overall Verdict

**Sound with minor adjustments — apply CHANGE list, then proceed.**

The plan is well-grounded, correctly scoped, and follows established patterns. The changes above reduce task count from 7 to 5 and make one AC more testable. No fundamental issues.
