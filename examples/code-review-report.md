# Code Review: PR #68 — Internal Funnel Analytics

**Scope**: PR #68 (feat/funnel-analytics → main)
**Diff Size**: 247 lines changed across 7 files
**Plan**: `.agents/plans/completed/proj-122-funnel-analytics.plan.md`
**Recommendation**: APPROVE

## Summary

PR #68 implements anonymous section-transition tracking for the dashboard. The implementation closely follows the plan with one minor deviation (validation middleware placement). Code quality is high, RLS is correctly configured, and all tests pass including cross-firm isolation verification.

## Required Changes

None — ready to merge.

## Git Workflow Issues

None.

## Plan Coverage

### Acceptance Criteria

| # | Criterion | Status | Notes |
|---|-----------|--------|-------|
| 1 | POST /api/telemetry/events accepts { section_from, section_to } and returns 201 | PASS | Route test confirms |
| 2 | Events are scoped to the authenticated firm via RLS | PASS | Integration test with two firms |
| 3 | GET /api/telemetry/funnel returns top paths with counts | PASS | Verified in route test |
| 4 | Dashboard section transitions fire telemetry events | PASS | Hook wired to 4 sections |
| 5 | No PII in event data | PASS | Schema has only id, firm_id, section_from, section_to, created_at |
| 6 | Analytics failures don't break the dashboard UI | PASS | try/catch with silent failure in hook |
| 7 | All tasks completed and build passes | PASS | Build green |
| 8 | Tests verify RLS isolation between firms | PASS | `it('should not return events from other firms')` |

**Coverage**: 8/8 criteria met

### Task Completion

| Task | Files | Status | Notes |
|------|-------|--------|-------|
| Task 1: Create migration | `0017_add_funnel_events.sql` | DONE | RLS policy matches audit_log pattern |
| Task 2: Create funnel service | `funnel-service.ts` | DONE | Clean implementation |
| Task 3: Create routes + register | `funnel-routes.ts`, `index.ts` | DONE | Merged per critique |
| Task 4: Create hook + wire | `use-section-tracker.ts`, `app.tsx` | DONE | Merged per critique |
| Task 5: Write tests | `funnel-service.test.ts` | DONE | 6 test cases |

### Scope Analysis

- **Plan files implemented**: 7/7
- **Extra files not in plan**: None
- **Plan files missing from PR**: None

### Plan Deviations

1. **Validation middleware placement**: The plan specified `validate(schema)` as middleware in the route definition. The implementation uses `zod.parse()` inside the handler instead. This is functionally equivalent and matches a newer pattern emerging in `recommendation-routes.ts:30-35`. **Assessment**: Code is correct; plan can be updated to reflect the newer pattern.

### Plan Issues

None.

## Issues Found

### Critical
None.

### High Priority
None.

### Medium Priority

1. **Missing rate limiting on POST /api/telemetry/events** — While the 300ms debounce in the client prevents rapid fire from normal usage, there's no server-side rate limiting. A misbehaving client could flood the events table. Consider adding rate limiting middleware or documenting this as a future enhancement.
   - *File*: `packages/api/src/routes/funnel-routes.ts:15`
   - *Severity*: Medium — not a security issue (events are scoped to authenticated firms), but could cause storage bloat.

### Suggestions / Nits

1. **Nit:** `getTopPaths` default `days = 30` is hardcoded. Consider extracting to a named constant (`DEFAULT_FUNNEL_LOOKBACK_DAYS`) for readability.
   - *File*: `packages/api/src/services/funnel-service.ts:28`

2. **Optional:** The aggregation query uses `GROUP BY section_from, section_to`. Adding `HAVING count(*) > 1` would filter out noise from one-off transitions, making the results more actionable.
   - *File*: `packages/api/src/services/funnel-service.ts:32`

## Dead Code Identified

None.

## Validation Results

| Check | Status | Notes |
|-------|--------|-------|
| Type Check | ✅ PASS | Clean |
| Lint | ✅ PASS | No warnings |
| Tests | ✅ PASS | 42 passed (6 new) |

> Validation was run in an isolated worktree against the PR's HEAD commit. The user's working tree was not modified.

## What's Good

The RLS test is particularly well-crafted — it creates events for two different firms, then verifies that querying as Firm A returns zero events from Firm B. This is the most important test for data isolation and it's written clearly enough that a reviewer immediately understands what's being verified.

## Recommendation

Ready to merge. The Medium issue (rate limiting) is worth tracking as a follow-up but doesn't block this PR — the debounce provides client-side protection and events are firm-scoped so the blast radius is limited.

**Next steps:**
1. Merge the PR
2. Optionally file a follow-up issue for server-side rate limiting
3. Monitor event table growth during the first week of the pilot
